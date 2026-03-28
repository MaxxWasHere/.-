import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "display_settings"
        title: Translation.tr("This settings window")
        subtitle: Translation.tr("Looks and layout of this app only — not the bar, dock, or shell.")
        Layout.fillWidth: true

        ContentSubsection {
            title: Translation.tr("UI preset")
            tooltip: Translation.tr("Each preset changes typography, weight, spacing, corner radii, nav rail, transparency, and pane colors. Window size stays the same. Only this process is affected.\nRestart the app if a preset seems to do nothing.")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.windows.settingsUi ? (Config.options.windows.settingsUi.preset || "default") : "default"
                onSelected: newValue => {
                    Config.setNestedValue("windows.settingsUi.preset", newValue);
                }
                options: [
                    { value: "default", displayName: Translation.tr("Default"), icon: "tune" },
                    { value: "material", displayName: Translation.tr("Material"), icon: "palette" },
                    { value: "mono", displayName: Translation.tr("Mono"), icon: "code" },
                    { value: "cli", displayName: Translation.tr("CLI"), icon: "terminal" },
                    { value: "hyprland", displayName: Translation.tr("Hyprland"), icon: "grid_view" },
                    { value: "soft", displayName: Translation.tr("Soft"), icon: "blur_on" },
                    { value: "glass", displayName: Translation.tr("Glass"), icon: "water_drop" },
                    { value: "amoled", displayName: Translation.tr("AMOLED"), icon: "contrast" }
                ]
            }
        }
    }

    Process {
        id: randomWallProc
        property string status: ""
        property string scriptPath: `${Directories.scriptPath}/colors/random/random_konachan_wall.sh`
        command: ["bash", "-c", FileUtils.trimFileProtocol(randomWallProc.scriptPath)]
        stdout: SplitParser {
            onRead: data => {
                randomWallProc.status = data.trim();
            }
        }
    }

    component SmallLightDarkPreferenceButton: RippleButton {
        id: smallLightDarkPreferenceButton
        required property bool dark
        property color colText: toggled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer2
        topPadding: 10
        bottomPadding: 10
        leftPadding: 8
        rightPadding: 8
        Layout.fillWidth: true
        implicitHeight: Math.max(56, ldColumn.implicitHeight + topPadding + bottomPadding)
        toggled: Appearance.m3colors.darkmode === dark
        colBackground: Appearance.colors.colLayer2
        onClicked: {
            Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --mode ${dark ? "dark" : "light"} --noswitch`]);
        }
        contentItem: ColumnLayout {
            id: ldColumn
            spacing: 4
            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                iconSize: 28
                text: dark ? "dark_mode" : "light_mode"
                color: smallLightDarkPreferenceButton.colText
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: dark ? Translation.tr("Dark") : Translation.tr("Light")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: smallLightDarkPreferenceButton.colText
            }
        }
    }

    ContentSection {
        icon: "format_paint"
        title: Translation.tr("Wallpaper & colors")
        subtitle: Translation.tr("Preview, Matugen palette, light/dark wallpaper, and quick transparency.")
        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Item {
                    id: wallpaperPreviewBox
                    Layout.preferredWidth: 288
                    Layout.preferredHeight: 162
                    Layout.alignment: Qt.AlignTop

                    readonly property bool pathValid: {
                        const p = Config.options.background.wallpaperPath;
                        return typeof p === "string" && p.trim().length > 0;
                    }

                    Rectangle {
                        id: wallpaperPreviewFrame
                        anchors.fill: parent
                        radius: Appearance.rounding.normal
                        color: Appearance.colors.colLayer1
                        border.width: Math.max(1, Appearance.settingsContentPaneBorderWidth)
                        border.color: Appearance.colors.colOutlineVariant
                    }

                    StyledRectangularShadow {
                        z: -1
                        target: wallpaperPreviewFrame
                    }

                    StyledImage {
                        id: wallpaperPreview
                        anchors.fill: parent
                        anchors.margins: 3
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        source: Config.options.background.wallpaperPath
                        cache: false
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: wallpaperPreview.width
                                height: wallpaperPreview.height
                                radius: Math.max(2, wallpaperPreviewFrame.radius - 2)
                            }
                        }
                    }

                    StyledText {
                        z: 1
                        anchors.centerIn: parent
                        width: parent.width - 24
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: !wallpaperPreviewBox.pathValid || (wallpaperPreviewBox.pathValid && wallpaperPreview.status === Image.Error)
                        text: wallpaperPreview.status === Image.Error ? Translation.tr("Could not load image") : Translation.tr("No wallpaper path set")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colSubtext
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 8

                    ContentSubsection {
                        title: Translation.tr("Wallpaper actions")
                        tooltip: Translation.tr("Random sources depend on policy “weeb”. Browse opens the grid or system picker.")

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            visible: Config.options.policies.weeb === 1

                            StyledComboBox {
                                id: randomWallSourceCombo
                                Layout.fillWidth: true
                                buttonIcon: "shuffle"
                                textRole: "displayName"
                                model: [
                                    {
                                        displayName: Translation.tr("Random: Konachan (SFW)"),
                                        script: "random_konachan_wall.sh",
                                        tip: Translation.tr("Random SFW anime art from Konachan; saved under ~/Pictures/Wallpapers")
                                    },
                                    {
                                        displayName: Translation.tr("Random: osu! seasonal"),
                                        script: "random_osu_wall.sh",
                                        tip: Translation.tr("Random osu! seasonal background; saved under ~/Pictures/Wallpapers")
                                    }
                                ]
                                currentIndex: 0
                                StyledToolTip {
                                    text: {
                                        const m = randomWallSourceCombo.model;
                                        const i = randomWallSourceCombo.currentIndex;
                                        if (m && i >= 0 && i < m.length && m[i].tip)
                                            return m[i].tip;
                                        return "";
                                    }
                                }
                            }
                            RippleButtonWithIcon {
                                enabled: !randomWallProc.running
                                Layout.preferredWidth: 112
                                implicitHeight: 40
                                buttonRadius: Appearance.rounding.small
                                materialIcon: "casino"
                                mainText: randomWallProc.running ? Translation.tr("…") : Translation.tr("Go")
                                onClicked: {
                                    const row = randomWallSourceCombo.model[randomWallSourceCombo.currentIndex];
                                    randomWallProc.scriptPath = `${Directories.scriptPath}/colors/random/${row.script}`;
                                    randomWallProc.running = true;
                                }
                                StyledToolTip {
                                    text: Translation.tr("Run the random wallpaper script selected in the dropdown")
                                }
                            }
                        }

                        RippleButtonWithIcon {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            materialIcon: "wallpaper"
                            mainText: Translation.tr("Browse wallpapers")
                            StyledToolTip {
                                text: Translation.tr("Open the wallpaper grid (same as the launcher)")
                            }
                            onClicked: {
                                if (Config.options.wallpaperSelector.useSystemFileDialog) {
                                    Wallpapers.openFallbackPicker(Appearance.m3colors.darkmode);
                                } else {
                                    GlobalStates.wallpaperSelectorOpen = true;
                                }
                            }
                        }
                    }

                    ContentSubsection {
                        title: Translation.tr("Wallpaper light / dark")
                        tooltip: Translation.tr("Runs your wallpaper script in light or dark mode (--noswitch). Does not change the global shell theme by itself.")

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            uniformCellSizes: true

                            SmallLightDarkPreferenceButton {
                                dark: false
                            }
                            SmallLightDarkPreferenceButton {
                                dark: true
                            }
                        }
                    }
                }
            }

            ContentSubsection {
                title: Translation.tr("Matugen color scheme")
                tooltip: Translation.tr("Drives accent colors from the wallpaper. Re-apply with your wallpaper script after changing scheme. Same list as Customize → Theme & color.")

                ConfigSelectionArray {
                    Layout.fillWidth: true
                    currentValue: Config.options.appearance.palette.type
                    onSelected: newValue => {
                        Config.options.appearance.palette.type = newValue;
                        Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`]);
                    }
                    options: [
                        { value: "auto", displayName: Translation.tr("Auto"), icon: "auto_awesome" },
                        { value: "scheme-content", displayName: Translation.tr("Content"), icon: "article" },
                        { value: "scheme-expressive", displayName: Translation.tr("Expressive"), icon: "emoji_people" },
                        { value: "scheme-fidelity", displayName: Translation.tr("Fidelity"), icon: "high_quality" },
                        { value: "scheme-fruit-salad", displayName: Translation.tr("Fruit salad"), icon: "nutrition" },
                        { value: "scheme-monochrome", displayName: Translation.tr("Monochrome"), icon: "contrast" },
                        { value: "scheme-neutral", displayName: Translation.tr("Neutral"), icon: "tonality" },
                        { value: "scheme-rainbow", displayName: Translation.tr("Rainbow"), icon: "looks" },
                        { value: "scheme-tonal-spot", displayName: Translation.tr("Tonal spot"), icon: "blur_on" },
                        { value: "scheme-vibrant", displayName: Translation.tr("Vibrant"), icon: "flare" }
                    ]
                }
            }

            ContentSubsection {
                title: Translation.tr("Transparent shell")
                tooltip: Translation.tr("Quick toggle for frosted / transparent surfaces. Fine-grained sliders live under Customize → Theme & color.")

                ConfigSwitch {
                    buttonIcon: "ev_shadow"
                    text: Translation.tr("Enable transparency")
                    checked: Config.options.appearance.transparency.enable
                    onCheckedChanged: {
                        Config.options.appearance.transparency.enable = checked;
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "screenshot_monitor"
        title: Translation.tr("Bar & screen")
        subtitle: Translation.tr("Quick shortcuts; full bar options are under the Bar tab.")

        ConfigRow {
            ContentSubsection {
                title: Translation.tr("Bar position")
                ConfigSelectionArray {
                    currentValue: (Config.options.bar.bottom ? 1 : 0) | (Config.options.bar.vertical ? 2 : 0)
                    onSelected: newValue => {
                        Config.options.bar.bottom = (newValue & 1) !== 0;
                        Config.options.bar.vertical = (newValue & 2) !== 0;
                    }
                    options: [
                        {
                            displayName: Translation.tr("Top"),
                            icon: "arrow_upward",
                            value: 0 // bottom: false, vertical: false
                        },
                        {
                            displayName: Translation.tr("Left"),
                            icon: "arrow_back",
                            value: 2 // bottom: false, vertical: true
                        },
                        {
                            displayName: Translation.tr("Bottom"),
                            icon: "arrow_downward",
                            value: 1 // bottom: true, vertical: false
                        },
                        {
                            displayName: Translation.tr("Right"),
                            icon: "arrow_forward",
                            value: 3 // bottom: true, vertical: true
                        }
                    ]
                }
            }
            ContentSubsection {
                title: Translation.tr("Bar style")

                ConfigSelectionArray {
                    currentValue: Config.options.bar.cornerStyle
                    onSelected: newValue => {
                        Config.options.bar.cornerStyle = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: Translation.tr("Hug"),
                            icon: "line_curve",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Float"),
                            icon: "page_header",
                            value: 1
                        },
                        {
                            displayName: Translation.tr("Rect"),
                            icon: "toolbar",
                            value: 2
                        }
                    ]
                }
            }
        }

        ConfigRow {
            ContentSubsection {
                title: Translation.tr("Screen round corner")

                ConfigSelectionArray {
                    currentValue: Config.options.appearance.fakeScreenRounding
                    onSelected: newValue => {
                        Config.options.appearance.fakeScreenRounding = newValue;
                    }
                    options: [
                        {
                            displayName: Translation.tr("No"),
                            icon: "close",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Yes"),
                            icon: "check",
                            value: 1
                        },
                        {
                            displayName: Translation.tr("When not fullscreen"),
                            icon: "fullscreen_exit",
                            value: 2
                        }
                    ]
                }
            }
            
        }
    }

    NoticeBox {
        Layout.fillWidth: true
        text: Translation.tr('Not all options are available in this app. You should also check the config file by hitting the "Config file" button on the topleft corner or opening %1 manually.').arg(Directories.shellConfigPath)

        Item {
            Layout.fillWidth: true
        }
        RippleButtonWithIcon {
            id: copyPathButton
            property bool justCopied: false
            Layout.fillWidth: false
            buttonRadius: Appearance.rounding.small
            materialIcon: justCopied ? "check" : "content_copy"
            mainText: justCopied ? Translation.tr("Path copied") : Translation.tr("Copy path")
            onClicked: {
                copyPathButton.justCopied = true
                Quickshell.clipboardText = FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`);
                revertTextTimer.restart();
            }
            colBackground: ColorUtils.transparentize(Appearance.colors.colPrimaryContainer)
            colBackgroundHover: Appearance.colors.colPrimaryContainerHover
            colRipple: Appearance.colors.colPrimaryContainerActive

            Timer {
                id: revertTextTimer
                interval: 1500
                onTriggered: {
                    copyPathButton.justCopied = false
                }
            }
        }
    }
}
