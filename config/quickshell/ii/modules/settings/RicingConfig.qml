import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "screenshot_frame_2"
        title: Translation.tr("Screen capture")

        ContentSubsection {
            title: Translation.tr("Area snip tool")
            tooltip: Translation.tr("Used for Super+Shift+S and bar/IPC region shots.\n• Illogical Impulse — selector built into this shell.\n• HyprQuickFrame — separate Quickshell config (see its README; AUR: hyprquickframe-git).")

            ConfigSelectionArray {
                Layout.fillWidth: true
                currentValue: Config.options.ricing.screenshotTool
                onSelected: newValue => {
                    Config.options.ricing.screenshotTool = newValue;
                }
                options: [
                    {
                        value: "quickshell",
                        displayName: Translation.tr("Illogical Impulse"),
                        icon: "widgets"
                    },
                    {
                        value: "hyprquickframe",
                        displayName: Translation.tr("HyprQuickFrame"),
                        icon: "photo_camera"
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "palette"
        title: Translation.tr("Hyprland overrides")

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Appearance.colors.colSubtext
            text: Translation.tr("Your own window and layer rules: ~/.config/hypr/ricing/ (loaded after the default hyprland/* files). Quickshell still reads colors from Matugen’s generated colors.json.")
        }

        RippleButtonWithIcon {
            Layout.fillWidth: true
            implicitHeight: 44
            materialIcon: "folder_open"
            mainText: Translation.tr("Open hypr/ricing folder")
            onClicked: {
                Qt.openUrlExternally(`${Directories.config}/hypr/ricing`);
            }
        }
    }
}
