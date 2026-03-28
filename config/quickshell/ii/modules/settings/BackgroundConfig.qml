import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "sync_alt"
        title: Translation.tr("Parallax")

        ConfigSwitch {
            buttonIcon: "unfold_more_double"
            text: Translation.tr("Vertical")
            checked: Config.options.background.parallax.vertical
            onCheckedChanged: {
                Config.options.background.parallax.vertical = checked;
            }
        }

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "counter_1"
                text: Translation.tr("Depends on workspace")
                checked: Config.options.background.parallax.enableWorkspace
                onCheckedChanged: {
                    Config.options.background.parallax.enableWorkspace = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "side_navigation"
                text: Translation.tr("Depends on sidebars")
                checked: Config.options.background.parallax.enableSidebar
                onCheckedChanged: {
                    Config.options.background.parallax.enableSidebar = checked;
                }
            }

        }

        ConfigSpinBox {
            icon: "loupe"
            text: Translation.tr("Preferred wallpaper zoom (%)")
            value: Config.options.background.parallax.workspaceZoom * 100
            from: 100
            to: 150
            stepSize: 1
            onValueChanged: {
                Config.options.background.parallax.workspaceZoom = value / 100;
            }
        }

    }

    ContentSection {
        id: settingsClock

        readonly property bool digitalPresent: stylePresent("digital")
        readonly property bool cookiePresent: stylePresent("cookie")
        readonly property bool clockCornerPlacement: {
            const p = Config.options.background.widgets.clock.placementStrategy;
            return p === "topLeft" || p === "topRight" || p === "bottomLeft" || p === "bottomRight";
        }

        function stylePresent(styleName) {
            if (!Config.options.background.widgets.clock.showOnlyWhenLocked && Config.options.background.widgets.clock.style === styleName)
                return true;

            if (Config.options.background.widgets.clock.styleLocked === styleName)
                return true;

            return false;
        }

        icon: "clock_loader_40"
        title: Translation.tr("Widget: Clock")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.background.widgets.clock.enable
            onCheckedChanged: {
                Config.options.background.widgets.clock.enable = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Placement")
            tooltip: Translation.tr("Draggable or snap the clock to a screen region. Options wrap to the next line on narrow windows.")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.background.widgets.clock.placementStrategy
                onSelected: (newValue) => {
                    Config.options.background.widgets.clock.placementStrategy = newValue;
                }
                options: [{
                    "displayName": Translation.tr("Draggable"),
                    "icon": "drag_pan",
                    "value": "free"
                }, {
                    "displayName": Translation.tr("Least busy"),
                    "icon": "category",
                    "value": "leastBusy"
                }, {
                    "displayName": Translation.tr("Most busy"),
                    "icon": "shapes",
                    "value": "mostBusy"
                }, {
                    "displayName": Translation.tr("Top left"),
                    "icon": "north_west",
                    "value": "topLeft"
                }, {
                    "displayName": Translation.tr("Top right"),
                    "icon": "north_east",
                    "value": "topRight"
                }, {
                    "displayName": Translation.tr("Bottom left"),
                    "icon": "south_west",
                    "value": "bottomLeft"
                }, {
                    "displayName": Translation.tr("Bottom right"),
                    "icon": "south_east",
                    "value": "bottomRight"
                }]
            }

        }

        ConfigSpinBox {
            visible: settingsClock.clockCornerPlacement
            icon: "margin"
            text: Translation.tr("Corner inset (px)")
            value: Config.options.background.widgets.clock.anchorMargin
            from: 0
            to: 120
            stepSize: 2
            onValueChanged: {
                Config.options.background.widgets.clock.anchorMargin = value;
            }
        }

        ConfigSwitch {
            buttonIcon: "terminal"
            text: Translation.tr("CLI clock (monospace digital)")
            checked: Config.options.background.widgets.clock.cliStyle
            onCheckedChanged: {
                Config.options.background.widgets.clock.cliStyle = checked;
            }

            StyledToolTip {
                text: Translation.tr("Forces digital time with the font from “CLI” settings (see font fields in config if needed).")
            }

        }

        ConfigSwitch {
            buttonIcon: "lock_clock"
            text: Translation.tr("Show only when locked")
            checked: Config.options.background.widgets.clock.showOnlyWhenLocked
            onCheckedChanged: {
                Config.options.background.widgets.clock.showOnlyWhenLocked = checked;
            }
        }

        ConfigRow {
            ContentSubsection {
                visible: !Config.options.background.widgets.clock.showOnlyWhenLocked
                title: Translation.tr("Clock style")
                Layout.fillWidth: true

                ConfigSelectionArray {
                    currentValue: Config.options.background.widgets.clock.style
                    onSelected: (newValue) => {
                        Config.options.background.widgets.clock.style = newValue;
                    }
                    options: [{
                        "displayName": Translation.tr("Digital"),
                        "icon": "timer_10",
                        "value": "digital"
                    }, {
                        "displayName": Translation.tr("Cookie"),
                        "icon": "cookie",
                        "value": "cookie"
                    }]
                }

            }

            ContentSubsection {
                title: Translation.tr("Clock style (locked)")
                Layout.fillWidth: false

                ConfigSelectionArray {
                    currentValue: Config.options.background.widgets.clock.styleLocked
                    onSelected: (newValue) => {
                        Config.options.background.widgets.clock.styleLocked = newValue;
                    }
                    options: [{
                        "displayName": Translation.tr("Digital"),
                        "icon": "timer_10",
                        "value": "digital"
                    }, {
                        "displayName": Translation.tr("Cookie"),
                        "icon": "cookie",
                        "value": "cookie"
                    }]
                }

            }

        }

        ContentSubsection {
            visible: settingsClock.digitalPresent
            title: Translation.tr("Digital clock settings")
            tooltip: Translation.tr("Font width and roundness settings are only available for some fonts like Google Sans Flex")

            ConfigRow {
                uniform: true

                ConfigSwitch {
                    buttonIcon: "vertical_distribute"
                    text: Translation.tr("Vertical")
                    checked: Config.options.background.widgets.clock.digital.vertical
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.digital.vertical = checked;
                    }
                }

                ConfigSwitch {
                    buttonIcon: "animation"
                    text: Translation.tr("Animate time change")
                    checked: Config.options.background.widgets.clock.digital.animateChange
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.digital.animateChange = checked;
                    }
                }

            }

            ConfigRow {
                uniform: true

                ConfigSwitch {
                    buttonIcon: "date_range"
                    text: Translation.tr("Show date")
                    checked: Config.options.background.widgets.clock.digital.showDate
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.digital.showDate = checked;
                    }
                }

                ConfigSwitch {
                    buttonIcon: "activity_zone"
                    text: Translation.tr("Use adaptive alignment")
                    checked: Config.options.background.widgets.clock.digital.adaptiveAlignment
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.digital.adaptiveAlignment = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("Aligns the date and quote to left, center or right depending on its position on the screen.")
                    }

                }

            }

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Font family")
                text: Config.options.background.widgets.clock.digital.font.family
                wrapMode: TextEdit.Wrap
                onTextChanged: {
                    Config.options.background.widgets.clock.digital.font.family = text;
                }
            }

            ConfigSlider {
                text: Translation.tr("Font weight")
                value: Config.options.background.widgets.clock.digital.font.weight
                usePercentTooltip: false
                buttonIcon: "format_bold"
                from: 1
                to: 1000
                stopIndicatorValues: [350]
                onValueChanged: {
                    Config.options.background.widgets.clock.digital.font.weight = value;
                }
            }

            ConfigSlider {
                text: Translation.tr("Font size")
                value: Config.options.background.widgets.clock.digital.font.size
                usePercentTooltip: false
                buttonIcon: "format_size"
                from: 50
                to: 700
                stopIndicatorValues: [90]
                onValueChanged: {
                    Config.options.background.widgets.clock.digital.font.size = value;
                }
            }

            ConfigSlider {
                text: Translation.tr("Font width")
                value: Config.options.background.widgets.clock.digital.font.width
                usePercentTooltip: false
                buttonIcon: "fit_width"
                from: 25
                to: 125
                stopIndicatorValues: [100]
                onValueChanged: {
                    Config.options.background.widgets.clock.digital.font.width = value;
                }
            }

            ConfigSlider {
                text: Translation.tr("Font roundness")
                value: Config.options.background.widgets.clock.digital.font.roundness
                usePercentTooltip: false
                buttonIcon: "line_curve"
                from: 0
                to: 100
                onValueChanged: {
                    Config.options.background.widgets.clock.digital.font.roundness = value;
                }
            }

        }

        ContentSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Cookie clock settings")

            ConfigSwitch {
                buttonIcon: "wand_stars"
                text: Translation.tr("Auto styling with Gemini")
                checked: Config.options.background.widgets.clock.cookie.aiStyling
                onCheckedChanged: {
                    Config.options.background.widgets.clock.cookie.aiStyling = checked;
                }

                StyledToolTip {
                    text: Translation.tr("Uses Gemini to categorize the wallpaper then picks a preset based on it.\nYou'll need to set Gemini API key on the left sidebar first.\nImages are downscaled for performance, but just to be safe,\ndo not select wallpapers with sensitive information.")
                }

            }

            ConfigSwitch {
                buttonIcon: "airwave"
                text: Translation.tr("Use old sine wave cookie implementation")
                checked: Config.options.background.widgets.clock.cookie.useSineCookie
                onCheckedChanged: {
                    Config.options.background.widgets.clock.cookie.useSineCookie = checked;
                }

                StyledToolTip {
                    text: "Looks a bit softer and more consistent with different number of sides,\nbut has less impressive morphing"
                }

            }

            ConfigSpinBox {
                icon: "add_triangle"
                text: Translation.tr("Sides")
                value: Config.options.background.widgets.clock.cookie.sides
                from: 0
                to: 40
                stepSize: 1
                onValueChanged: {
                    Config.options.background.widgets.clock.cookie.sides = value;
                }
            }

            ConfigSwitch {
                buttonIcon: "autoplay"
                text: Translation.tr("Constantly rotate")
                checked: Config.options.background.widgets.clock.cookie.constantlyRotate
                onCheckedChanged: {
                    Config.options.background.widgets.clock.cookie.constantlyRotate = checked;
                }

                StyledToolTip {
                    text: "Makes the clock always rotate. This is extremely expensive\n(expect 50% usage on Intel UHD Graphics) and thus impractical."
                }

            }

            ConfigRow {
                ConfigSwitch {
                    enabled: Config.options.background.widgets.clock.cookie.dialNumberStyle === "dots" || Config.options.background.widgets.clock.cookie.dialNumberStyle === "full"
                    buttonIcon: "brightness_7"
                    text: Translation.tr("Hour marks")
                    checked: Config.options.background.widgets.clock.cookie.hourMarks
                    onEnabledChanged: {
                        checked = Config.options.background.widgets.clock.cookie.hourMarks;
                    }
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.cookie.hourMarks = checked;
                    }

                    StyledToolTip {
                        text: "Can only be turned on using the 'Dots' or 'Full' dial style for aesthetic reasons"
                    }

                }

                ConfigSwitch {
                    enabled: Config.options.background.widgets.clock.cookie.dialNumberStyle !== "numbers"
                    buttonIcon: "timer_10"
                    text: Translation.tr("Digits in the middle")
                    checked: Config.options.background.widgets.clock.cookie.timeIndicators
                    onEnabledChanged: {
                        checked = Config.options.background.widgets.clock.cookie.timeIndicators;
                    }
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.cookie.timeIndicators = checked;
                    }

                    StyledToolTip {
                        text: "Can't be turned on when using 'Numbers' dial style for aesthetic reasons"
                    }

                }

            }

        }

        ContentSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Dial style")

            ConfigSelectionArray {
                currentValue: Config.options.background.widgets.clock.cookie.dialNumberStyle
                onSelected: (newValue) => {
                    Config.options.background.widgets.clock.cookie.dialNumberStyle = newValue;
                    if (newValue !== "dots" && newValue !== "full")
                        Config.options.background.widgets.clock.cookie.hourMarks = false;

                    if (newValue === "numbers")
                        Config.options.background.widgets.clock.cookie.timeIndicators = false;

                }
                options: [{
                    "displayName": "",
                    "icon": "block",
                    "value": "none"
                }, {
                    "displayName": Translation.tr("Dots"),
                    "icon": "graph_6",
                    "value": "dots"
                }, {
                    "displayName": Translation.tr("Full"),
                    "icon": "history_toggle_off",
                    "value": "full"
                }, {
                    "displayName": Translation.tr("Numbers"),
                    "icon": "counter_1",
                    "value": "numbers"
                }]
            }

        }

        ContentSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Hour hand")

            ConfigSelectionArray {
                currentValue: Config.options.background.widgets.clock.cookie.hourHandStyle
                onSelected: (newValue) => {
                    Config.options.background.widgets.clock.cookie.hourHandStyle = newValue;
                }
                options: [{
                    "displayName": "",
                    "icon": "block",
                    "value": "hide"
                }, {
                    "displayName": Translation.tr("Classic"),
                    "icon": "radio",
                    "value": "classic"
                }, {
                    "displayName": Translation.tr("Hollow"),
                    "icon": "circle",
                    "value": "hollow"
                }, {
                    "displayName": Translation.tr("Fill"),
                    "icon": "eraser_size_5",
                    "value": "fill"
                }]
            }

        }

        ContentSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Minute hand")

            ConfigSelectionArray {
                currentValue: Config.options.background.widgets.clock.cookie.minuteHandStyle
                onSelected: (newValue) => {
                    Config.options.background.widgets.clock.cookie.minuteHandStyle = newValue;
                }
                options: [{
                    "displayName": "",
                    "icon": "block",
                    "value": "hide"
                }, {
                    "displayName": Translation.tr("Classic"),
                    "icon": "radio",
                    "value": "classic"
                }, {
                    "displayName": Translation.tr("Thin"),
                    "icon": "line_end",
                    "value": "thin"
                }, {
                    "displayName": Translation.tr("Medium"),
                    "icon": "eraser_size_2",
                    "value": "medium"
                }, {
                    "displayName": Translation.tr("Bold"),
                    "icon": "eraser_size_4",
                    "value": "bold"
                }]
            }

        }

        ContentSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Second hand")

            ConfigSelectionArray {
                currentValue: Config.options.background.widgets.clock.cookie.secondHandStyle
                onSelected: (newValue) => {
                    Config.options.background.widgets.clock.cookie.secondHandStyle = newValue;
                }
                options: [{
                    "displayName": "",
                    "icon": "block",
                    "value": "hide"
                }, {
                    "displayName": Translation.tr("Classic"),
                    "icon": "radio",
                    "value": "classic"
                }, {
                    "displayName": Translation.tr("Line"),
                    "icon": "line_end",
                    "value": "line"
                }, {
                    "displayName": Translation.tr("Dot"),
                    "icon": "adjust",
                    "value": "dot"
                }]
            }

        }

        ContentSubsection {
            visible: settingsClock.cookiePresent
            title: Translation.tr("Date style")

            ConfigSelectionArray {
                currentValue: Config.options.background.widgets.clock.cookie.dateStyle
                onSelected: (newValue) => {
                    Config.options.background.widgets.clock.cookie.dateStyle = newValue;
                }
                options: [{
                    "displayName": "",
                    "icon": "block",
                    "value": "hide"
                }, {
                    "displayName": Translation.tr("Bubble"),
                    "icon": "bubble_chart",
                    "value": "bubble"
                }, {
                    "displayName": Translation.tr("Border"),
                    "icon": "rotate_right",
                    "value": "border"
                }, {
                    "displayName": Translation.tr("Rect"),
                    "icon": "rectangle",
                    "value": "rect"
                }]
            }

        }

        ContentSubsection {
            title: Translation.tr("Quote")
            tooltip: Translation.tr("Main text is always shown first. Extra lines in “More quotes” rotate or shuffle when interval > 0.")

            ConfigSwitch {
                buttonIcon: "check"
                text: Translation.tr("Enable")
                checked: Config.options.background.widgets.clock.quote.enable
                onCheckedChanged: {
                    Config.options.background.widgets.clock.quote.enable = checked;
                }
            }

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Primary quote")
                text: Config.options.background.widgets.clock.quote.text
                wrapMode: TextEdit.Wrap
                onTextChanged: {
                    Config.options.background.widgets.clock.quote.text = text;
                }
            }

            MaterialTextArea {
                id: quoteRotationPoolField

                Layout.fillWidth: true
                placeholderText: Translation.tr("More quotes (one per line, for rotation)")
                wrapMode: TextEdit.Wrap
                Component.onCompleted: {
                    quoteRotationPoolField.text = Config.options.background.widgets.clock.quote.rotationPool.join("\n");
                }
                onTextChanged: {
                    Config.options.background.widgets.clock.quote.rotationPool = text.split("\n").map((s) => {
                        return s.trimEnd();
                    }).filter((s) => {
                        return s.length > 0;
                    });
                }
            }

            ConfigSpinBox {
                icon: "schedule"
                text: Translation.tr("Rotation interval (s, 0 = off)")
                value: Config.options.background.widgets.clock.quote.rotateIntervalSec
                from: 0
                to: 3600
                stepSize: 5
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.rotateIntervalSec = value;
                }
            }

            ConfigSwitch {
                buttonIcon: "shuffle"
                text: Translation.tr("Shuffle instead of sequential")
                checked: Config.options.background.widgets.clock.quote.shuffle
                onCheckedChanged: {
                    Config.options.background.widgets.clock.quote.shuffle = checked;
                }
            }

        }

        ContentSubsection {
            title: Translation.tr("Quote layout & quotation marks")
            tooltip: Translation.tr("Tighten spacing next to the quote icon, trim curly quotes, or use ASCII quotes if typography feels too wide. “Cookie” clock only: hide icon.")

            ConfigSwitch {
                buttonIcon: "format_quote"
                text: Translation.tr("Show quote icon (cookie clock)")
                checked: Config.options.background.widgets.clock.quote.showQuoteIcon !== false
                onCheckedChanged: {
                    Config.options.background.widgets.clock.quote.showQuoteIcon = checked;
                }
            }

            ConfigSpinBox {
                icon: "space_bar"
                text: Translation.tr("Gap between icon and text (px)")
                value: Config.options.background.widgets.clock.quote.iconTextSpacing ?? 4
                from: 0
                to: 32
                stepSize: 1
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.iconTextSpacing = value;
                }
            }

            ConfigSpinBox {
                icon: "square"
                text: Translation.tr("Inner horizontal padding (cookie, px)")
                value: Config.options.background.widgets.clock.quote.paddingH ?? 8
                from: 0
                to: 48
                stepSize: 2
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.paddingH = value;
                }
            }

            ConfigSpinBox {
                icon: "square"
                text: Translation.tr("Inner vertical padding (cookie, px)")
                value: Config.options.background.widgets.clock.quote.paddingV ?? 4
                from: 0
                to: 48
                stepSize: 2
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.paddingV = value;
                }
            }

            ConfigSlider {
                buttonIcon: "format_line_spacing"
                text: Translation.tr("Line height (0 = default)")
                usePercentTooltip: false
                value: Config.options.background.widgets.clock.quote.lineHeight ?? 0
                from: 0
                to: 2
                stopIndicatorValues: [0]
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.lineHeight = value;
                }
            }

            ConfigSwitch {
                buttonIcon: "format_quote"
                text: Translation.tr("Strip outer quotation marks from text")
                checked: Config.flagIsTrue(Config.options.background.widgets.clock.quote.trimOuterQuotes)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.background.widgets.clock.quote.trimOuterQuotes) !== checked)
                        Config.options.background.widgets.clock.quote.trimOuterQuotes = checked;

                }
            }

            ConfigSwitch {
                buttonIcon: "text_fields"
                text: Translation.tr("Use ASCII quotes (narrower than “smart” quotes)")
                checked: Config.flagIsTrue(Config.options.background.widgets.clock.quote.useAsciiQuotes)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.background.widgets.clock.quote.useAsciiQuotes) !== checked)
                        Config.options.background.widgets.clock.quote.useAsciiQuotes = checked;

                }
            }

            ConfigSwitch {
                buttonIcon: "compress"
                text: Translation.tr("Collapse extra spaces in quote text")
                checked: Config.flagIsTrue(Config.options.background.widgets.clock.quote.collapseWhitespace)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.background.widgets.clock.quote.collapseWhitespace) !== checked)
                        Config.options.background.widgets.clock.quote.collapseWhitespace = checked;

                }
            }

            ConfigSwitch {
                buttonIcon: "data_array"
                text: Translation.tr("Auto-wrap with quotes if prefix/suffix empty")
                checked: Config.flagIsTrue(Config.options.background.widgets.clock.quote.autoWrapQuotes)
                onCheckedChanged: {
                    if (Config.flagIsTrue(Config.options.background.widgets.clock.quote.autoWrapQuotes) !== checked)
                        Config.options.background.widgets.clock.quote.autoWrapQuotes = checked;

                }
            }

        }

        ContentSubsection {
            title: Translation.tr("Quote typography")
            tooltip: Translation.tr("Leave size at 0 to use the default digital clock quote size.")

            ConfigSlider {
                text: Translation.tr("Font size (0 = default)")
                value: Config.options.background.widgets.clock.quote.fontSize
                usePercentTooltip: false
                buttonIcon: "format_size"
                from: 0
                to: 120
                stopIndicatorValues: [0]
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.fontSize = value;
                }
            }

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Font family (empty = theme reading font)")
                text: Config.options.background.widgets.clock.quote.fontFamily
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    Config.options.background.widgets.clock.quote.fontFamily = text;
                }
            }

            ConfigSlider {
                text: Translation.tr("Opacity")
                value: Math.round(Config.options.background.widgets.clock.quote.opacity * 100)
                usePercentTooltip: true
                buttonIcon: "opacity"
                from: 10
                to: 100
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.opacity = value / 100;
                }
            }

            ConfigSpinBox {
                icon: "width"
                text: Translation.tr("Max width (px, 0 = auto)")
                value: Config.options.background.widgets.clock.quote.maxWidth
                from: 0
                to: 2000
                stepSize: 20
                onValueChanged: {
                    Config.options.background.widgets.clock.quote.maxWidth = value;
                }
            }

            StyledComboBox {
                buttonIcon: "format_align_center"
                textRole: "displayName"
                model: [{
                    "displayName": Translation.tr("Align: follow clock"),
                    "value": "auto"
                }, {
                    "displayName": Translation.tr("Align: left"),
                    "value": "left"
                }, {
                    "displayName": Translation.tr("Align: center"),
                    "value": "center"
                }, {
                    "displayName": Translation.tr("Align: right"),
                    "value": "right"
                }]
                currentIndex: {
                    const v = Config.options.background.widgets.clock.quote.horizontalAlign;
                    const i = model.findIndex((e) => {
                        return e.value === v;
                    });
                    return i >= 0 ? i : 0;
                }
                onActivated: (index) => {
                    Config.options.background.widgets.clock.quote.horizontalAlign = model[index].value;
                }
            }

            ConfigRow {
                uniform: true

                ConfigSwitch {
                    buttonIcon: "format_italic"
                    text: Translation.tr("Italic")
                    checked: Config.options.background.widgets.clock.quote.italic
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.quote.italic = checked;
                    }
                }

                ConfigSwitch {
                    buttonIcon: "blur_on"
                    text: Translation.tr("Text shadow")
                    checked: Config.options.background.widgets.clock.quote.textShadow
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.quote.textShadow = checked;
                    }
                }

                ConfigSwitch {
                    buttonIcon: "text_fields"
                    text: Translation.tr("Uppercase")
                    checked: Config.options.background.widgets.clock.quote.uppercase
                    onCheckedChanged: {
                        Config.options.background.widgets.clock.quote.uppercase = checked;
                    }
                }

            }

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Prefix (e.g. ““ )")
                text: Config.options.background.widgets.clock.quote.prefix
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    Config.options.background.widgets.clock.quote.prefix = text;
                }
            }

            MaterialTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Suffix (e.g. ”” — Author)")
                text: Config.options.background.widgets.clock.quote.suffix
                wrapMode: TextEdit.NoWrap
                onTextChanged: {
                    Config.options.background.widgets.clock.quote.suffix = text;
                }
            }

        }

    }

    ContentSection {
        icon: "weather_mix"
        title: Translation.tr("Widget: Weather")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.background.widgets.weather.enable
            onCheckedChanged: {
                Config.options.background.widgets.weather.enable = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Placement")
            tooltip: Translation.tr("Where the weather widget snaps when not dragged.")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.background.widgets.weather.placementStrategy
                onSelected: (newValue) => {
                    Config.options.background.widgets.weather.placementStrategy = newValue;
                }
                options: [{
                    "displayName": Translation.tr("Draggable"),
                    "icon": "drag_pan",
                    "value": "free"
                }, {
                    "displayName": Translation.tr("Least busy"),
                    "icon": "category",
                    "value": "leastBusy"
                }, {
                    "displayName": Translation.tr("Most busy"),
                    "icon": "shapes",
                    "value": "mostBusy"
                }]
            }

        }

    }

}
