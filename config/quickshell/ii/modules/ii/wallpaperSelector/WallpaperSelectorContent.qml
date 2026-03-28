import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

MouseArea {
    id: root
    readonly property int columns: Math.max(2, Math.min(8, Config.options?.wallpaperSelector?.gridColumns ?? 4))
    readonly property real wallpaperThumbnailCellAspect: Math.max(0.5, Math.min(3, Config.options?.wallpaperSelector?.thumbnailCellAspectRatio ?? 1.333333))
    readonly property real wallpaperThumbnailCellScale: Math.max(0.45, Math.min(2.15, Config.options?.wallpaperSelector?.thumbnailCellScale ?? 1))
    property bool useDarkMode: Appearance.m3colors.darkmode
    /// Bumped on scroll coalesce / movement end so delegates re-evaluate lazy thumbnail loading without binding every frame.
    property int lazyScrollEpoch: 0
    /// Matches batch thumbgen / Freedesktop cache tier for visible cell decode size.
    readonly property string wallpaperThumbSizeName: {
        const m = (Appearance.sizes.wallpaperSelectorItemMargins + Appearance.sizes.wallpaperSelectorItemPadding) * 2;
        const w = Math.max(1, grid.cellWidth - m);
        const h = Math.max(1, grid.cellHeight - m);
        return Images.thumbnailSizeNameForDimensions(w, h);
    }

    function updateThumbnails() {
        const totalImageMargin = (Appearance.sizes.wallpaperSelectorItemMargins + Appearance.sizes.wallpaperSelectorItemPadding) * 2
        const thumbnailSizeName = Images.thumbnailSizeNameForDimensions(grid.cellWidth - totalImageMargin, grid.cellHeight - totalImageMargin)
        Wallpapers.generateThumbnail(thumbnailSizeName)
    }

    Connections {
        target: Wallpapers
        function onWallpaperFolderChanged() {
            root.updateThumbnails()
        }
    }

    function selectWallpaperPath(filePath) {
        if (filePath && filePath.length > 0)
            Wallpapers.select(filePath, root.useDarkMode);
    }

    anchors.fill: parent

    // Loader only instantiates this while the selector is open; openChanged is easy to miss on first load.
    Component.onCompleted: {
        Wallpapers.beginWallpaperSelectorSession();
        root.updateThumbnails();
        wallpaperGridBackground.focus = true;
        Qt.callLater(() => grid.forceActiveFocus());
        Qt.callLater(() => {
            grid.contentY = 0;
            grid.currentIndex = grid.count > 0 ? 0 : -1;
        });
    }

    StyledRectangularShadow {
        target: wallpaperGridBackground
    }

    ColumnLayout {
        id: selectorColumn
        anchors.fill: parent
        anchors.margins: Appearance.sizes.elevationMargin
        spacing: 12

        Rectangle {
            id: wallpaperGridBackground
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            color: Appearance.colors.colLayer0
            radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    GlobalStates.wallpaperSelectorOpen = false;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    grid.moveSelection(-grid.keyStepMultiplier(event.modifiers));
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    grid.moveSelection(grid.keyStepMultiplier(event.modifiers));
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    grid.moveSelection(-grid.columns * grid.keyStepMultiplier(event.modifiers));
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    grid.moveSelection(grid.columns * grid.keyStepMultiplier(event.modifiers));
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageUp) {
                    grid.pageScroll(-1, event.modifiers);
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageDown) {
                    grid.pageScroll(1, event.modifiers);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Home) {
                    grid.scrollToTop();
                    event.accepted = true;
                } else if (event.key === Qt.Key_End) {
                    grid.scrollToEnd();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    grid.activateCurrent();
                    event.accepted = true;
                }
            }

            Item {
                id: gridDisplayRegion
                anchors.fill: parent
                anchors.margins: 8

            GridView {
                id: grid
                visible: Wallpapers.gridModel.count > 0

                readonly property int columns: root.columns
                readonly property real maxScrollY: Math.max(0, contentHeight - height)

                flickDeceleration: Config.options?.wallpaperSelector?.gridFlickDeceleration ?? 1650
                maximumFlickVelocity: Config.options?.wallpaperSelector?.gridMaximumFlickVelocity ?? 6000
                pressDelay: Config.options?.wallpaperSelector?.gridPressDelay ?? 0
                cacheBuffer: Config.options?.wallpaperSelector?.gridCacheBuffer ?? 320

                anchors.fill: parent
                cellWidth: Math.max(1, width / root.columns)
                cellHeight: Math.max(1, (cellWidth / root.wallpaperThumbnailCellAspect) * root.wallpaperThumbnailCellScale)
                interactive: true
                clip: true
                keyNavigationWraps: true
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                ScrollBar.vertical: StyledScrollBar {}

                function keyStepMultiplier(modifiers) {
                    const fast = (modifiers & Qt.ShiftModifier) || (modifiers & Qt.ControlModifier);
                    return fast ? Math.max(1, Config.options?.wallpaperSelector?.gridKeyboardFastStepMultiplier ?? 4) : 1;
                }

                function pageScroll(direction, modifiers) {
                    const mult = grid.keyStepMultiplier(modifiers);
                    const page = Math.max(grid.cellHeight, grid.height * 0.88) * mult;
                    grid.contentY = Math.max(0, Math.min(grid.maxScrollY, grid.contentY + direction * page));
                }

                function scrollToTop() {
                    if (grid.count <= 0)
                        return;
                    grid.currentIndex = 0;
                    grid.positionViewAtIndex(0, GridView.Beginning);
                }

                function scrollToEnd() {
                    if (grid.count <= 0)
                        return;
                    const last = grid.count - 1;
                    grid.currentIndex = last;
                    grid.positionViewAtIndex(last, GridView.End);
                }

                Component.onCompleted: {
                    root.updateThumbnails()
                }

                function moveSelection(delta) {
                    if (grid.count <= 0)
                        return;
                    const next = Math.max(0, Math.min(grid.count - 1, grid.currentIndex + delta));
                    grid.currentIndex = next;
                    grid.positionViewAtIndex(next, GridView.Contain);
                }

                function activateCurrent() {
                    if (grid.count <= 0)
                        return;
                    if (grid.currentIndex < 0 || grid.currentIndex >= grid.count)
                        return;
                    let filePath = "";
                    const m = grid.model;
                    if (m && typeof m.get === "function") {
                        const row = m.get(grid.currentIndex);
                        if (row && row.filePath)
                            filePath = String(row.filePath);
                    }
                    root.selectWallpaperPath(filePath);
                }

                model: Wallpapers.gridModel
                onModelChanged: currentIndex = grid.count > 0 ? 0 : -1

                delegate: Item {
                    id: wrap
                    required property int index
                    required property var filePath
                    required property var fileUrl
                    required property var fileName
                    required property var fileIsDir

                    readonly property Item wallpaperPanelRoot: {
                        const gv = GridView.view;
                        if (!gv || !gv.parent || !gv.parent.parent || !gv.parent.parent.parent || !gv.parent.parent.parent.parent)
                            return null;
                        return gv.parent.parent.parent.parent;
                    }
                    readonly property bool loadThumbLazy: {
                        const gv = GridView.view;
                        if (!gv)
                            return true;
                        // Until the grid/delegate have real size, viewport math is wrong — keep thumbs enabled.
                        if (gv.width <= 0 || gv.height <= 0 || gv.cellHeight <= 0)
                            return true;
                        const pr = wallpaperPanelRoot;
                        if (pr)
                            void pr.lazyScrollEpoch;
                        void gv.contentY;
                        void gv.height;
                        void gv.width;
                        const pad = Math.max(gv.cellHeight * 2.5, 300);
                        const top = gv.contentY - pad;
                        const bot = gv.contentY + gv.height + pad;
                        const iy = wrap.y;
                        const ih = wrap.height;
                        if (ih <= 0)
                            return true;
                        return !(iy + ih < top || iy > bot);
                    }

                    width: grid.cellWidth
                    height: grid.cellHeight
                    property real cellOpacity: Config.options?.wallpaperSelector?.gridDelegateIntroAnimation ? 0 : 1
                    opacity: cellOpacity

                    SequentialAnimation {
                        id: delegateIntroAnim
                        PauseAnimation {
                            duration: Math.min(wrap.index * 12, 280)
                        }
                        NumberAnimation {
                            target: wrap
                            property: "cellOpacity"
                            from: 0
                            to: 1
                            duration: 140
                            easing.type: Easing.OutCubic
                        }
                    }
                    Component.onCompleted: {
                        if (Config.options?.wallpaperSelector?.gridDelegateIntroAnimation)
                            delegateIntroAnim.start();
                        else
                            wrap.cellOpacity = 1;
                    }

                    WallpaperDirectoryItem {
                        anchors.fill: parent
                        thumbnailSizeName: root.wallpaperThumbSizeName
                        loadThumbnail: wrap.loadThumbLazy
                        fitWithoutStretch: Config.options?.wallpaperSelector?.fitThumbnailsWithoutStretch ?? false
                        fileModelData: ({
                            filePath: String(wrap.filePath ?? ""),
                            fileUrl: (wrap.fileUrl !== undefined && wrap.fileUrl !== null) ? wrap.fileUrl : Qt.resolvedUrl(String(wrap.filePath ?? "")),
                            fileName: String(wrap.fileName ?? ""),
                            fileIsDir: !!wrap.fileIsDir
                        })
                        colBackground: (wrap.filePath === Config.options.background.wallpaperPath) ? Appearance.colors.colSecondaryContainer : ColorUtils.transparentize(Appearance.colors.colPrimaryContainer)

                        onEntered: {
                            grid.currentIndex = wrap.index;
                        }

                        onActivated: {
                            root.selectWallpaperPath(String(wrap.filePath ?? ""));
                        }
                    }
                }

                Timer {
                    id: lazyScrollCoalesce
                    interval: 160
                    repeat: false
                    onTriggered: root.lazyScrollEpoch++
                }
                Connections {
                    target: grid
                    function onContentYChanged() {
                        lazyScrollCoalesce.restart();
                    }
                    function onHeightChanged() {
                        lazyScrollCoalesce.restart();
                    }
                    function onWidthChanged() {
                        lazyScrollCoalesce.restart();
                    }
                    function onMovingChanged() {
                        if (!grid.moving)
                            root.lazyScrollEpoch++;
                        lazyScrollCoalesce.restart();
                    }
                }

                layer.enabled: true
                layer.smooth: false
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: grid.width
                        height: grid.height
                        radius: wallpaperGridBackground.radius - 8
                    }
                }
            }

            // Animated selection ring (morphs with index and cell size changes)
            Item {
                id: selectionRingHost
                anchors.fill: grid
                clip: true
                visible: grid.visible && grid.count > 0 && grid.currentIndex >= 0
                z: 2

                Item {
                    id: selectionRing
                    x: (grid.currentIndex % grid.columns) * grid.cellWidth - grid.contentX
                    y: Math.floor(grid.currentIndex / grid.columns) * grid.cellHeight - grid.contentY
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Behavior on x {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on y {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: Appearance.rounding.normal + 2
                        color: "transparent"
                        border.width: 4
                        border.color: Appearance.colors.colPrimary
                    }
                }
            }

                StyledIndeterminateProgressBar {
                    id: indeterminateProgressBar
                    visible: Wallpapers.thumbnailGenerationRunning && value == 0
                    z: 11
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 8
                        leftMargin: 8
                        rightMargin: 8
                    }
                }

                StyledProgressBar {
                    visible: Wallpapers.thumbnailGenerationRunning && value > 0
                    value: Wallpapers.thumbnailGenerationProgress
                    z: 11
                    anchors.fill: indeterminateProgressBar
                }
            }
        }

        Toolbar {
            id: floatingActions
            Layout.alignment: Qt.AlignHCenter

            IconToolbarButton {
                implicitWidth: height
                onClicked: {
                    Wallpapers.openFallbackPicker(root.useDarkMode);
                    GlobalStates.wallpaperSelectorOpen = false;
                }
                altAction: () => {
                    Wallpapers.openFallbackPicker(root.useDarkMode);
                    GlobalStates.wallpaperSelectorOpen = false;
                    Config.options.wallpaperSelector.useSystemFileDialog = true
                }
                text: "open_in_new"
            }

                IconToolbarButton {
                    implicitWidth: height
                    onClicked: {
                        Wallpapers.randomFromCurrentFolder();
                    }
                    text: "ifl"
                }

                IconToolbarButton {
                    implicitWidth: height
                    onClicked: () => Wallpapers.cycleWallpaperSortMode()
                    text: "palette"
                }

            IconToolbarButton {
                implicitWidth: height
                onClicked: root.useDarkMode = !root.useDarkMode
                text: root.useDarkMode ? "dark_mode" : "light_mode"
            }

            IconToolbarButton {
                implicitWidth: height
                onClicked: {
                    GlobalStates.wallpaperSelectorOpen = false;
                }
                text: "close"
            }
        }
    }

    Connections {
        target: Wallpapers
        function onChanged() {
            GlobalStates.wallpaperSelectorOpen = false;
        }
    }
}
