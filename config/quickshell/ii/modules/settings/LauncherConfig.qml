import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "search"
        title: Translation.tr("Launcher / overview")

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Appearance.colors.colSubtext
            text: Translation.tr("The app launcher opens with the overview/search shortcut (e.g. Super+Space). These options change layout and motion only.")
        }

        ConfigSwitch {
            buttonIcon: "vertical_align_center"
            text: Translation.tr("Vertically center on screen")
            checked: Config.options.launcher.overview.verticalCenter
            onCheckedChanged: {
                Config.options.launcher.overview.verticalCenter = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Animations")

            ConfigSwitch {
                buttonIcon: "animation"
                text: Translation.tr("Open animation (scale)")
                checked: Config.options.launcher.overview.openAnimation
                onCheckedChanged: {
                    Config.options.launcher.overview.openAnimation = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "expand"
                text: Translation.tr("Animate search bar width (collapsed → expanded)")
                checked: Config.options.launcher.overview.expandSearchWidthAnimation
                onCheckedChanged: {
                    Config.options.launcher.overview.expandSearchWidthAnimation = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "unfold_more"
                text: Translation.tr("Animate results list height")
                checked: Config.options.launcher.overview.resultsHeightAnimation
                onCheckedChanged: {
                    Config.options.launcher.overview.resultsHeightAnimation = checked;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Effects")

            ConfigSwitch {
                buttonIcon: "layers"
                text: Translation.tr("Drop shadow behind search panel")
                checked: Config.options.launcher.overview.panelShadow
                onCheckedChanged: {
                    Config.options.launcher.overview.panelShadow = checked;
                }
            }
        }
    }
}
