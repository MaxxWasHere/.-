//@ pragma UseQApplication
//@ pragma Env II_SETTINGS_APP=1
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the app smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

ApplicationWindow {
    id: root
    readonly property int settingsNavCardPadding: 10
    property string firstRunFilePath: CF.FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: Appearance.settingsWindowContentPadding
    property bool showNextTime: false
    property var pages: [
        {
            name: Translation.tr("Quick"),
            icon: "instant_mix",
            component: "modules/settings/QuickConfig.qml",
            searchTags: ["quick", "shortcuts", "wallpaper", "first", "settings app", "style", "cli", "mono", "amoled", "typography"]
        },
        {
            name: Translation.tr("General"),
            icon: "browse",
            component: "modules/settings/GeneralConfig.qml",
            searchTags: ["general", "locale", "time", "date", "keybinds"]
        },
        {
            name: Translation.tr("Bar"),
            icon: "toast",
            iconRotation: 180,
            component: "modules/settings/BarConfig.qml",
            searchTags: ["bar", "status", "tray", "workspaces", "weather", "clock", "oled"]
        },
        {
            name: Translation.tr("Background"),
            icon: "texture",
            component: "modules/settings/BackgroundConfig.qml",
            searchTags: ["background", "wallpaper", "widgets", "parallax", "blur"]
        },
        {
            name: Translation.tr("Interface"),
            icon: "bottom_app_bar",
            component: "modules/settings/InterfaceConfig.qml",
            searchTags: ["interface", "sidebar", "osd", "notifications", "screen", "corners", "overview", "dock", "lock"]
        },
        {
            name: Translation.tr("Customize"),
            icon: "tune",
            component: "modules/settings/CustomizationConfig.qml",
            searchTags: ["customize", "theme", "oled", "corners", "bar", "palette", "appearance", "transparency", "matugen", "cli", "clock", "dock", "lock", "amoled"]
        },
        {
            name: Translation.tr("Matugen"),
            icon: "gradient",
            component: "modules/settings/MatugenConfig.qml",
            searchTags: ["matugen", "wallpaper", "colors", "discord", "vencord", "betterdiscord", "contrast", "palette", "scheme"]
        },
        {
            name: Translation.tr("Launcher"),
            icon: "search",
            component: "modules/settings/LauncherConfig.qml",
            searchTags: ["launcher", "search", "overview", "animation", "spotlight", "run", "apps", "super"]
        },
        {
            name: Translation.tr("Rice"),
            icon: "auto_awesome",
            component: "modules/settings/RicingConfig.qml",
            searchTags: ["rice", "ricing", "hyprland", "screenshot", "capture", "theme"]
        },
        {
            name: Translation.tr("Services"),
            icon: "settings",
            component: "modules/settings/ServicesConfig.qml",
            searchTags: ["services", "audio", "network", "bluetooth", "easyeffects"]
        },
        {
            name: Translation.tr("Advanced"),
            icon: "construction",
            component: "modules/settings/AdvancedConfig.qml",
            searchTags: ["advanced", "debug", "ipc", "experimental"]
        },
        {
            name: Translation.tr("About"),
            icon: "info",
            component: "modules/settings/About.qml",
            searchTags: ["about", "version", "credits"]
        }
    ]
    property int currentPage: 0
    property string navSearch: ""
    property int navRailIndex: 0
    /// 0 = all pages; 1 = shell & desktop; 2 = look & apps; 3 = system
    property int settingsNavCategoryIndex: 0

    function settingsCategoryAllowedPages(catIdx) {
        if (catIdx <= 0)
            return null;
        if (catIdx === 1)
            return [0, 1, 2, 3, 4];
        if (catIdx === 2)
            return [5, 6, 7, 8];
        if (catIdx === 3)
            return [9, 10, 11];
        return null;
    }

    readonly property var filteredPageIndices: {
        const q = root.navSearch.trim().toLowerCase();
        const n = root.pages.length;
        const all = [];
        for (let i = 0; i < n; ++i)
            all.push(i);
        let base = all;
        if (q.length > 0) {
            const out = [];
            for (let i = 0; i < n; ++i) {
                const p = root.pages[i];
                const name = (p.name + "").toLowerCase();
                if (name.includes(q)) {
                    out.push(i);
                    continue;
                }
                const tags = p.searchTags;
                if (!tags)
                    continue;
                for (let j = 0; j < tags.length; j++) {
                    if ((tags[j] + "").toLowerCase().includes(q)) {
                        out.push(i);
                        break;
                    }
                }
            }
            base = out;
        }
        const allow = root.settingsCategoryAllowedPages(root.settingsNavCategoryIndex);
        if (!allow)
            return base;
        return base.filter(i => allow.includes(i));
    }

    function navCycleList() {
        const f = root.filteredPageIndices;
        if (root.navSearch.trim().length > 0 && f.length > 0)
            return f;
        const a = [];
        for (let i = 0; i < root.pages.length; ++i)
            a.push(i);
        return a;
    }

    function syncNavRailIndex() {
        const f = root.filteredPageIndices;
        let idx = f.indexOf(root.currentPage);
        if (idx >= 0) {
            root.navRailIndex = idx;
            return;
        }
        if (f.length > 0) {
            root.currentPage = f[0];
            root.navRailIndex = 0;
        } else {
            root.navRailIndex = 0;
        }
    }

    onCurrentPageChanged: syncNavRailIndex()
    onNavSearchChanged: syncNavRailIndex()
    onSettingsNavCategoryIndexChanged: syncNavRailIndex()

    visible: true
    onClosing: Qt.quit()
    title: "illogical-impulse Settings"

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Config.readWriteDelay = 0 // Settings app always only sets one var at a time so delay isn't needed
    }

    minimumWidth: Appearance.settingsWindowMinWidth
    minimumHeight: Appearance.settingsWindowMinHeight
    width: Appearance.settingsWindowPreferredWidth
    height: Appearance.settingsWindowPreferredHeight
    color: Appearance.settingsWindowRootColor

    Shortcut {
        sequences: ["Ctrl+F", "Ctrl+K"]
        context: Qt.ApplicationShortcut
        onActivated: settingsSearchField.forceActiveFocus()
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: contentPadding
        }
        spacing: 0

        Keys.onPressed: (event) => {
            if (event.modifiers === Qt.ControlModifier) {
                const list = root.navCycleList();
                if (list.length === 0) {
                    event.accepted = true;
                    return;
                }
                const pos = Math.max(0, list.indexOf(root.currentPage));
                if (event.key === Qt.Key_PageDown) {
                    root.currentPage = list[Math.min(pos + 1, list.length - 1)];
                    event.accepted = true;
                } else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = list[Math.max(pos - 1, 0)];
                    event.accepted = true;
                } else if (event.key === Qt.Key_Tab) {
                    root.currentPage = list[(pos + 1) % list.length];
                    event.accepted = true;
                } else if (event.key === Qt.Key_Backtab) {
                    root.currentPage = list[(pos - 1 + list.length) % list.length];
                    event.accepted = true;
                }
            }
        }

        Item {
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? Appearance.settingsTitleCloseButtonSize + 4 : 0
            RippleButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                buttonRadius: Appearance.rounding.full
                implicitWidth: Appearance.settingsTitleCloseButtonSize
                implicitHeight: Appearance.settingsTitleCloseButtonSize
                colBackground: CF.ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                colBackgroundHover: Appearance.colors.colLayer1Hover
                onClicked: root.close()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "close"
                    iconSize: Math.round(20 * Appearance.settingsFontScale)
                }
            }
        }

        RowLayout { // Window content with navigation rail and content pane
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: contentPadding
            Item {
                id: navRailWrapper
                Layout.fillHeight: true
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                readonly property real cardPad: root.settingsNavCardPadding
                implicitWidth: (navRail.expanded ? Appearance.settingsNavRailExpandedWidth : fab.baseSize) + 2 * cardPad
                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }

                Rectangle {
                    id: navRailCard
                    anchors.fill: parent
                    radius: Appearance.rounding.large
                    color: Appearance.colors.colLayer1
                    border.width: Math.max(1, Appearance.settingsContentPaneBorderWidth)
                    border.color: Appearance.colors.colLayer0Border
                    clip: true

                    NavigationRail {
                        id: navRail
                        anchors {
                            fill: parent
                            margins: root.settingsNavCardPadding
                        }
                        spacing: Appearance.settingsNavRailInternalSpacing
                        expanded: root.width > 900

                        NavigationRailExpandButton {
                            focus: root.visible
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            implicitHeight: Appearance.settingsSearchFieldHeight

                            ToolbarTextField {
                                id: settingsSearchField
                                Layout.fillWidth: true
                                Layout.preferredHeight: Appearance.settingsSearchFieldHeight
                                placeholderText: Translation.tr("Search")
                                Component.onCompleted: settingsSearchField.text = root.navSearch
                                onTextChanged: root.navSearch = settingsSearchField.text
                            }

                            RippleButton {
                                visible: root.navSearch.length > 0
                                implicitWidth: Math.max(32, Appearance.settingsSearchFieldHeight - 6)
                                implicitHeight: Appearance.settingsSearchFieldHeight - 6
                                buttonRadius: Appearance.rounding.full
                                colBackground: CF.ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                                colBackgroundHover: Appearance.colors.colLayer1Hover
                                onClicked: {
                                    root.navSearch = "";
                                    settingsSearchField.text = "";
                                    settingsSearchField.forceActiveFocus();
                                }
                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "close"
                                    iconSize: Math.round(18 * Appearance.settingsFontScale)
                                    color: Appearance.colors.colOnLayer1
                                }
                            }
                        }

                        StyledComboBox {
                            id: settingsCategoryCombo
                            Layout.fillWidth: true
                            buttonIcon: "filter_alt"
                            textRole: "displayName"
                            model: [
                                {
                                    displayName: Translation.tr("All sections"),
                                    value: 0
                                },
                                {
                                    displayName: Translation.tr("Shell & desktop"),
                                    value: 1
                                },
                                {
                                    displayName: Translation.tr("Look & apps"),
                                    value: 2
                                },
                                {
                                    displayName: Translation.tr("System"),
                                    value: 3
                                }
                            ]
                            currentIndex: root.settingsNavCategoryIndex
                            onActivated: index => {
                                root.settingsNavCategoryIndex = settingsCategoryCombo.model[index].value;
                            }
                        }

                    FloatingActionButton {
                        id: fab
                        baseSize: Appearance.settingsFabBaseSize
                        property bool justCopied: false
                        iconText: justCopied ? "check" : "edit"
                        buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                        expanded: navRail.expanded
                        downAction: () => {
                            Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`);
                        }
                        altAction: () => {
                            Quickshell.clipboardText = CF.FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`);
                            fab.justCopied = true;
                            revertTextTimer.restart()
                        }

                        Timer {
                            id: revertTextTimer
                            interval: 1500
                            onTriggered: {
                                fab.justCopied = false;
                            }
                        }

                        StyledToolTip {
                            text: Translation.tr("Open the shell config file\nAlternatively right-click to copy path")
                        }
                    }

                    Flickable {
                        id: navRailFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        boundsBehavior: Flickable.StopAtBounds
                        contentWidth: width
                        contentHeight: navFlickColumn.implicitHeight
                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 6
                        }

                        Column {
                            id: navFlickColumn
                            width: navRailFlick.width
                            spacing: Appearance.settingsNavTabColumnSpacing

                            NavigationRailTabArray {
                                id: navRailTabs
                                width: parent.width
                                currentIndex: root.navRailIndex
                                expanded: navRail.expanded
                                Repeater {
                                    model: root.filteredPageIndices
                                    NavigationRailButton {
                                        required property var modelData
                                        required property int index
                                        readonly property int pageIndex: modelData
                                        toggled: root.currentPage === pageIndex
                                        onPressed: {
                                            root.currentPage = pageIndex;
                                            root.navRailIndex = index;
                                        }
                                        expanded: navRail.expanded
                                        buttonIcon: root.pages[pageIndex].icon
                                        buttonIconRotation: root.pages[pageIndex].iconRotation || 0
                                        buttonText: root.pages[pageIndex].name
                                        showToggledHighlight: false
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: visible ? noMatchLabel.implicitHeight + 16 : 0
                                visible: root.navSearch.trim().length > 0 && root.filteredPageIndices.length === 0
                                StyledText {
                                    id: noMatchLabel
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    text: Translation.tr("No matches")
                                    color: Appearance.colors.colOnSurfaceVariant
                                    font.pixelSize: Appearance.font.pixelSize.small
                                }
                            }
                        }
                    }
                    }
                }
            }
            Rectangle { // Content container
                id: contentPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.settingsContentPaneColor
                border.width: Appearance.settingsContentPaneBorderWidth
                border.color: Appearance.colors.colOutlineVariant
                radius: Appearance.rounding.windowRounding - root.contentPadding
                clip: true

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    anchors.margins: 10
                    opacity: 1.0

                    active: Config.ready
                    Component.onCompleted: {
                        source = root.pages[0].component
                    }

                    Connections {
                        target: root
                        function onCurrentPageChanged() {
                            switchAnim.complete();
                            switchAnim.start();
                        }
                    }

                    SequentialAnimation {
                        id: switchAnim

                        NumberAnimation {
                            target: pageLoader
                            properties: "opacity"
                            from: 1
                            to: 0
                            duration: 100
                            easing.type: Appearance.animation.elementMoveExit.type
                            easing.bezierCurve: Appearance.animationCurves.emphasizedFirstHalf
                        }
                        ParallelAnimation {
                            PropertyAction {
                                target: pageLoader
                                property: "source"
                                value: root.pages[root.currentPage].component
                            }
                            PropertyAction {
                                target: pageLoader
                                property: "anchors.topMargin"
                                value: 20
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: pageLoader
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: 200
                                easing.type: Appearance.animation.elementMoveEnter.type
                                easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                            }
                            NumberAnimation {
                                target: pageLoader
                                properties: "anchors.topMargin"
                                to: 0
                                duration: 200
                                easing.type: Appearance.animation.elementMoveEnter.type
                                easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                            }
                        }
                    }
                }
            }
        }
    }
}
