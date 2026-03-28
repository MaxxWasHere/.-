import qs.modules.common
import qs.modules.common.models
import qs.modules.common.functions
import QtQuick
import Qt.labs.folderlistmodel
import QtQml.Models
import Quickshell
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

/**
 * Provides a list of wallpapers and an "apply" action that calls the existing
 * switchwall.sh script. Grid order follows per-file dominant color (HSV) after sampling.
 */
Singleton {
    id: root

    /// Bumped when the sampling script or sort semantics change; forces re-queue of cached colors.
    readonly property string colorSampleAlgo: "dom2"

    property string thumbgenScriptPath: `${FileUtils.trimFileProtocol(Directories.scriptPath)}/thumbnails/thumbgen-venv.sh`
    property string generateThumbnailsMagickScriptPath: `${FileUtils.trimFileProtocol(Directories.scriptPath)}/thumbnails/generate-thumbnails-magick.sh`
    readonly property string colorSampleScriptPath: `${FileUtils.trimFileProtocol(Directories.scriptPath)}/colors/wallpaper-sample-color.sh`
    readonly property string colorCachePath: `${FileUtils.trimFileProtocol(Directories.genericCache)}/wallpaper-color-index.json`
    readonly property string sortOrderStorePath: `${FileUtils.trimFileProtocol(Directories.genericCache)}/wallpaper-sort-order.json`

    property alias directory: folderModel.folder
    readonly property string effectiveDirectory: FileUtils.trimFileProtocol(folderModel.folder.toString())
    readonly property url defaultFolder: Qt.resolvedUrl(`${FileUtils.trimFileProtocol(Directories.pictures)}/Wallpapers`)
    readonly property bool lockToWallpaperDirectory: true

    signal wallpaperFolderChanged()
    property alias folderModel: folderModel
    property string searchQuery: ""
    readonly property list<string> extensions: [
        "jpg", "jpeg", "png", "webp", "avif", "bmp", "svg"
    ]
    property list<string> wallpapers: []
    readonly property bool thumbnailGenerationRunning: thumbgenProc.running
    property real thumbnailGenerationProgress: 0

    /// Path → { mtimeMs, r, g, b, size, algo } (size matches FolderListModel fileSize for invalidation)
    property var colorCache: ({})

    /// Persisted grid order per folder: { byFolder: { "<dirKey>": { sortAlgo, paths: string[] } } }
    property var sortOrderStore: ({
        "byFolder": {}
    })

    property var colorSampleQueue: []
    readonly property bool colorSamplingActive: colorSampleProc.running || colorSampleQueue.length > 0

    signal changed()
    signal thumbnailGenerated(directory: string)
    signal thumbnailGeneratedFile(filePath: string)

    /// When false, the in-memory grid stays empty: no ListModel copy of the folder until the selector opens.
    property bool wallpaperSelectorSessionActive: false

    function load() {}

    function beginWallpaperSelectorSession() {
        root.wallpaperSelectorSessionActive = true;
        root.resetToDefaultWallpaperFolder();
        root.reloadSortOrderStoreFromDisk();
        root.reloadColorCacheFromDisk();
        root.rebuildGridModel();
        root.seedColorSampleQueue();
        deferredSessionGridRefresh.restart();
    }

    function endWallpaperSelectorSession() {
        rebuildAfterColorDebounce.stop();
        deferredSessionGridRefresh.stop();
        root.wallpaperSelectorSessionActive = false;
        wallpaperGridModel.clear();
        root.stopThumbnailBatch();
        root.stopColorSampling();
    }

    function syncGridIfSelectorSessionActive() {
        if (!root.wallpaperSelectorSessionActive)
            return;
        root.rebuildGridModel();
        root.seedColorSampleQueue();
        deferredSessionGridRefresh.restart();
    }

    function ensureGridModelPopulated() {
        if (wallpaperGridModel.count > 0)
            return;
        root.rebuildGridModel();
    }

    /// Single key for colorCache map (trim file://, drop trailing slash).
    function wallpaperCacheKey(rawPath) {
        var s = FileUtils.trimFileProtocol(String(rawPath ?? ""));
        while (s.length > 1 && (s.endsWith("/") || s.endsWith("\\")))
            s = s.slice(0, -1);
        return s;
    }

    /// True when cache row can be used for hue sort (algo + RGB + size rules).
    function colorEntryValidForRow(c, row) {
        if (!c)
            return false;
        // Disk cache may omit algo (older index); treat as current algo after ingest migration.
        if (c.algo !== undefined && c.algo !== null && c.algo !== "" && c.algo !== root.colorSampleAlgo)
            return false;
        if (c.r === undefined || c.g === undefined || c.b === undefined)
            return false;
        if (isNaN(c.r) || isNaN(c.g) || isNaN(c.b))
            return false;
        var fs = row.fileSize;
        var cs = c.size;
        // completeColorSample sets size -1 if folder scan missed the path; do not invalidate RGB then.
        // FolderListModel fileSize vs JSON number can differ by type (e.g. string vs int).
        if (fs !== undefined && fs !== null && cs !== undefined && cs !== null && cs !== -1) {
            if (Number(cs) !== Number(fs))
                return false;
        }
        return true;
    }

    function rgbToHsv(r, g, b) {
        const R = r / 255;
        const G = g / 255;
        const B = b / 255;
        const max = Math.max(R, G, B);
        const min = Math.min(R, G, B);
        const d = max - min;
        let h = 0;
        if (d > 1e-9) {
            if (max === R)
                h = ((60 * ((G - B) / d) % 360) + 360) % 360;
            else if (max === G)
                h = ((60 * ((B - R) / d) + 120) % 360 + 360) % 360;
            else
                h = ((60 * ((R - G) / d) + 240) % 360 + 360) % 360;
        }
        const s = max < 1e-9 ? 0 : d / max;
        const v = max;
        return {
            h: h,
            s: s,
            v: v
        };
    }

    function pruneColorCache() {
        // Never prune against an empty folder listing (startup / folder reset race) — would wipe the whole cache on disk.
        if (folderModel.count <= 0)
            return;
        var set = new Set();
        for (var i = 0; i < folderModel.count; i++)
            set.add(root.wallpaperCacheKey(folderModel.get(i, "filePath")));
        var c = root.colorCache;
        var next = {};
        for (var k in c) {
            if (Object.prototype.hasOwnProperty.call(c, k) && set.has(root.wallpaperCacheKey(k)))
                next[root.wallpaperCacheKey(k)] = c[k];
        }
        root.colorCache = next;
    }

    function saveColorCacheToDisk() {
        root.pruneColorCache();
        const json = JSON.stringify(root.colorCache);
        const path = root.colorCachePath;
        const dir = FileUtils.parentDirectory(path);
        Quickshell.execDetached([
            "bash", "-c",
            `mkdir -p '${StringUtils.shellSingleQuoteEscape(dir)}' && echo '${StringUtils.shellSingleQuoteEscape(json)}' > '${StringUtils.shellSingleQuoteEscape(path)}'`
        ]);
    }

    function saveColorCacheDeferred() {
        saveCacheDebouncer.restart();
    }

    /// Parse JSON from disk into colorCache (keys normalized via wallpaperCacheKey).
    function ingestColorCacheText(raw) {
        try {
            var parsed = JSON.parse((String(raw || "").trim()) || "{}");
            var obj = (typeof parsed === "object" && parsed !== null) ? parsed : {};
            var migrated = {};
            for (var key in obj) {
                if (!Object.prototype.hasOwnProperty.call(obj, key))
                    continue;
                var entry = obj[key];
                if (entry && typeof entry === "object") {
                    var row = Object.assign({}, entry);
                    if (row.algo === undefined || row.algo === null || row.algo === "")
                        row.algo = root.colorSampleAlgo;
                    migrated[root.wallpaperCacheKey(key)] = row;
                }
            }
            root.colorCache = migrated;
        } catch (e) {
            root.colorCache = {};
        }
    }

    /// Prefer FileView reload + text() so cache is applied in the same turn as open (Process/StdioCollector can finish late after QS reload).
    function reloadColorCacheFromDisk() {
        colorCacheFileView.reload();
        var t = "";
        try {
            t = colorCacheFileView.text();
        } catch (e) {
            t = "";
        }
        // If reload is async, text() can be empty until onLoaded; do not replace a good in-memory cache with {}.
        if (String(t || "").trim().length > 0)
            root.ingestColorCacheText(t);
        colorCacheResyncTimer.restart();
    }

    /// Qt FolderListModel role is `fileUrl`; `fileURL` is wrong and yields undefined (breaks thumbnails).
    function folderEntryAt(index) {
        const fpRaw = folderModel.get(index, "filePath");
        const fp = fpRaw !== undefined && fpRaw !== null ? String(fpRaw) : "";
        let fu = folderModel.get(index, "fileUrl");
        if (fu === undefined || fu === null)
            fu = folderModel.get(index, "fileURL");
        if ((fu === undefined || fu === null) && fp.length > 0)
            fu = Qt.resolvedUrl(fp);
        const sz = folderModel.get(index, "fileSize");
        return {
            filePath: fp,
            fileUrl: fu,
            fileName: String(folderModel.get(index, "fileName") ?? ""),
            fileIsDir: !!folderModel.get(index, "fileIsDir"),
            fileSize: sz
        };
    }

    /// Sort uses sampled dominant color per file (see wallpaper-sample-color.sh): HSV hue ring, vivid first.
    function wallpaperSortMode() {
        return "dominant_color";
    }

    function sortOrderFolderKey() {
        return root.wallpaperCacheKey(root.effectiveDirectory);
    }

    function ingestSortOrderStoreText(raw) {
        try {
            var parsed = JSON.parse((String(raw || "").trim()) || "{}");
            var bf = parsed.byFolder;
            if (typeof bf !== "object" || bf === null)
                bf = {};
            root.sortOrderStore = {
                "byFolder": bf
            };
        } catch (e) {
            root.sortOrderStore = {
                "byFolder": {}
            };
        }
    }

    function reloadSortOrderStoreFromDisk() {
        sortOrderFileView.reload();
        var t = "";
        try {
            t = sortOrderFileView.text();
        } catch (e) {
            t = "";
        }
        if (String(t || "").trim().length > 0)
            root.ingestSortOrderStoreText(t);
    }

    function saveSortOrderStoreToDisk() {
        const json = JSON.stringify(root.sortOrderStore);
        const path = root.sortOrderStorePath;
        const dir = FileUtils.parentDirectory(path);
        Quickshell.execDetached([
            "bash", "-c",
            `mkdir -p '${StringUtils.shellSingleQuoteEscape(dir)}' && echo '${StringUtils.shellSingleQuoteEscape(json)}' > '${StringUtils.shellSingleQuoteEscape(path)}'`
        ]);
    }

    function saveSortOrderStoreDeferred() {
        saveSortOrderDebouncer.restart();
    }

    function sortOrderPathsMatchCurrent(keys, savedPaths) {
        if (!savedPaths || savedPaths.length !== keys.length || keys.length === 0)
            return false;
        var a = keys.slice().map(function(k) {
            return root.wallpaperCacheKey(k);
        }).sort();
        var b = savedPaths.slice().map(function(p) {
            return root.wallpaperCacheKey(p);
        }).sort();
        for (var i = 0; i < a.length; i++) {
            if (a[i] !== b[i])
                return false;
        }
        return true;
    }

    function orderRowsBySavedPaths(rows, savedPaths) {
        var keyToRow = {};
        for (var i = 0; i < rows.length; i++) {
            var r = rows[i];
            keyToRow[root.wallpaperCacheKey(r.filePath)] = r;
        }
        var out = [];
        for (var j = 0; j < savedPaths.length; j++) {
            var k = root.wallpaperCacheKey(savedPaths[j]);
            if (keyToRow[k])
                out.push(keyToRow[k]);
        }
        return out.length === rows.length ? out : null;
    }

    function recordSortOrderForCurrentFolder(orderedRows) {
        var fk = root.sortOrderFolderKey();
        var paths = [];
        for (var i = 0; i < orderedRows.length; i++)
            paths.push(root.wallpaperCacheKey(orderedRows[i].filePath));
        var bf = root.sortOrderStore.byFolder ? Object.assign({}, root.sortOrderStore.byFolder) : {};
        bf[fk] = {
            sortAlgo: root.colorSampleAlgo,
            paths: paths
        };
        root.sortOrderStore = {
            "byFolder": bf
        };
        root.saveSortOrderStoreDeferred();
    }

    function rebuildGridModel() {
        rebuildAfterColorDebounce.stop();
        var n = folderModel.count;
        var rows = [];
        for (var i = 0; i < n; i++)
            rows.push(root.folderEntryAt(i));
        var fk = root.sortOrderFolderKey();
        var store = root.sortOrderStore.byFolder && root.sortOrderStore.byFolder[fk];
        var savedPaths = store && store.paths ? store.paths : null;
        var savedAlgo = store && store.sortAlgo ? store.sortAlgo : "";
        var currentKeys = [];
        for (var ki = 0; ki < rows.length; ki++)
            currentKeys.push(root.wallpaperCacheKey(rows[ki].filePath));

        var usedSavedOrder = false;
        if (rows.length > 0 && savedPaths && savedAlgo === root.colorSampleAlgo && root.sortOrderPathsMatchCurrent(currentKeys, savedPaths)) {
            var reordered = root.orderRowsBySavedPaths(rows, savedPaths);
            if (reordered) {
                rows = reordered;
                usedSavedOrder = true;
            }
        }

        if (rows.length > 0 && !usedSavedOrder) {
            /// Below this saturation, hue is unreliable — group as neutrals, sort by brightness.
            var neutralSaturation = 0.08;
            var scored = rows.map(function(r, folderIndex) {
                var path = root.wallpaperCacheKey(r.filePath);
                var c = root.colorCache[path];
                var valid = root.colorEntryValidForRow(c, r);
                var h = 0;
                var s = 0;
                var v = 0;
                if (valid) {
                    var o = root.rgbToHsv(c.r, c.g, c.b);
                    h = o.h;
                    s = o.s;
                    v = o.v;
                }
                var neutral = !valid || s < neutralSaturation;
                return {
                    row: r,
                    folderIndex: folderIndex,
                    hasColor: valid,
                    neutral: neutral,
                    h: h,
                    s: s,
                    v: v
                };
            });
            scored.sort(function(A, B) {
                var cmp;
                if (A.hasColor !== B.hasColor)
                    return A.hasColor ? -1 : 1;
                if (!A.hasColor) {
                    cmp = String(A.row.fileName).localeCompare(String(B.row.fileName));
                    return cmp !== 0 ? cmp : (A.folderIndex - B.folderIndex);
                }
                if (A.neutral !== B.neutral)
                    return A.neutral ? 1 : -1;
                if (A.neutral && B.neutral) {
                    if (A.v !== B.v)
                        return B.v - A.v;
                    cmp = String(A.row.fileName).localeCompare(String(B.row.fileName));
                    return cmp !== 0 ? cmp : (A.folderIndex - B.folderIndex);
                }
                if (A.h !== B.h)
                    return A.h - B.h;
                if (A.s !== B.s)
                    return B.s - A.s;
                if (A.v !== B.v)
                    return B.v - A.v;
                cmp = String(A.row.fileName).localeCompare(String(B.row.fileName));
                return cmp !== 0 ? cmp : (A.folderIndex - B.folderIndex);
            });
            rows.length = 0;
            for (var j = 0; j < scored.length; j++)
                rows.push(scored[j].row);
            root.recordSortOrderForCurrentFolder(rows);
        }

        wallpaperGridModel.clear();
        for (var k = 0; k < rows.length; k++) {
            var r = rows[k];
            wallpaperGridModel.append({
                filePath: r.filePath,
                fileUrl: r.fileUrl,
                fileName: r.fileName,
                fileIsDir: r.fileIsDir,
                fileSize: r.fileSize
            });
        }
    }

    function seedColorSampleQueue() {
        var q = [];
        for (var i = 0; i < folderModel.count; i++) {
            var row = root.folderEntryAt(i);
            var fp = root.wallpaperCacheKey(row.filePath);
            if (!root.colorEntryValidForRow(root.colorCache[fp], row))
                q.push(fp);
        }
        root.colorSampleQueue = q;
        dequeueColorSample();
    }

    function dequeueColorSample() {
        if (colorSampleProc.running)
            return;
        if (root.colorSampleQueue.length === 0)
            return;
        const fp = root.colorSampleQueue[0];
        const rest = root.colorSampleQueue.slice(1);
        root.colorSampleQueue = rest;
        colorSampleProc.pendingPath = fp;
        colorSampleProc.command = ["bash", root.colorSampleScriptPath, fp];
        colorSampleProc.running = true;
    }

    function completeColorSample(path, stdoutText) {
        var norm = root.wallpaperCacheKey(path);
        var parts = stdoutText.trim().split(/\s+/);
        if (parts.length < 4)
            return;
        var r = parseInt(parts[1], 10);
        var g = parseInt(parts[2], 10);
        var b = parseInt(parts[3], 10);
        if (isNaN(r) || isNaN(g) || isNaN(b))
            return;
        var size = -1;
        for (var i = 0; i < folderModel.count; i++) {
            var fp = root.wallpaperCacheKey(folderModel.get(i, "filePath"));
            if (fp === norm) {
                size = folderModel.get(i, "fileSize");
                break;
            }
        }
        var copy = Object.assign({}, root.colorCache);
        copy[norm] = {
            mtimeMs: parseInt(parts[0], 10),
            r: r,
            g: g,
            b: b,
            size: size,
            algo: root.colorSampleAlgo
        };
        root.colorCache = copy;
        saveColorCacheDeferred();
        if (root.wallpaperSelectorSessionActive)
            rebuildAfterColorDebounce.restart();
    }

    function cycleWallpaperSortMode() {
        rebuildGridModel();
        seedColorSampleQueue();
        if (root.wallpaperSelectorSessionActive)
            deferredSessionGridRefresh.restart();
    }

    Process {
        id: applyProc
    }

    function openFallbackPicker(darkMode = Appearance.m3colors.darkmode) {
        applyProc.exec([
            Directories.wallpaperSwitchScriptPath,
            "--mode", (darkMode ? "dark" : "light")
        ]);
    }

    function apply(path, darkMode = Appearance.m3colors.darkmode) {
        if (!path || path.length == 0)
            return;
        applyProc.exec([
            Directories.wallpaperSwitchScriptPath,
            "--image", path,
            "--mode", (darkMode ? "dark" : "light")
        ]);
        root.changed();
    }

    Process {
        id: selectProc
        property string filePath: ""
        property bool darkMode: Appearance.m3colors.darkmode
        function select(filePath, darkMode = Appearance.m3colors.darkmode) {
            selectProc.filePath = filePath;
            selectProc.darkMode = darkMode;
            selectProc.exec(["test", "-d", FileUtils.trimFileProtocol(filePath)]);
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                setDirectory(selectProc.filePath);
                return;
            }
            root.apply(selectProc.filePath, selectProc.darkMode);
        }
    }

    function select(filePath, darkMode = Appearance.m3colors.darkmode) {
        selectProc.select(filePath, darkMode);
    }

    function randomFromCurrentFolder(darkMode = Appearance.m3colors.darkmode) {
        root.ensureGridModelPopulated();
        if (wallpaperGridModel.count === 0)
            return;
        const randomIndex = Math.floor(Math.random() * wallpaperGridModel.count);
        const row = wallpaperGridModel.get(randomIndex);
        const filePath = row && row.filePath ? row.filePath : "";
        if (!filePath)
            return;
        print("Randomly selected wallpaper:", filePath);
        root.select(filePath, darkMode);
        if (!root.wallpaperSelectorSessionActive)
            wallpaperGridModel.clear();
    }

    Process {
        id: validateDirProc
        property string nicePath: ""
        function setDirectoryIfValid(path) {
            validateDirProc.nicePath = FileUtils.trimFileProtocol(path).replace(/\/+$/, "");
            if (/^\/*$/.test(validateDirProc.nicePath))
                validateDirProc.nicePath = "/";
            validateDirProc.exec([
                "bash", "-c",
                `if [ -d "${validateDirProc.nicePath}" ]; then echo dir; elif [ -f "${validateDirProc.nicePath}" ]; then echo file; else echo invalid; fi`
            ]);
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim();
                if (result === "dir")
                    root.directory = Qt.resolvedUrl(validateDirProc.nicePath);
                else if (result === "file")
                    root.directory = Qt.resolvedUrl(FileUtils.parentDirectory(validateDirProc.nicePath));
            }
        }
    }

    function setDirectory(path) {
        if (root.lockToWallpaperDirectory) {
            folderModel.folder = root.defaultFolder;
            return;
        }
        validateDirProc.setDirectoryIfValid(path);
    }

    function resetToDefaultWallpaperFolder() {
        folderModel.folder = root.defaultFolder;
    }

    function navigateUp() {
        if (root.lockToWallpaperDirectory)
            return;
        folderModel.navigateUp();
    }
    function navigateBack() {
        if (root.lockToWallpaperDirectory)
            return;
        folderModel.navigateBack();
    }
    function navigateForward() {
        if (root.lockToWallpaperDirectory)
            return;
        folderModel.navigateForward();
    }

    FolderListModelWithHistory {
        id: folderModel
        folder: root.defaultFolder
        caseSensitive: false
        nameFilters: root.extensions.map(ext => `*.${ext}`)
        showDirs: false
        showDotAndDotDot: false
        showOnlyReadable: true
        sortField: FolderListModel.Time
        sortReversed: false
        onFolderChanged: {
            root.wallpaperFolderChanged();
        }
    }

    ListModel {
        id: wallpaperGridModel
    }

    property alias gridModel: wallpaperGridModel

    Connections {
        target: folderModel
        function onCountChanged() {
            if (root.wallpaperSelectorSessionActive) {
                root.rebuildGridModel();
                deferredSessionGridRefresh.restart();
            }
            root.seedColorSampleQueue();
        }
    }

    /// Re-sort after async color-cache load and FolderListModel settle (QS restart / folder refresh).
    Timer {
        id: deferredSessionGridRefresh
        interval: 160
        repeat: false
        onTriggered: {
            if (!root.wallpaperSelectorSessionActive)
                return;
            root.rebuildGridModel();
            root.seedColorSampleQueue();
        }
    }

    /// FileView.text() can lag reload(); re-read once so dominant-color sort matches disk cache.
    Timer {
        id: colorCacheResyncTimer
        interval: 220
        repeat: false
        onTriggered: {
            var t = "";
            try {
                t = colorCacheFileView.text();
            } catch (e) {
                t = "";
            }
            if (String(t || "").trim().length > 0)
                root.ingestColorCacheText(t);
            root.syncGridIfSelectorSessionActive();
            root.seedColorSampleQueue();
        }
    }

    Timer {
        id: saveCacheDebouncer
        interval: 400
        repeat: false
        onTriggered: root.saveColorCacheToDisk()
    }

    Timer {
        id: saveSortOrderDebouncer
        interval: 500
        repeat: false
        onTriggered: root.saveSortOrderStoreToDisk()
    }

    /// Full grid rebuild after color samples was causing visible snapping; coalesce many updates into one.
    Timer {
        id: rebuildAfterColorDebounce
        interval: 900
        repeat: false
        onTriggered: {
            if (root.wallpaperSelectorSessionActive)
                root.rebuildGridModel();
        }
    }

    FileView {
        id: colorCacheFileView
        path: Qt.resolvedUrl(root.colorCachePath)
        onLoaded: {
            root.ingestColorCacheText(colorCacheFileView.text());
            colorCacheResyncTimer.stop();
            root.syncGridIfSelectorSessionActive();
            root.seedColorSampleQueue();
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound)
                root.colorCache = {};
            root.syncGridIfSelectorSessionActive();
            root.seedColorSampleQueue();
        }
    }

    FileView {
        id: sortOrderFileView
        path: Qt.resolvedUrl(root.sortOrderStorePath)
        onLoaded: {
            root.ingestSortOrderStoreText(sortOrderFileView.text());
            root.syncGridIfSelectorSessionActive();
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound)
                root.sortOrderStore = {
                    "byFolder": {}
                };
            root.syncGridIfSelectorSessionActive();
        }
    }

    Process {
        id: colorSampleProc
        property string pendingPath: ""
        running: false
        command: ["echo"]
        stdout: StdioCollector {
            id: colorSampleOut
            onStreamFinished: {
                if (colorSampleProc.pendingPath.length > 0 && this.text.trim().length > 0)
                    root.completeColorSample(colorSampleProc.pendingPath, this.text);
                colorSampleProc.pendingPath = "";
                Qt.callLater(root.dequeueColorSample);
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                colorSampleProc.pendingPath = "";
                Qt.callLater(root.dequeueColorSample);
            }
        }
    }

    Component.onCompleted: {
        root.reloadSortOrderStoreFromDisk();
        root.reloadColorCacheFromDisk();
        root.syncGridIfSelectorSessionActive();
        root.seedColorSampleQueue();
    }

    function generateThumbnail(size: string) {
        if (!["normal", "large", "x-large", "xx-large"].includes(size))
            throw new Error("Invalid thumbnail size");
        thumbgenProc.directory = root.directory;
        thumbgenProc.running = false;
        thumbgenProc.command = [
            "bash", "-c",
            `${thumbgenScriptPath} --size ${size} --machine_progress -d ${FileUtils.trimFileProtocol(root.directory)} || ${generateThumbnailsMagickScriptPath} --size ${size} -d ${FileUtils.trimFileProtocol(root.directory)}`,
        ];
        root.thumbnailGenerationProgress = 0;
        thumbgenProc.running = true;
    }

    function stopThumbnailBatch() {
        thumbgenProc.running = false;
    }

    function stopColorSampling() {
        rebuildAfterColorDebounce.stop();
        root.colorSampleQueue = [];
        colorSampleProc.running = false;
        colorSampleProc.pendingPath = "";
    }

    Process {
        id: thumbgenProc
        property string directory
        stdout: SplitParser {
            onRead: data => {
                let match = data.match(/PROGRESS (\d+)\/(\d+)/);
                if (match) {
                    const completed = parseInt(match[1]);
                    const total = parseInt(match[2]);
                    root.thumbnailGenerationProgress = completed / total;
                }
                match = data.match(/FILE (.+)/);
                if (match) {
                    const filePath = match[1];
                    root.thumbnailGeneratedFile(filePath);
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.thumbnailGenerated(thumbgenProc.directory);
        }
    }

    IpcHandler {
        target: "wallpapers"

        function apply(path: string): void {
            root.apply(path);
        }
    }
}
