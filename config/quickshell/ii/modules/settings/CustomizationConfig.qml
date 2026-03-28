import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "palette"
        title: Translation.tr("Theme & color")
        subtitle: Translation.tr("Shell-wide look (bar, panels, …). For this settings window only, use Quick → This settings window.")

        ContentSubsection {
            title: Translation.tr("Matugen color scheme")
            tooltip: Translation.tr("Drives accent colors from the wallpaper. Re-apply with your wallpaper script after changing scheme.")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.appearance.palette.type
                onSelected: (newValue) => {
                    Config.options.appearance.palette.type = newValue;
                    Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`]);
                }
                options: [{
                    "value": "auto",
                    "displayName": Translation.tr("Auto"),
                    "icon": "auto_awesome"
                }, {
                    "value": "scheme-content",
                    "displayName": Translation.tr("Content"),
                    "icon": "article"
                }, {
                    "value": "scheme-expressive",
                    "displayName": Translation.tr("Expressive"),
                    "icon": "emoji_people"
                }, {
                    "value": "scheme-fidelity",
                    "displayName": Translation.tr("Fidelity"),
                    "icon": "high_quality"
                }, {
                    "value": "scheme-fruit-salad",
                    "displayName": Translation.tr("Fruit salad"),
                    "icon": "nutrition"
                }, {
                    "value": "scheme-monochrome",
                    "displayName": Translation.tr("Monochrome"),
                    "icon": "contrast"
                }, {
                    "value": "scheme-neutral",
                    "displayName": Translation.tr("Neutral"),
                    "icon": "tonality"
                }, {
                    "value": "scheme-rainbow",
                    "displayName": Translation.tr("Rainbow"),
                    "icon": "looks"
                }, {
                    "value": "scheme-tonal-spot",
                    "displayName": Translation.tr("Tonal spot"),
                    "icon": "blur_on"
                }, {
                    "value": "scheme-vibrant",
                    "displayName": Translation.tr("Vibrant"),
                    "icon": "flare"
                }]
            }

        }

        ContentSubsection {
            title: Translation.tr("Wallpaper light / dark")
            tooltip: Translation.tr("Runs your wallpaper script in light or dark mode (--noswitch).")

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                RippleButtonWithIcon {
                    Layout.fillWidth: true
                    materialIcon: "light_mode"
                    mainText: Translation.tr("Light mode")
                    onClicked: Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --mode light --noswitch`])
                }

                RippleButtonWithIcon {
                    Layout.fillWidth: true
                    materialIcon: "dark_mode"
                    mainText: Translation.tr("Dark mode")
                    onClicked: Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --mode dark --noswitch`])
                }

            }

        }

        ConfigSwitch {
            buttonIcon: "gradient"
            text: Translation.tr("Tint background with primary (subtle)")
            checked: Config.options.appearance.extraBackgroundTint
            onCheckedChanged: {
                Config.options.appearance.extraBackgroundTint = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "ev_shadow"
            text: Translation.tr("Transparent shell surfaces")
            checked: Config.options.appearance.transparency.enable
            onCheckedChanged: {
                Config.options.appearance.transparency.enable = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "auto_mode"
            text: Translation.tr("Auto transparency from wallpaper")
            enabled: Config.options.appearance.transparency.enable
            checked: Config.options.appearance.transparency.automatic
            onCheckedChanged: {
                Config.options.appearance.transparency.automatic = checked;
            }
        }

        ConfigSlider {
            buttonIcon: "opacity"
            text: Translation.tr("Background transparency")
            visible: Config.options.appearance.transparency.enable
            enabled: Config.options.appearance.transparency.enable && !Config.options.appearance.transparency.automatic
            value: Config.options.appearance.transparency.backgroundTransparency
            from: 0
            to: 0.35
            onValueChanged: {
                Config.options.appearance.transparency.backgroundTransparency = value;
            }
        }

        ConfigSlider {
            buttonIcon: "layers"
            text: Translation.tr("Content / layer transparency")
            visible: Config.options.appearance.transparency.enable
            enabled: Config.options.appearance.transparency.enable && !Config.options.appearance.transparency.automatic
            value: Config.options.appearance.transparency.contentTransparency
            from: 0
            to: 0.85
            onValueChanged: {
                Config.options.appearance.transparency.contentTransparency = value;
            }
        }

        ConfigSwitch {
            buttonIcon: "wallpaper"
            text: Translation.tr("Theming: apps & shell from wallpaper")
            checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell
            onCheckedChanged: {
                Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked;
            }
        }

    }

    ContentSection {
        icon: "contrast"
        title: Translation.tr("OLED & deep surfaces")

        ConfigSwitch {
            buttonIcon: "rectangle"
            text: Translation.tr("True black status bar")
            checked: Config.flagIsTrue(Config.options.bar.amoledStyle)
            onCheckedChanged: {
                if (Config.flagIsTrue(Config.options.bar.amoledStyle) !== checked)
                    Config.options.bar.amoledStyle = checked;

            }
        }

        ConfigSwitch {
            buttonIcon: "layers"
            text: Translation.tr("Darker panels in dark mode")
            checked: Config.flagIsTrue(Config.options.appearance.amoledDeepSurfaces)
            onCheckedChanged: {
                if (Config.flagIsTrue(Config.options.appearance.amoledDeepSurfaces) !== checked)
                    Config.options.appearance.amoledDeepSurfaces = checked;

            }
        }

    }

    ContentSection {
        icon: "rounded_corner"
        title: Translation.tr("Corners & screen")

        ContentSubsection {
            title: Translation.tr("Fake display rounding")
            tooltip: Translation.tr("Draws rounded corners over the desktop (Quickshell). Separate from Hyprland window rounding.")

            ConfigSelectionArray {
                currentValue: Config.options.appearance.fakeScreenRounding
                onSelected: (newValue) => {
                    Config.options.appearance.fakeScreenRounding = newValue;
                }
                options: [{
                    "displayName": Translation.tr("Off"),
                    "icon": "close",
                    "value": 0
                }, {
                    "displayName": Translation.tr("Always"),
                    "icon": "check",
                    "value": 1
                }, {
                    "displayName": Translation.tr("Hide when fullscreen"),
                    "icon": "fullscreen_exit",
                    "value": 2
                }]
            }

        }

        ConfigSwitch {
            buttonIcon: "border_clear"
            text: Translation.tr("Hyprland right-edge 1px workaround")
            checked: Config.options.interactions.deadPixelWorkaround.enable
            onCheckedChanged: {
                Config.options.interactions.deadPixelWorkaround.enable = checked;
            }

            StyledToolTip {
                text: Translation.tr("Some Hyprland builds leave a one-pixel strip; this nudges hit-testing. Reload Hyprland after changing.")
            }

        }

    }

    ContentSection {
        icon: "dock_to_bottom"
        title: Translation.tr("Bar appearance")

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Appearance.colors.colSubtext
            text: Translation.tr("Position and OLED toggles also live under Bar. Here: shape and how dense the center modules are.")
        }

        ContentSubsection {
            title: Translation.tr("Bar shape")
            tooltip: Translation.tr("How the bar meets the screen edge.")

            ConfigSelectionArray {
                currentValue: Config.options.bar.cornerStyle
                onSelected: (newValue) => {
                    Config.options.bar.cornerStyle = newValue;
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

        ConfigSwitch {
            buttonIcon: "shadow"
            text: Translation.tr("Shadow under floating bar")
            enabled: Config.options.bar.cornerStyle === 1
            checked: Config.options.bar.floatStyleShadow
            onCheckedChanged: {
                Config.options.bar.floatStyleShadow = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Module groups")
            tooltip: Translation.tr("Workspace cluster, clock, tray: separate pills vs one bar with dividers.")

            ConfigSelectionArray {
                currentValue: Config.options.bar.borderless
                onSelected: (newValue) => {
                    Config.options.bar.borderless = newValue;
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

        ConfigSwitch {
            buttonIcon: "palette"
            text: Translation.tr("Bar background fill")
            checked: Config.options.bar.showBackground
            onCheckedChanged: {
                Config.options.bar.showBackground = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "info"
            text: Translation.tr("Verbose bar (media title, extra clock, util buttons)")
            checked: Config.options.bar.verbose
            onCheckedChanged: {
                Config.options.bar.verbose = checked;
            }
        }

    }

    ContentSection {
        icon: "side_navigation"
        title: Translation.tr("Control center & shell windows")

        ContentSubsection {
            title: Translation.tr("Right sidebar look")
            tooltip: Translation.tr("Material adds rounder cards and more padding (pairs well with Android quick toggles).")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.sidebar.panelStyle
                onSelected: (newValue) => {
                    Config.options.sidebar.panelStyle = newValue;
                }
                options: [{
                    "displayName": Translation.tr("Standard"),
                    "icon": "dashboard",
                    "value": "standard"
                }, {
                    "displayName": Translation.tr("Material (clean)"),
                    "icon": "palette",
                    "value": "material"
                }]
            }

        }

        ConfigSwitch {
            buttonIcon: "title"
            text: Translation.tr("Title bar on shell windows (settings, etc.)")
            checked: Config.options.windows.showTitlebar
            onCheckedChanged: {
                Config.options.windows.showTitlebar = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "format_align_center"
            text: Translation.tr("Center window title")
            enabled: Config.options.windows.showTitlebar
            checked: Config.options.windows.centerTitle
            onCheckedChanged: {
                Config.options.windows.centerTitle = checked;
            }
        }

    }

    ContentSection {
        icon: "nest_clock_farsight_analog"
        title: Translation.tr("Desktop clock & dock")

        ConfigSwitch {
            buttonIcon: "terminal"
            text: Translation.tr("Desktop clock: CLI / monospace style")
            checked: Config.options.background.widgets.clock.cliStyle
            onCheckedChanged: {
                Config.options.background.widgets.clock.cliStyle = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "dock_to_bottom"
            text: Translation.tr("Dock enabled")
            checked: Config.options.dock.enable
            onCheckedChanged: {
                Config.options.dock.enable = checked;
            }
        }

    }

    ContentSection {
        icon: "lock"
        title: Translation.tr("Lock screen")

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Translation.tr("Blur lock background")
            checked: Config.options.lock.blur.enable
            onCheckedChanged: {
                Config.options.lock.blur.enable = checked;
            }
        }

        ConfigSpinBox {
            icon: "blur_circular"
            text: Translation.tr("Lock blur radius")
            enabled: Config.options.lock.blur.enable
            value: Config.options.lock.blur.radius
            from: 0
            to: 200
            stepSize: 5
            onValueChanged: {
                Config.options.lock.blur.radius = value;
            }
        }

    }

}
