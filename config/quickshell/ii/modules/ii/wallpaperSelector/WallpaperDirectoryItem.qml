import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

MouseArea {
    id: root
    required property var fileModelData
    /// Freedesktop cache tier name (normal, large, …). Empty = load scaled original only.
    property string thumbnailSizeName: ""
    /// When false, skip decoding the image (viewport lazy load in wallpaper grid).
    property bool loadThumbnail: true
    /// Letterbox inside tile (true aspect); false = crop fill.
    property bool fitWithoutStretch: false
    property bool isDirectory: fileModelData.fileIsDir
    property bool useThumbnail: Images.isValidImageByName(fileModelData.fileName)

    readonly property string _filePathStr: String(fileModelData.filePath ?? "")
    readonly property string thumbCachePath: root.thumbnailSizeName.length > 0 && _filePathStr.length > 0 ? Images.thumbnailCacheFilePathForFile(_filePathStr, root.thumbnailSizeName) : ""

    property alias colBackground: background.color
    property alias radius: background.radius
    property alias margins: background.anchors.margins
    property alias padding: wallpaperItemImageContainer.anchors.margins
    margins: Appearance.sizes.wallpaperSelectorItemMargins
    padding: Appearance.sizes.wallpaperSelectorItemPadding

    signal activated()

    hoverEnabled: true
    onClicked: root.activated()

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Appearance.rounding.normal
        clip: true
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        Item {
            id: wallpaperItemImageContainer
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                visible: root.useThumbnail && !root.loadThumbnail
                radius: Appearance.rounding.normal
                color: Appearance.colors.colLayer2
            }

            Image {
                id: wallpaperThumb
                property int sourcePhase: 0
                visible: root.useThumbnail && root.loadThumbnail
                anchors.fill: parent
                asynchronous: true
                cache: true
                smooth: true
                mipmap: false
                fillMode: root.fitWithoutStretch ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                source: {
                    if (!root.useThumbnail || !root.loadThumbnail)
                        return "";
                    if (wallpaperThumb.sourcePhase === 0 && root.thumbCachePath.length > 0)
                        return Qt.resolvedUrl(root.thumbCachePath);
                    return fileModelData.fileUrl || Qt.resolvedUrl(root._filePathStr);
                }
                sourceSize: wallpaperThumb.sourcePhase === 0 && root.thumbCachePath.length > 0 ? Qt.size(0, 0) : (root.fitWithoutStretch ? Qt.size(768, 768) : Qt.size(512, 512))
                onStatusChanged: {
                    if (status === Image.Error && wallpaperThumb.sourcePhase === 0 && root.thumbCachePath.length > 0)
                        wallpaperThumb.sourcePhase = 1;
                }
            }

            Connections {
                target: root
                function onThumbCachePathChanged() {
                    wallpaperThumb.sourcePhase = 0;
                }
            }

            Connections {
                target: Wallpapers
                function onThumbnailGeneratedFile(filePath) {
                    if (!root.loadThumbnail || !root.useThumbnail || root.thumbCachePath.length === 0)
                        return;
                    const fp = String(filePath ?? "");
                    if (fp.length === 0 || FileUtils.trimFileProtocol(fp) !== FileUtils.trimFileProtocol(root._filePathStr))
                        return;
                    wallpaperThumb.sourcePhase = 0;
                    wallpaperThumb.source = "";
                    wallpaperThumb.source = Qt.resolvedUrl(root.thumbCachePath);
                }
            }

            Loader {
                id: iconLoader
                active: !root.useThumbnail
                anchors.fill: parent
                sourceComponent: DirectoryIcon {
                    fileModelData: root.fileModelData
                    sourceSize.width: wallpaperItemImageContainer.width
                    sourceSize.height: wallpaperItemImageContainer.height
                }
            }

            layer.enabled: true
            layer.smooth: false
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: wallpaperItemImageContainer.width
                    height: wallpaperItemImageContainer.height
                    radius: Appearance.rounding.normal
                }
            }
        }
    }
}
