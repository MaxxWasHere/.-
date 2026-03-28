import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("Cheat sheet")

        ContentSubsection {
            title: Translation.tr("Super key symbol")
            tooltip: Translation.tr("You can also manually edit cheatsheet.superKey")
            ConfigSelectionArray {
                currentValue: Config.options.cheatsheet.superKey
                onSelected: newValue => {
                    Config.options.cheatsheet.superKey = newValue;
                }
                // Use a nerdfont to see the icons
                options: ([
                  "󰖳", "", "󰨡", "", "󰌽", "󰣇", "", "", "", 
                  "", "", "󱄛", "", "", "", "⌘", "󰀲", "󰟍", ""
                ]).map(icon => { return {
                  displayName: icon,
                  value: icon
                  }
                })
            }
        }

        ConfigSwitch {
            buttonIcon: "󰘵"
            text: Translation.tr("Use macOS-like symbols for mods keys")
            checked: Config.options.cheatsheet.useMacSymbol
            onCheckedChanged: {
                Config.options.cheatsheet.useMacSymbol = checked;
            }
            StyledToolTip {
                text: Translation.tr("e.g. 󰘴  for Ctrl, 󰘵  for Alt, 󰘶  for Shift, etc")
            }
        }

        ConfigSwitch {
            buttonIcon: "󱊶"
            text: Translation.tr("Use symbols for function keys")
            checked: Config.options.cheatsheet.useFnSymbol
            onCheckedChanged: {
                Config.options.cheatsheet.useFnSymbol = checked;
            }
            StyledToolTip {
              text: Translation.tr("e.g. 󱊫 for F1, 󱊶  for F12")
            }
        }
        ConfigSwitch {
            buttonIcon: "󰍽"
            text: Translation.tr("Use symbols for mouse")
            checked: Config.options.cheatsheet.useMouseSymbol
            onCheckedChanged: {
                Config.options.cheatsheet.useMouseSymbol = checked;
            }
            StyledToolTip {
              text: Translation.tr("Replace 󱕐   for \"Scroll ↓\", 󱕑   \"Scroll ↑\", L󰍽   \"LMB\", R󰍽   \"RMB\", 󱕒   \"Scroll ↑/↓\" and ⇞/⇟ for \"Page_↑/↓\"")
            }
        }
        ConfigSwitch {
            buttonIcon: "highlight_keyboard_focus"
            text: Translation.tr("Split buttons")
            checked: Config.options.cheatsheet.splitButtons
            onCheckedChanged: {
                Config.options.cheatsheet.splitButtons = checked;
            }
            StyledToolTip {
                text: Translation.tr("Display modifiers and keys in multiple keycap (e.g., \"Ctrl + A\" instead of \"Ctrl A\" or \"󰘴 + A\" instead of \"󰘴 A\")")
            }

        }

        ConfigSpinBox {
            text: Translation.tr("Keybind font size")
            value: Config.options.cheatsheet.fontSize.key
            from: 8
            to: 30
            stepSize: 1
            onValueChanged: {
                Config.options.cheatsheet.fontSize.key = value;
            }
        }
        ConfigSpinBox {
            text: Translation.tr("Description font size")
            value: Config.options.cheatsheet.fontSize.comment
            from: 8
            to: 30
            stepSize: 1
            onValueChanged: {
                Config.options.cheatsheet.fontSize.comment = value;
            }
        }
    }
    ContentSection {
        icon: "call_to_action"
        title: Translation.tr("Dock")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.dock.enable
            onCheckedChanged: {
                Config.options.dock.enable = checked;
            }
        }

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "highlight_mouse_cursor"
                text: Translation.tr("Hover to reveal")
                checked: Config.options.dock.hoverToReveal
                onCheckedChanged: {
                    Config.options.dock.hoverToReveal = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "keep"
                text: Translation.tr("Pinned on startup")
                checked: Config.options.dock.pinnedOnStartup
                onCheckedChanged: {
                    Config.options.dock.pinnedOnStartup = checked;
                }
            }
        }
        ConfigSwitch {
            buttonIcon: "colors"
            text: Translation.tr("Tint app icons")
            checked: Config.options.dock.monochromeIcons
            onCheckedChanged: {
                Config.options.dock.monochromeIcons = checked;
            }
        }
    }

    ContentSection {
        icon: "lock"
        title: Translation.tr("Lock screen")

        ConfigSwitch {
            buttonIcon: "water_drop"
            text: Translation.tr('Use Hyprlock (instead of Quickshell)')
            checked: Config.options.lock.useHyprlock
            onCheckedChanged: {
                Config.options.lock.useHyprlock = checked;
            }
            StyledToolTip {
                text: Translation.tr("If you want to somehow use fingerprint unlock...")
            }
        }

        ConfigSwitch {
            buttonIcon: "account_circle"
            text: Translation.tr('Launch on startup')
            checked: Config.options.lock.launchOnStartup
            onCheckedChanged: {
                Config.options.lock.launchOnStartup = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Security")

            ConfigSwitch {
                buttonIcon: "settings_power"
                text: Translation.tr('Require password to power off/restart')
                checked: Config.options.lock.security.requirePasswordToPower
                onCheckedChanged: {
                    Config.options.lock.security.requirePasswordToPower = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Remember that on most devices one can always hold the power button to force shutdown\nThis only makes it a tiny bit harder for accidents to happen")
                }
            }

            ConfigSwitch {
                buttonIcon: "key_vertical"
                text: Translation.tr('Also unlock keyring')
                checked: Config.options.lock.security.unlockKeyring
                onCheckedChanged: {
                    Config.options.lock.security.unlockKeyring = checked;
                }
                StyledToolTip {
                    text: Translation.tr("This is usually safe and needed for your browser and AI sidebar anyway\nMostly useful for those who use lock on startup instead of a display manager that does it (GDM, SDDM, etc.)")
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Style: general")

            ConfigSwitch {
                buttonIcon: "center_focus_weak"
                text: Translation.tr('Center clock')
                checked: Config.options.lock.centerClock
                onCheckedChanged: {
                    Config.options.lock.centerClock = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "info"
                text: Translation.tr('Show "Locked" text')
                checked: Config.options.lock.showLockedText
                onCheckedChanged: {
                    Config.options.lock.showLockedText = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "shapes"
                text: Translation.tr('Use varying shapes for password characters')
                checked: Config.options.lock.materialShapeChars
                onCheckedChanged: {
                    Config.options.lock.materialShapeChars = checked;
                }
            }
        }
        ContentSubsection {
            title: Translation.tr("Style: Blurred")

            ConfigSwitch {
                buttonIcon: "blur_on"
                text: Translation.tr('Enable blur')
                checked: Config.options.lock.blur.enable
                onCheckedChanged: {
                    Config.options.lock.blur.enable = checked;
                }
            }

            ConfigSpinBox {
                icon: "loupe"
                text: Translation.tr("Extra wallpaper zoom (%)")
                value: Config.options.lock.blur.extraZoom * 100
                from: 1
                to: 150
                stepSize: 2
                onValueChanged: {
                    Config.options.lock.blur.extraZoom = value / 100;
                }
            }
        }
    }

    ContentSection {
        icon: "notifications"
        title: Translation.tr("Notifications")

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Timeout duration (if not defined by notification) (ms)")
            value: Config.options.notifications.timeout
            from: 1000
            to: 60000
            stepSize: 1000
            onValueChanged: {
                Config.options.notifications.timeout = value;
            }
        }
    }

    ContentSection {
        icon: "select_window"
        title: Translation.tr("Overlay: General")

        ConfigSwitch {
            buttonIcon: "high_density"
            text: Translation.tr("Enable opening zoom animation")
            checked: Config.options.overlay.openingZoomAnimation
            onCheckedChanged: {
                Config.options.overlay.openingZoomAnimation = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "texture"
            text: Translation.tr("Darken screen")
            checked: Config.options.overlay.darkenScreen
            onCheckedChanged: {
                Config.options.overlay.darkenScreen = checked;
            }
        }
    }

    ContentSection {
        icon: "point_scan"
        title: Translation.tr("Overlay: Crosshair")

        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Crosshair code (in Valorant's format)")
            text: Config.options.crosshair.code
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.crosshair.code = text;
            }
        }

        RowLayout {
            StyledText {
                Layout.leftMargin: 10
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smallie
                text: Translation.tr("Press Super+G to open the overlay and pin the crosshair")
            }
            Item {
                Layout.fillWidth: true
            }
            RippleButtonWithIcon {
                id: editorButton
                buttonRadius: Appearance.rounding.full
                materialIcon: "open_in_new"
                mainText: Translation.tr("Open editor")
                onClicked: {
                    Qt.openUrlExternally(`https://www.vcrdb.net/builder?c=${Config.options.crosshair.code}`);
                }
                StyledToolTip {
                    text: "www.vcrdb.net"
                }
            }
        }
    }

    ContentSection {
        icon: "point_scan"
        title: Translation.tr("Overlay: Floating Image")

        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Image source")
            text: Config.options.overlay.floatingImage.imageSource
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.overlay.floatingImage.imageSource = text;
            }
        }
    }

    ContentSection {
        icon: "screenshot_frame_2"
        title: Translation.tr("Region selector (screen snipping/Google Lens)")

        ContentSubsection {
            title: Translation.tr("Hint target regions")
            ConfigRow {
                ConfigSwitch {
                    buttonIcon: "select_window"
                    text: Translation.tr('Windows')
                    checked: Config.options.regionSelector.targetRegions.windows
                    onCheckedChanged: {
                        Config.options.regionSelector.targetRegions.windows = checked;
                    }
                }
                ConfigSwitch {
                    buttonIcon: "right_panel_open"
                    text: Translation.tr('Layers')
                    checked: Config.options.regionSelector.targetRegions.layers
                    onCheckedChanged: {
                        Config.options.regionSelector.targetRegions.layers = checked;
                    }
                }
                ConfigSwitch {
                    buttonIcon: "nearby"
                    text: Translation.tr('Content')
                    checked: Config.options.regionSelector.targetRegions.content
                    onCheckedChanged: {
                        Config.options.regionSelector.targetRegions.content = checked;
                    }
                    StyledToolTip {
                        text: Translation.tr("Could be images or parts of the screen that have some containment.\nMight not always be accurate.\nThis is done with an image processing algorithm run locally and no AI is used.")
                    }
                }
            }
        }
        
        ContentSubsection {
            title: Translation.tr("Google Lens")
            
            ConfigSelectionArray {
                currentValue: Config.options.search.imageSearch.useCircleSelection ? "circle" : "rectangles"
                onSelected: newValue => {
                    Config.options.search.imageSearch.useCircleSelection = (newValue === "circle");
                }
                options: [
                    { icon: "activity_zone", value: "rectangles", displayName: Translation.tr("Rectangular selection") },
                    { icon: "gesture", value: "circle", displayName: Translation.tr("Circle to Search") }
                ]
            }
        }

        ContentSubsection {
            title: Translation.tr("Rectangular selection")

            ConfigSwitch {
                buttonIcon: "point_scan"
                text: Translation.tr("Show aim lines")
                checked: Config.options.regionSelector.rect.showAimLines
                onCheckedChanged: {
                    Config.options.regionSelector.rect.showAimLines = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "gesture_select"
                text: Translation.tr("Smooth rectangle selection")
                checked: Config.options.regionSelector.rect.smoothSelection
                onCheckedChanged: {
                    Config.options.regionSelector.rect.smoothSelection = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Spring-smoothed selection box while dragging (rectangular mode).")
                }
            }
            ConfigSpinBox {
                visible: Config.options.regionSelector.rect.smoothSelection
                icon: "schedule"
                text: Translation.tr("Smooth update interval (ms)")
                value: Config.options.regionSelector.rect.smoothSelectionIntervalMs
                from: 4
                to: 32
                stepSize: 1
                onValueChanged: {
                    Config.options.regionSelector.rect.smoothSelectionIntervalMs = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Circle selection")
            
            ConfigSpinBox {
                icon: "eraser_size_3"
                text: Translation.tr("Stroke width")
                value: Config.options.regionSelector.circle.strokeWidth
                from: 1
                to: 20
                stepSize: 1
                onValueChanged: {
                    Config.options.regionSelector.circle.strokeWidth = value;
                }
            }

            ConfigSpinBox {
                icon: "screenshot_frame_2"
                text: Translation.tr("Padding")
                value: Config.options.regionSelector.circle.padding
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.regionSelector.circle.padding = value;
                }
            }
        }
    }

    ContentSection {
        icon: "side_navigation"
        title: Translation.tr("Sidebars")

        ConfigSwitch {
            buttonIcon: "memory"
            text: Translation.tr('Keep right sidebar loaded')
            checked: Config.options.sidebar.keepRightSidebarLoaded
            onCheckedChanged: {
                Config.options.sidebar.keepRightSidebarLoaded = checked;
            }
            StyledToolTip {
                text: Translation.tr("When enabled keeps the content of the right sidebar loaded to reduce the delay when opening,\nat the cost of around 15MB of consistent RAM usage. Delay significance depends on your system's performance.\nUsing a custom kernel like linux-cachyos might help")
            }
        }

        ContentSubsection {
            title: Translation.tr("Control center look")
            tooltip: Translation.tr("Applies to the right sidebar (notifications, sliders, calendar block). Pair with Quick toggles → Android for pill tiles.")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.sidebar.panelStyle
                onSelected: newValue => {
                    Config.options.sidebar.panelStyle = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("Standard"),
                        icon: "dashboard",
                        value: "standard"
                    },
                    {
                        displayName: Translation.tr("Material (clean)"),
                        icon: "palette",
                        value: "material"
                    }
                ]
            }
        }

        ConfigSwitch {
            buttonIcon: "translate"
            text: Translation.tr('Enable translator')
            checked: Config.options.sidebar.translator.enable
            onCheckedChanged: {
                Config.options.sidebar.translator.enable = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Quick toggles")
            
            ConfigSelectionArray {
                Layout.fillWidth: false
                currentValue: Config.options.sidebar.quickToggles.style
                onSelected: newValue => {
                    Config.options.sidebar.quickToggles.style = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("Classic"),
                        icon: "password_2",
                        value: "classic"
                    },
                    {
                        displayName: Translation.tr("Android"),
                        icon: "action_key",
                        value: "android"
                    }
                ]
            }

            ConfigSpinBox {
                enabled: Config.options.sidebar.quickToggles.style === "android"
                icon: "splitscreen_left"
                text: Translation.tr("Columns")
                value: Config.options.sidebar.quickToggles.android.columns
                from: 1
                to: 8
                stepSize: 1
                onValueChanged: {
                    Config.options.sidebar.quickToggles.android.columns = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Sliders")

            ConfigSwitch {
                buttonIcon: "check"
                text: Translation.tr("Enable")
                checked: Config.options.sidebar.quickSliders.enable
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.enable = checked;
                }
            }
            
            ConfigSwitch {
                buttonIcon: "brightness_6"
                text: Translation.tr("Brightness")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showBrightness
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showBrightness = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "volume_up"
                text: Translation.tr("Volume")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showVolume
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showVolume = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "mic"
                text: Translation.tr("Microphone")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showMic
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showMic = checked;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Corner open")
            tooltip: Translation.tr("Allows you to open sidebars by clicking or hovering screen corners regardless of bar position")
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "check"
                    text: Translation.tr("Enable")
                    checked: Config.options.sidebar.cornerOpen.enable
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.enable = checked;
                    }
                }
            }
            ConfigSwitch {
                buttonIcon: "highlight_mouse_cursor"
                text: Translation.tr("Hover to trigger")
                checked: Config.options.sidebar.cornerOpen.clickless
                onCheckedChanged: {
                    Config.options.sidebar.cornerOpen.clickless = checked;
                }

                StyledToolTip {
                    text: Translation.tr("When this is off you'll have to click")
                }
            }
            Row {
                ConfigSwitch {
                    enabled: !Config.options.sidebar.cornerOpen.clickless
                    text: Translation.tr("Force hover open at absolute corner")
                    checked: Config.options.sidebar.cornerOpen.clicklessCornerEnd
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.clicklessCornerEnd = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("When the previous option is off and this is on,\nyou can still hover the corner's end to open sidebar,\nand the remaining area can be used for volume/brightness scroll")
                    }
                }
                ConfigSpinBox {
                    icon: "arrow_cool_down"
                    text: Translation.tr("with vertical offset")
                    value: Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset
                    from: 0
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset = value;
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        StyledToolTip {
                            extraVisibleCondition: mouseArea.containsMouse
                            text: Translation.tr("Why this is cool:\nFor non-0 values, it won't trigger when you reach the\nscreen corner along the horizontal edge, but it will when\nyou do along the vertical edge")
                        }
                    }
                }
            }
            
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "vertical_align_bottom"
                    text: Translation.tr("Place at bottom")
                    checked: Config.options.sidebar.cornerOpen.bottom
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.bottom = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("Place the corners to trigger at the bottom")
                    }
                }
                ConfigSwitch {
                    buttonIcon: "unfold_more_double"
                    text: Translation.tr("Value scroll")
                    checked: Config.options.sidebar.cornerOpen.valueScroll
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.valueScroll = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("Brightness and volume")
                    }
                }
            }
            ConfigSwitch {
                buttonIcon: "visibility"
                text: Translation.tr("Visualize region")
                checked: Config.options.sidebar.cornerOpen.visualize
                onCheckedChanged: {
                    Config.options.sidebar.cornerOpen.visualize = checked;
                }
            }
            ConfigRow {
                ConfigSpinBox {
                    icon: "arrow_range"
                    text: Translation.tr("Region width")
                    value: Config.options.sidebar.cornerOpen.cornerRegionWidth
                    from: 1
                    to: 300
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.cornerRegionWidth = value;
                    }
                }
                ConfigSpinBox {
                    icon: "height"
                    text: Translation.tr("Region height")
                    value: Config.options.sidebar.cornerOpen.cornerRegionHeight
                    from: 1
                    to: 300
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.cornerRegionHeight = value;
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "voting_chip"
        title: Translation.tr("On-screen display")

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Timeout (ms)")
            value: Config.options.osd.timeout
            from: 100
            to: 3000
            stepSize: 100
            onValueChanged: {
                Config.options.osd.timeout = value;
            }
        }
    }

    ContentSection {
        icon: "overview_key"
        title: Translation.tr("Overview")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.overview.enable
            onCheckedChanged: {
                Config.options.overview.enable = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "center_focus_strong"
            text: Translation.tr("Center icons")
            checked: Config.options.overview.centerIcons
            onCheckedChanged: {
                Config.options.overview.centerIcons = checked;
            }
        }
        ConfigSpinBox {
            icon: "loupe"
            text: Translation.tr("Scale (%)")
            value: Config.options.overview.scale * 100
            from: 1
            to: 100
            stepSize: 1
            onValueChanged: {
                Config.options.overview.scale = value / 100;
            }
        }
        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "splitscreen_bottom"
                text: Translation.tr("Rows")
                value: Config.options.overview.rows
                from: 1
                to: 20
                stepSize: 1
                onValueChanged: {
                    Config.options.overview.rows = value;
                }
            }
            ConfigSpinBox {
                icon: "splitscreen_right"
                text: Translation.tr("Columns")
                value: Config.options.overview.columns
                from: 1
                to: 20
                stepSize: 1
                onValueChanged: {
                    Config.options.overview.columns = value;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSelectionArray {
                currentValue: Config.options.overview.orderRightLeft
                onSelected: newValue => {
                    Config.options.overview.orderRightLeft = newValue
                }
                options: [
                    {
                        displayName: Translation.tr("Left to right"),
                        icon: "arrow_forward",
                        value: 0
                    },
                    {
                        displayName: Translation.tr("Right to left"),
                        icon: "arrow_back",
                        value: 1
                    }
                ]
            }
            ConfigSelectionArray {
                currentValue: Config.options.overview.orderBottomUp
                onSelected: newValue => {
                    Config.options.overview.orderBottomUp = newValue
                }
                options: [
                    {
                        displayName: Translation.tr("Top-down"),
                        icon: "arrow_downward",
                        value: 0
                    },
                    {
                        displayName: Translation.tr("Bottom-up"),
                        icon: "arrow_upward",
                        value: 1
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "wallpaper_slideshow"
        title: Translation.tr("Wallpaper selector")

        ConfigSwitch {
            buttonIcon: "ad"
            text: Translation.tr('Use system file picker')
            checked: Config.options.wallpaperSelector.useSystemFileDialog
            onCheckedChanged: {
                Config.options.wallpaperSelector.useSystemFileDialog = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Grid order")
            tooltip: Translation.tr("Each image’s dominant color is sampled (resize + palette, not a single-pixel average), then the grid sorts by hue around the color wheel. Low-saturation / gray images are grouped after vivid ones and ordered by brightness. Uncached files stay at the end until sampled in the background.")

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: Translation.tr("Order follows dominant color (hue). Tap the palette button in the wallpaper grid to re-run sampling after changing the script or cache.")
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        ContentSubsection {
            title: Translation.tr("Thumbnail layout")
            tooltip: Translation.tr("Turn on “fit without stretching” to letterbox each image (true aspect, no distortion). Column count, size, and tile shape change how large each preview is and how rows are laid out.")

            ConfigSwitch {
                buttonIcon: "aspect_ratio"
                text: Translation.tr("Fit thumbnails without stretching")
                checked: Config.options.wallpaperSelector.fitThumbnailsWithoutStretch
                onCheckedChanged: {
                    Config.options.wallpaperSelector.fitThumbnailsWithoutStretch = checked;
                }
            }

            ConfigSpinBox {
                text: Translation.tr("Grid columns")
                icon: "view_column"
                value: Config.options.wallpaperSelector.gridColumns
                from: 2
                to: 8
                stepSize: 1
                onValueChanged: {
                    Config.options.wallpaperSelector.gridColumns = value;
                }
            }

            ConfigSpinBox {
                text: Translation.tr("Thumbnail size (%)")
                icon: "photo_size_select_large"
                value: Math.round(Config.options.wallpaperSelector.thumbnailCellScale * 100)
                from: 50
                to: 200
                stepSize: 5
                onValueChanged: {
                    Config.options.wallpaperSelector.thumbnailCellScale = value / 100;
                }
            }

            ConfigSpinBox {
                text: Translation.tr("Tile shape ×100 (width ÷ height)")
                icon: "crop_16_9"
                value: Math.round(Config.options.wallpaperSelector.thumbnailCellAspectRatio * 100)
                from: 65
                to: 250
                stepSize: 5
                onValueChanged: {
                    Config.options.wallpaperSelector.thumbnailCellAspectRatio = value / 100;
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Thumbnail fade-in when grid loads")
            checked: Config.options.wallpaperSelector.gridDelegateIntroAnimation
            onCheckedChanged: {
                Config.options.wallpaperSelector.gridDelegateIntroAnimation = checked;
            }
        }

        ConfigSpinBox {
            text: Translation.tr("Fast key step (Shift/Ctrl + arrows)")
            value: Config.options.wallpaperSelector.gridKeyboardFastStepMultiplier
            from: 2
            to: 10
            stepSize: 1
            onValueChanged: {
                Config.options.wallpaperSelector.gridKeyboardFastStepMultiplier = value;
            }
        }
    }

    ContentSection {
        icon: "wallpaper"
        title: Translation.tr("Desktop wallpaper")
        subtitle: Translation.tr("Long explanations are on the ⓘ tooltips.")

        ContentSubsection {
            title: Translation.tr("Wallpaper engine")
            tooltip: Translation.tr("Quickshell draws the image by default. Choose swww for GPU transition effects; run swww-daemon at login (see hypr hyprland/execs.conf). Video wallpapers still use mpvpaper.")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.background.wallpaperDaemon
                onSelected: newValue => {
                    Config.options.background.wallpaperDaemon = newValue;
                }
                options: [
                    {
                        value: "quickshell",
                        displayName: Translation.tr("Quickshell (default)"),
                        icon: "imagesearch_roller"
                    },
                    {
                        value: "swww",
                        displayName: Translation.tr("swww transitions"),
                        icon: "animation"
                    }
                ]
            }
        }

        ContentSubsection {
            title: Translation.tr("swww effect")
            visible: Config.options.background.wallpaperDaemon === "swww"
            tooltip: Translation.tr("Transition type for swww img (see swww img --help).")

            StyledComboBox {
                buttonIcon: "animation"
                textRole: "displayName"
                model: [
                    {
                        value: "simple",
                        displayName: Translation.tr("simple"),
                        icon: "blur_on"
                    },
                    {
                        value: "fade",
                        displayName: Translation.tr("fade"),
                        icon: "gradient"
                    },
                    {
                        value: "left",
                        displayName: Translation.tr("left"),
                        icon: "arrow_back"
                    },
                    {
                        value: "right",
                        displayName: Translation.tr("right"),
                        icon: "arrow_forward"
                    },
                    {
                        value: "top",
                        displayName: Translation.tr("top"),
                        icon: "arrow_upward"
                    },
                    {
                        value: "bottom",
                        displayName: Translation.tr("bottom"),
                        icon: "arrow_downward"
                    },
                    {
                        value: "wipe",
                        displayName: Translation.tr("wipe"),
                        icon: "gesture"
                    },
                    {
                        value: "wave",
                        displayName: Translation.tr("wave"),
                        icon: "waves"
                    },
                    {
                        value: "grow",
                        displayName: Translation.tr("grow"),
                        icon: "center_focus_strong"
                    },
                    {
                        value: "center",
                        displayName: Translation.tr("center"),
                        icon: "adjust"
                    },
                    {
                        value: "outer",
                        displayName: Translation.tr("outer"),
                        icon: "circle"
                    },
                    {
                        value: "random",
                        displayName: Translation.tr("random"),
                        icon: "shuffle"
                    },
                    {
                        value: "none",
                        displayName: Translation.tr("none (instant)"),
                        icon: "block"
                    }
                ]
                currentIndex: {
                    const v = Config.options.background.swwwTransitionType;
                    const i = model.findIndex(e => e.value === v);
                    return i >= 0 ? i : 0;
                }
                onActivated: index => {
                    Config.options.background.swwwTransitionType = model[index].value;
                }
            }
        }

        ConfigSpinBox {
            visible: Config.options.background.wallpaperDaemon === "swww"
            text: Translation.tr("swww transition duration (s)")
            value: Math.round(Config.options.background.swwwTransitionDuration)
            from: 1
            to: 12
            stepSize: 1
            onValueChanged: {
                Config.options.background.swwwTransitionDuration = value;
            }
        }

        ConfigSpinBox {
            visible: Config.options.background.wallpaperDaemon === "swww"
            text: Translation.tr("swww transition FPS")
            value: Config.options.background.swwwTransitionFps
            from: 24
            to: 144
            stepSize: 6
            onValueChanged: {
                Config.options.background.swwwTransitionFps = value;
            }
        }

        ContentSubsection {
            title: Translation.tr("swww scale filter")
            visible: Config.options.background.wallpaperDaemon === "swww"
            tooltip: Translation.tr("Scaling filter passed to swww.")

            StyledComboBox {
                buttonIcon: "high_quality"
                textRole: "displayName"
                model: [
                    {
                        value: "Nearest",
                        displayName: Translation.tr("Nearest"),
                        icon: "grid_on"
                    },
                    {
                        value: "Bilinear",
                        displayName: Translation.tr("Bilinear"),
                        icon: "texture"
                    },
                    {
                        value: "CatmullRom",
                        displayName: Translation.tr("CatmullRom"),
                        icon: "texture"
                    },
                    {
                        value: "Mitchell",
                        displayName: Translation.tr("Mitchell"),
                        icon: "texture"
                    },
                    {
                        value: "Lanczos3",
                        displayName: Translation.tr("Lanczos3"),
                        icon: "high_quality"
                    }
                ]
                currentIndex: {
                    const v = Config.options.background.swwwFilter;
                    const i = model.findIndex(e => e.value === v);
                    return i >= 0 ? i : 0;
                }
                onActivated: index => {
                    Config.options.background.swwwFilter = model[index].value;
                }
            }
        }
    }

    ContentSection {
        icon: "text_format"
        title: Translation.tr("Fonts")
        subtitle: Translation.tr("Use the tabs to switch groups. Hover ⓘ for what each slot affects.")

        TabBar {
            id: fontCategoryTabs
            Layout.fillWidth: true

            TabButton {
                width: implicitWidth + 12
                font.pixelSize: Appearance.font.pixelSize.small
                text: Translation.tr("Interface")
            }
            TabButton {
                width: implicitWidth + 12
                font.pixelSize: Appearance.font.pixelSize.small
                text: Translation.tr("Code & icons")
            }
            TabButton {
                width: implicitWidth + 12
                font.pixelSize: Appearance.font.pixelSize.small
                text: Translation.tr("Reading")
            }
        }

        StackLayout {
            Layout.fillWidth: true
            currentIndex: fontCategoryTabs.currentIndex

            ColumnLayout {
                spacing: 4

                ContentSubsection {
                    title: Translation.tr("Main font")
                    tooltip: Translation.tr("Used for general UI text")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name (e.g., Google Sans Flex)")
                        text: Config.options.appearance.fonts.main
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.main = text;
                        }
                    }
                }

                ContentSubsection {
                    title: Translation.tr("Numbers font")
                    tooltip: Translation.tr("Used for displaying numbers")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name")
                        text: Config.options.appearance.fonts.numbers
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.numbers = text;
                        }
                    }
                }

                ContentSubsection {
                    title: Translation.tr("Title font")
                    tooltip: Translation.tr("Used for headings and titles")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name")
                        text: Config.options.appearance.fonts.title
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.title = text;
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 4

                ContentSubsection {
                    title: Translation.tr("Monospace font")
                    tooltip: Translation.tr("Used for code and terminal")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name (e.g., JetBrains Mono NF)")
                        text: Config.options.appearance.fonts.monospace
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.monospace = text;
                        }
                    }
                }

                ContentSubsection {
                    title: Translation.tr("Nerd font icons")
                    tooltip: Translation.tr("Font used for Nerd Font icons")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name (e.g., JetBrains Mono NF)")
                        text: Config.options.appearance.fonts.iconNerd
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.iconNerd = text;
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 4

                ContentSubsection {
                    title: Translation.tr("Reading font")
                    tooltip: Translation.tr("Used for reading large blocks of text")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name (e.g., Readex Pro)")
                        text: Config.options.appearance.fonts.reading
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.reading = text;
                        }
                    }
                }

                ContentSubsection {
                    title: Translation.tr("Expressive font")
                    tooltip: Translation.tr("Used for decorative/expressive text")

                    MaterialTextArea {
                        Layout.fillWidth: true
                        placeholderText: Translation.tr("Font family name (e.g., Space Grotesk)")
                        text: Config.options.appearance.fonts.expressive
                        wrapMode: TextEdit.NoWrap
                        onTextChanged: {
                            Config.options.appearance.fonts.expressive = text;
                        }
                    }
                }
            }
        }
    }

}
