import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower

Rectangle {
    id: slidersPanelRoot
    readonly property bool materialPanel: Config.options.sidebar.panelStyle === "material"

    property var screen: slidersPanelRoot.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)

    implicitWidth: contentItem.implicitWidth + slidersPanelRoot.horizontalPadding * 2
    implicitHeight: contentItem.implicitHeight + slidersPanelRoot.verticalPadding * 2
    radius: slidersPanelRoot.materialPanel ? Appearance.rounding.large : Appearance.rounding.normal
    color: Appearance.colors.colLayer1
    property real verticalPadding: slidersPanelRoot.materialPanel ? 10 : 4
    property real horizontalPadding: slidersPanelRoot.materialPanel ? 14 : 12

    Column {
        id: contentItem
        anchors {
            fill: parent
            leftMargin: slidersPanelRoot.horizontalPadding
            rightMargin: slidersPanelRoot.horizontalPadding
            topMargin: slidersPanelRoot.verticalPadding
            bottomMargin: slidersPanelRoot.verticalPadding
        }

        Loader {
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: active
            active: Config.options.sidebar.quickSliders.showBrightness
            sourceComponent: QuickSlider {
                materialSymbol: "brightness_6"
                value: slidersPanelRoot.brightnessMonitor.brightness
                onMoved: {
                    slidersPanelRoot.brightnessMonitor.setBrightness(value)
                }
            }
        }

        Loader {
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: active
            active: Config.options.sidebar.quickSliders.showVolume
            sourceComponent: QuickSlider {
                materialSymbol: "volume_up"
                value: Audio.sink.audio.volume
                onMoved: {
                    Audio.sink.audio.volume = value
                }
            }
        }

        Loader {
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: active
            active: Config.options.sidebar.quickSliders.showMic
            sourceComponent: QuickSlider {
                materialSymbol: "mic"
                value: Audio.source.audio.volume
                onMoved: {
                    Audio.source.audio.volume = value
                }
            }
        }
    }

    component QuickSlider: StyledSlider { 
        id: quickSlider
        required property string materialSymbol
        configuration: slidersPanelRoot.materialPanel ? StyledSlider.Configuration.L : StyledSlider.Configuration.M
        stopIndicatorValues: []
        
        MaterialSymbol {
            id: icon
            property bool nearFull: quickSlider.value >= 0.9
            anchors {
                verticalCenter: parent.verticalCenter
                right: nearFull ? quickSlider.handle.right : parent.right
                rightMargin: quickSlider.nearFull ? 14 : 8
            }
            iconSize: 20
            color: nearFull ? Appearance.colors.colOnPrimary : Appearance.colors.colOnSecondaryContainer
            text: quickSlider.materialSymbol

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
            Behavior on anchors.rightMargin {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

        }
    }
}
