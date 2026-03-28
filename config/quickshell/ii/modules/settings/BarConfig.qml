import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services

ContentPage {
    id: barConfigPage
    forceWidth: true

    readonly property string syncWaybarScriptPath: FileUtils.trimFileProtocol(`${Directories.config}/hypr/custom/scripts/sync-waybar.sh`)

    Timer {
        id: syncWaybarTimer
        interval: 280
        repeat: false
        onTriggered: Quickshell.execDetached(["/usr/bin/bash", barConfigPage.syncWaybarScriptPath])
    }

    ContentSection {
        icon: "bottom_app_bar"
        title: Translation.tr("Top panel backend")

        ContentSubsection {
            title: Translation.tr("Waybar")
            tooltip: Translation.tr("Uses ~/.config/waybar. Quickshell keeps wallpapers, overview, sidebars, etc. Toggle applies after save; session startup runs the same sync.")

            ConfigSwitch {
                buttonIcon: "account_balance"
                text: Translation.tr("Use Waybar instead of Quickshell bar")
                checked: Config.flagIsTrue(Config.options.bar.useWaybar)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.bar.useWaybar) !== checked) {
                        Config.options.bar.useWaybar = checked;
                        if (Config.ready)
                            syncWaybarTimer.restart();
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "notifications"
        title: Translation.tr("Notifications")

        ConfigSwitch {
            buttonIcon: "counter_2"
            text: Translation.tr("Unread indicator: show count")
            checked: Config.options.bar.indicators.notifications.showUnreadCount
            onCheckedChanged: {
                Config.options.bar.indicators.notifications.showUnreadCount = checked;
            }
        }

    }

    ContentSection {
        icon: "spoke"
        title: Translation.tr("Positioning")

        ConfigRow {
            ContentSubsection {
                title: Translation.tr("Bar position")
                Layout.fillWidth: true

                ConfigSelectionArray {
                    // bottom: false, vertical: false
                    // bottom: false, vertical: true
                    // bottom: true, vertical: false
                    // bottom: true, vertical: true

                    currentValue: (Config.options.bar.bottom ? 1 : 0) | (Config.options.bar.vertical ? 2 : 0)
                    onSelected: (newValue) => {
                        Config.options.bar.bottom = (newValue & 1) !== 0;
                        Config.options.bar.vertical = (newValue & 2) !== 0;
                    }
                    options: [{
                        "displayName": Translation.tr("Top"),
                        "icon": "arrow_upward",
                        "value": 0
                    }, {
                        "displayName": Translation.tr("Left"),
                        "icon": "arrow_back",
                        "value": 2
                    }, {
                        "displayName": Translation.tr("Bottom"),
                        "icon": "arrow_downward",
                        "value": 1
                    }, {
                        "displayName": Translation.tr("Right"),
                        "icon": "arrow_forward",
                        "value": 3
                    }]
                }

            }

            ContentSubsection {
                title: Translation.tr("Auto-hide")
                Layout.fillWidth: false

                ConfigSelectionArray {
                    currentValue: Config.options.bar.autoHide.enable
                    onSelected: (newValue) => {
                        Config.options.bar.autoHide.enable = newValue; // Update local copy
                    }
                    options: [{
                        "displayName": Translation.tr("No"),
                        "icon": "close",
                        "value": false
                    }, {
                        "displayName": Translation.tr("Yes"),
                        "icon": "check",
                        "value": true
                    }]
                }

            }

        }

        ContentSubsection {
            title: Translation.tr("Bar shape")
            tooltip: Translation.tr("How the bar meets the screen edge: curved flush with the display corners, a floating card with gap, or a flat full-width strip.")

            ConfigSelectionArray {
                currentValue: Config.options.bar.cornerStyle
                onSelected: (newValue) => {
                    Config.options.bar.cornerStyle = newValue; // Update local copy
                }
                options: [{
                    "displayName": Translation.tr("Curved flush"),
                    "icon": "line_curve",
                    "value": 0
                }, {
                    "displayName": Translation.tr("Floating card"),
                    "icon": "page_header",
                    "value": 1
                }, {
                    "displayName": Translation.tr("Flat strip"),
                    "icon": "toolbar",
                    "value": 2
                }]
            }

        }

        ContentSubsection {
            title: Translation.tr("Module groups")
            tooltip: Translation.tr("Workspaces, clock, system tray, etc. can look like separate rounded chips or one continuous bar with dividers.")

            ConfigSelectionArray {
                currentValue: Config.options.bar.borderless
                onSelected: (newValue) => {
                    Config.options.bar.borderless = newValue; // Update local copy
                }
                options: [{
                    "displayName": Translation.tr("Separate chips"),
                    "icon": "location_chip",
                    "value": false
                }, {
                    "displayName": Translation.tr("One bar (divided)"),
                    "icon": "split_scene",
                    "value": true
                }]
            }

        }

    }

    ContentSection {
        icon: "dark_mode"
        title: Translation.tr("OLED")
        subtitle: Translation.tr("Hover ⓘ beside each row for details.")

        ContentSubsection {
            title: Translation.tr("Status bar fill")
            tooltip: Translation.tr("True black behind the bar saves power on OLED. Paints the bar and matching screen-corner wedges solid black. Turns off the floating-bar drop shadow and outline where those apply. Bar shape and module layout are under Positioning above.")

            ConfigSwitch {
                buttonIcon: "rectangle"
                text: Translation.tr("True black status bar")
                checked: Config.flagIsTrue(Config.options.bar.amoledStyle)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.bar.amoledStyle) !== checked)
                        Config.options.bar.amoledStyle = checked;

                }
            }

        }

        ContentSubsection {
            title: Translation.tr("Panels in dark mode")
            tooltip: Translation.tr("Only when the shell is in dark mode: nudges layered backgrounds toward black for OLED-friendly panels. Primary, secondary, and accent colors from Matugen stay the same.")

            ConfigSwitch {
                buttonIcon: "layers"
                text: Translation.tr("Darker panel & popup backgrounds")
                checked: Config.flagIsTrue(Config.options.appearance.amoledDeepSurfaces)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.appearance.amoledDeepSurfaces) !== checked)
                        Config.options.appearance.amoledDeepSurfaces = checked;

                }
            }

        }

    }

    ContentSection {
        icon: "shelf_auto_hide"
        title: Translation.tr("Tray")

        ConfigSwitch {
            buttonIcon: "keep"
            text: Translation.tr('Make icons pinned by default')
            checked: Config.options.tray.invertPinnedItems
            onCheckedChanged: {
                Config.options.tray.invertPinnedItems = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "colors"
            text: Translation.tr('Tint icons')
            checked: Config.options.tray.monochromeIcons
            onCheckedChanged: {
                Config.options.tray.monochromeIcons = checked;
            }
        }

    }

    ContentSection {
        icon: "widgets"
        title: Translation.tr("Waybar Settings")
        visible: Config.options.bar.useWaybar === true

        ConfigRow {
            uniform: true

            ContentSubsection {
                title: Translation.tr("Waybar Config")
                tooltip: Translation.tr("Open ~/.config/waybar/config in your editor")

                RippleButtonWithIcon {
                    Layout.fillWidth: true
                    mainText: Translation.tr("Edit Config")
                    materialIcon: "edit"
                    onClicked: Quickshell.execDetached(["xdg-open", FileUtils.trimFileProtocol(`${Directories.config}/waybar/config`)])
                }
            }

            ContentSubsection {
                title: Translation.tr("Waybar Style")
                tooltip: Translation.tr("Open ~/.config/waybar/style.css in your editor")

                RippleButtonWithIcon {
                    Layout.fillWidth: true
                    mainText: Translation.tr("Edit Style")
                    materialIcon: "palette"
                    onClicked: Quickshell.execDetached(["xdg-open", FileUtils.trimFileProtocol(`${Directories.config}/waybar/style.css`)])
                }
            }
        }
    }

    ContentSection {
        icon: "widgets"
        title: Translation.tr("Utility buttons")
        visible: Config.options.bar.useWaybar !== true

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "content_cut"
                text: Translation.tr("Screen snip")
                checked: Config.options.bar.utilButtons.showScreenSnip
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showScreenSnip = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "colorize"
                text: Translation.tr("Color picker")
                checked: Config.options.bar.utilButtons.showColorPicker
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showColorPicker = checked;
                }
            }

        }

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "keyboard"
                text: Translation.tr("Keyboard toggle")
                checked: Config.options.bar.utilButtons.showKeyboardToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showKeyboardToggle = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "mic"
                text: Translation.tr("Mic toggle")
                checked: Config.options.bar.utilButtons.showMicToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showMicToggle = checked;
                }
            }

        }

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "dark_mode"
                text: Translation.tr("Dark/Light toggle")
                checked: Config.options.bar.utilButtons.showDarkModeToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showDarkModeToggle = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "speed"
                text: Translation.tr("Performance Profile toggle")
                checked: Config.options.bar.utilButtons.showPerformanceProfileToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showPerformanceProfileToggle = checked;
                }
            }

        }

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "videocam"
                text: Translation.tr("Record")
                checked: Config.options.bar.utilButtons.showScreenRecord
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showScreenRecord = checked;
                }
            }

        }

    }

    ContentSection {
        icon: "cloud"
        title: Translation.tr("Weather")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.bar.weather.enable
            onCheckedChanged: {
                Config.options.bar.weather.enable = checked;
            }
        }

    }

    ContentSection {
        icon: "workspaces"
        title: Translation.tr("Workspaces")

        ConfigSwitch {
            buttonIcon: "award_star"
            text: Translation.tr('Show app icons')
            checked: Config.options.bar.workspaces.showAppIcons
            onCheckedChanged: {
                Config.options.bar.workspaces.showAppIcons = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "colors"
            text: Translation.tr('Tint app icons')
            checked: Config.options.bar.workspaces.monochromeIcons
            onCheckedChanged: {
                Config.options.bar.workspaces.monochromeIcons = checked;
            }
        }

        ConfigSpinBox {
            icon: "view_column"
            text: Translation.tr("Workspaces shown")
            value: Config.options.bar.workspaces.shown
            from: 1
            to: 30
            stepSize: 1
            onValueChanged: {
                Config.options.bar.workspaces.shown = value;
            }
        }

    }

    ContentSection {
        icon: "tooltip"
        title: Translation.tr("Tooltips")

        ConfigSwitch {
            buttonIcon: "ads_click"
            text: Translation.tr("Click to show")
            checked: Config.options.bar.tooltips.clickToShow
            onCheckedChanged: {
                Config.options.bar.tooltips.clickToShow = checked;
            }
        }

    }

}
