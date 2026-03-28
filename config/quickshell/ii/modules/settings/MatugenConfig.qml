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
        title: Translation.tr("Matugen generation")
        subtitle: Translation.tr("Wallpaper-driven colors: passed to the matugen CLI when you switch wallpaper or run re-apply.")

        ContentSubsection {
            title: Translation.tr("Color scheme type")
            tooltip: Translation.tr("Same as Customize → Theme & color. Re-runs your wallpaper script with --noswitch.")

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

        ConfigSlider {
            buttonIcon: "contrast"
            text: Translation.tr("Contrast (-1 min … +1 max)")
            usePercentTooltip: false
            from: -1
            to: 1
            value: Config.options.appearance.wallpaperTheming.matugen?.contrast ?? 0
            onValueChanged: {
                Config.setNestedValue("appearance.wallpaperTheming.matugen.contrast", value);
            }
        }

        ConfigSpinBox {
            icon: "filter_1"
            text: Translation.tr("Source color index (0 = dominant … 4)")
            value: {
                var mg = Config.options.appearance.wallpaperTheming.matugen;
                return (mg && mg.sourceColorIndex !== undefined) ? mg.sourceColorIndex : 0;
            }
            from: 0
            to: 4
            stepSize: 1
            onValueChanged: {
                Config.setNestedValue("appearance.wallpaperTheming.matugen.sourceColorIndex", value);
            }
        }

        StyledComboBox {
            Layout.fillWidth: true
            buttonIcon: "tune"
            textRole: "displayName"
            model: [
                { displayName: Translation.tr("Prefer color: default (matugen)"), value: "" },
                { displayName: Translation.tr("Prefer: darkness"), value: "darkness" },
                { displayName: Translation.tr("Prefer: lightness"), value: "lightness" },
                { displayName: Translation.tr("Prefer: saturation"), value: "saturation" },
                { displayName: Translation.tr("Prefer: less saturation"), value: "less-saturation" },
                { displayName: Translation.tr("Prefer: value"), value: "value" },
                { displayName: Translation.tr("Prefer: closest to fallback"), value: "closest-to-fallback" }
            ]
            currentIndex: {
                const v = Config.options.appearance.wallpaperTheming.matugen?.prefer ?? "";
                const i = model.findIndex(e => e.value === v);
                return i >= 0 ? i : 0;
            }
            onActivated: index => {
                Config.setNestedValue("appearance.wallpaperTheming.matugen.prefer", model[index].value);
            }
        }

        StyledComboBox {
            Layout.fillWidth: true
            buttonIcon: "image"
            textRole: "displayName"
            model: [
                { displayName: Translation.tr("Resize: Lanczos3"), value: "lanczos3" },
                { displayName: Translation.tr("Resize: Catmull-Rom"), value: "catmull-rom" },
                { displayName: Translation.tr("Resize: Gaussian"), value: "gaussian" },
                { displayName: Translation.tr("Resize: Triangle"), value: "triangle" },
                { displayName: Translation.tr("Resize: Nearest"), value: "nearest" }
            ]
            currentIndex: {
                const v = Config.options.appearance.wallpaperTheming.matugen?.resizeFilter ?? "lanczos3";
                const i = model.findIndex(e => e.value === v);
                return i >= 0 ? i : 0;
            }
            onActivated: index => {
                Config.setNestedValue("appearance.wallpaperTheming.matugen.resizeFilter", model[index].value);
            }
        }

        ConfigSlider {
            buttonIcon: "dark_mode"
            text: Translation.tr("Lightness tweak (dark mode, 0 = standard)")
            usePercentTooltip: false
            from: -1
            to: 1
            value: Config.options.appearance.wallpaperTheming.matugen?.lightnessDark ?? 0
            onValueChanged: {
                Config.setNestedValue("appearance.wallpaperTheming.matugen.lightnessDark", value);
            }
        }

        ConfigSlider {
            buttonIcon: "light_mode"
            text: Translation.tr("Lightness tweak (light mode, 0 = standard)")
            usePercentTooltip: false
            from: -1
            to: 3
            value: Config.options.appearance.wallpaperTheming.matugen?.lightnessLight ?? 0
            onValueChanged: {
                Config.setNestedValue("appearance.wallpaperTheming.matugen.lightnessLight", value);
            }
        }

        ConfigSwitch {
            buttonIcon: "data_object"
            text: Translation.tr("Include wallpaper path in matugen JSON output")
            checked: Config.flagIsTrue(Config.options.appearance.wallpaperTheming.matugen?.includeImageInJson)
            onCheckedChanged: {
                if (Config.flagIsTrue(Config.options.appearance.wallpaperTheming.matugen?.includeImageInJson) !== checked)
                    Config.setNestedValue("appearance.wallpaperTheming.matugen.includeImageInJson", checked);

            }
        }

        RippleButtonWithIcon {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            materialIcon: "refresh"
            mainText: Translation.tr("Re-apply matugen (no wallpaper change)")
            onClicked: Quickshell.execDetached(["bash", "-c", `${Directories.wallpaperSwitchScriptPath} --noswitch`])
            StyledToolTip {
                text: Translation.tr("Runs switchwall with --noswitch: regenerates colors, GTK, Hypr, Quickshell cache, Discord export if enabled.")
            }
        }
    }

    ContentSection {
        icon: "forum"
        title: Translation.tr("Discord")
        subtitle: Translation.tr("Exports a BetterDiscord-compatible theme (Matugen). Turn on a client theme plugin and select “Matugen”.")

        ConfigSwitch {
            buttonIcon: "sync"
            text: Translation.tr("Sync Discord theme when colors regenerate")
            checked: Config.flagIsTrue(Config.options.appearance.wallpaperTheming.enableDiscordTheme)
            onCheckedChanged: {
                if (Config.flagIsTrue(Config.options.appearance.wallpaperTheming.enableDiscordTheme) !== checked)
                    Config.options.appearance.wallpaperTheming.enableDiscordTheme = checked;

            }
        }

        ConfigSwitch {
            buttonIcon: "extension"
            text: Translation.tr("Write to Vencord themes folder")
            enabled: Config.flagIsTrue(Config.options.appearance.wallpaperTheming.enableDiscordTheme)
            checked: Config.flagIsTrue(Config.options.appearance.wallpaperTheming.discordExportVencord)
            onCheckedChanged: {
                if (Config.flagIsTrue(Config.options.appearance.wallpaperTheming.discordExportVencord) !== checked)
                    Config.options.appearance.wallpaperTheming.discordExportVencord = checked;

            }
        }

        ConfigSwitch {
            buttonIcon: "extension"
            text: Translation.tr("Write to BetterDiscord themes folder")
            enabled: Config.flagIsTrue(Config.options.appearance.wallpaperTheming.enableDiscordTheme)
            checked: Config.flagIsTrue(Config.options.appearance.wallpaperTheming.discordExportBetterDiscord)
            onCheckedChanged: {
                if (Config.flagIsTrue(Config.options.appearance.wallpaperTheming.discordExportBetterDiscord) !== checked)
                    Config.options.appearance.wallpaperTheming.discordExportBetterDiscord = checked;

            }
        }

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
            text: Translation.tr("Files: ~/.config/Vencord/themes/Matugen.theme.css and/or ~/.config/BetterDiscord/themes/Matugen.theme.css. Use a client theme plugin (e.g. Vencord ClientTheme) and pick this theme. Restart Discord if it does not hot-reload.")
        }
    }

    ContentSection {
        icon: "wallpaper"
        title: Translation.tr("Related")
        subtitle: Translation.tr("Terminal harmony sliders and app theming toggles stay under Customize → Theme & color.")

        ConfigSwitch {
            buttonIcon: "wallpaper"
            text: Translation.tr("Theming: apps & shell from wallpaper")
            checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell
            onCheckedChanged: {
                Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "terminal"
            text: Translation.tr("Theming: terminal sequences / kitty")
            checked: Config.options.appearance.wallpaperTheming.enableTerminal
            onCheckedChanged: {
                Config.options.appearance.wallpaperTheming.enableTerminal = checked;
            }
        }
    }
}
