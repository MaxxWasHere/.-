pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: clockColumn
    spacing: 4

    property bool isVertical: Config.options.background.widgets.clock.digital.vertical
    property color colText: Appearance.colors.colOnSecondaryContainer
    property var textHorizontalAlignment: Text.AlignHCenter
    readonly property bool useCliTypography: Config.options.background.widgets.clock.cliStyle

    property int quoteRotateIndex: 0

    readonly property var quoteCandidates: {
        const q = Config.options.background.widgets.clock.quote;
        const out = [];
        const main = (q.text ?? "").trim();
        if (main.length > 0)
            out.push(main);
        const pool = q.rotationPool ?? [];
        for (let i = 0; i < pool.length; ++i) {
            const s = String(pool[i] ?? "").trim();
            if (s.length > 0)
                out.push(s);
        }
        return out;
    }

    readonly property int quoteHAlign: {
        const a = Config.options.background.widgets.clock.quote.horizontalAlign;
        if (a === "left")
            return Text.AlignLeft;
        if (a === "right")
            return Text.AlignRight;
        if (a === "center")
            return Text.AlignHCenter;
        return clockColumn.textHorizontalAlignment;
    }

    readonly property string quoteLineRaw: {
        const list = clockColumn.quoteCandidates;
        if (!list.length)
            return "";
        const iv = Config.options.background.widgets.clock.quote.rotateIntervalSec;
        if (list.length === 1 || !iv || iv <= 0)
            return list[0];
        const idx = Math.min(Math.max(0, clockColumn.quoteRotateIndex), list.length - 1);
        return list[idx];
    }

    readonly property string quoteLineShown: StringUtils.formatClockQuoteLine(clockColumn.quoteLineRaw, Config.options.background.widgets.clock.quote)

    Timer {
        running: Config.options.background.widgets.clock.quote.enable && clockColumn.quoteCandidates.length > 1 && Config.options.background.widgets.clock.quote.rotateIntervalSec > 0
        interval: Math.max(1, Config.options.background.widgets.clock.quote.rotateIntervalSec) * 1000
        repeat: true
        onTriggered: {
            const list = clockColumn.quoteCandidates;
            if (!list.length)
                return;
            if (Config.options.background.widgets.clock.quote.shuffle)
                clockColumn.quoteRotateIndex = Math.floor(Math.random() * list.length);
            else
                clockColumn.quoteRotateIndex = (clockColumn.quoteRotateIndex + 1) % list.length;
        }
    }

    // Time
    ClockText {
        id: timeTextTop
        text: clockColumn.isVertical ? DateTime.time.split(":")[0].padStart(2, "0") : DateTime.time
        color: clockColumn.colText
        horizontalAlignment: Text.AlignHCenter
        font {
            pixelSize: clockColumn.useCliTypography ? Config.options.background.widgets.clock.cli.fontSize : Config.options.background.widgets.clock.digital.font.size
            weight: clockColumn.useCliTypography ? Config.options.background.widgets.clock.cli.fontWeight : Config.options.background.widgets.clock.digital.font.weight
            family: clockColumn.useCliTypography ? Config.options.background.widgets.clock.cli.fontFamily : Config.options.background.widgets.clock.digital.font.family
            variableAxes: clockColumn.useCliTypography ? ({}) : ({
                    "wdth": Config.options.background.widgets.clock.digital.font.width,
                    "ROND": Config.options.background.widgets.clock.digital.font.roundness
                })
        }
    }

    Loader {
        Layout.topMargin: -40
        Layout.fillWidth: true
        active: clockColumn.isVertical
        visible: active
        sourceComponent: ClockText {
            id: timeTextBottom
            text: DateTime.time.split(":")[1].split(" ")[0].padStart(2, "0")
            color: clockColumn.colText
            horizontalAlignment: clockColumn.textHorizontalAlignment
            font {
                pixelSize: timeTextTop.font.pixelSize
                weight: timeTextTop.font.weight
                family: timeTextTop.font.family
                variableAxes: clockColumn.useCliTypography ? ({}) : timeTextTop.font.variableAxes
            }
        }
    }

    // Date
    ClockText {
        visible: Config.options.background.widgets.clock.digital.showDate
        Layout.topMargin: clockColumn.useCliTypography ? -8 : -20
        Layout.fillWidth: true
        text: DateTime.longDate
        color: clockColumn.colText
        horizontalAlignment: clockColumn.textHorizontalAlignment
        font {
            family: clockColumn.useCliTypography ? Config.options.background.widgets.clock.cli.fontFamily : timeTextTop.font.family
            pixelSize: clockColumn.useCliTypography ? Appearance.font.pixelSize.normal : Math.round(timeTextTop.font.pixelSize * 0.42)
            weight: clockColumn.useCliTypography ? Config.options.background.widgets.clock.cli.fontWeight : Font.Normal
            variableAxes: timeTextTop.font.variableAxes
        }
    }

    // Quote
    ClockText {
        visible: Config.options.background.widgets.clock.quote.enable && clockColumn.quoteLineShown.length > 0
        Layout.fillWidth: true
        Layout.maximumWidth: Config.options.background.widgets.clock.quote.maxWidth > 0 ? Config.options.background.widgets.clock.quote.maxWidth : 100000
        wrapMode: Config.options.background.widgets.clock.quote.maxWidth > 0 ? Text.WordWrap : Text.NoWrap
        font.pixelSize: Config.options.background.widgets.clock.quote.fontSize > 0 ? Config.options.background.widgets.clock.quote.fontSize : Appearance.font.pixelSize.normal
        font.italic: Config.options.background.widgets.clock.quote.italic
        font.family: Config.options.background.widgets.clock.quote.fontFamily.length > 0 ? Config.options.background.widgets.clock.quote.fontFamily : Appearance.font.family.expressive
        opacity: Config.options.background.widgets.clock.quote.opacity
        text: clockColumn.quoteLineShown
        animateChange: false
        color: clockColumn.colText
        horizontalAlignment: clockColumn.quoteHAlign
        style: Config.options.background.widgets.clock.quote.textShadow ? Text.Raised : Text.Normal
        styleColor: Config.options.background.widgets.clock.quote.textShadow ? Appearance.colors.colShadow : "transparent"
        lineHeightMode: Text.ProportionalHeight
        lineHeight: (Config.options.background.widgets.clock.quote.lineHeight ?? 0) > 0 ? Config.options.background.widgets.clock.quote.lineHeight : 1
    }
}
