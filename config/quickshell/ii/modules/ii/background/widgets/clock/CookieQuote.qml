import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

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
    readonly property string quoteLineRaw: {
        const list = root.quoteCandidates;
        if (!list.length)
            return "";

        const iv = Config.options.background.widgets.clock.quote.rotateIntervalSec;
        if (list.length === 1 || !iv || iv <= 0)
            return list[0];

        const idx = Math.min(Math.max(0, root.quoteRotateIndex), list.length - 1);
        return list[idx];
    }
    readonly property string quoteLineShown: StringUtils.formatClockQuoteLine(root.quoteLineRaw, Config.options.background.widgets.clock.quote)
    readonly property real quoteBoxMaxWidth: {
        const m = Config.options.background.widgets.clock.quote.maxWidth;
        return m > 0 ? m : 560;
    }

    implicitWidth: quoteBox.width
    implicitHeight: quoteBox.implicitHeight

    Timer {
        running: Config.options.background.widgets.clock.quote.enable && root.quoteCandidates.length > 1 && Config.options.background.widgets.clock.quote.rotateIntervalSec > 0
        interval: Math.max(1, Config.options.background.widgets.clock.quote.rotateIntervalSec) * 1000
        repeat: true
        onTriggered: {
            const list = root.quoteCandidates;
            if (!list.length)
                return ;

            if (Config.options.background.widgets.clock.quote.shuffle)
                root.quoteRotateIndex = Math.floor(Math.random() * list.length);
            else
                root.quoteRotateIndex = (root.quoteRotateIndex + 1) % list.length;
        }
    }

    DropShadow {
        visible: Config.options.background.widgets.clock.quote.textShadow
        source: quoteBox
        anchors.fill: quoteBox
        horizontalOffset: 0
        verticalOffset: 2
        radius: 12
        samples: radius * 2 + 1
        color: Appearance.colors.colShadow
        transparentBorder: true
    }

    Rectangle {
        id: quoteBox

        width: root.quoteBoxMaxWidth
        implicitHeight: quoteRow.implicitHeight + 2 * Math.max(0, Config.options.background.widgets.clock.quote.paddingV ?? 4)
        radius: Appearance.rounding.small
        color: Appearance.colors.colSecondaryContainer

        RowLayout {
            id: quoteRow

            anchors.centerIn: parent
            width: parent.width - 2 * Math.max(0, Config.options.background.widgets.clock.quote.paddingH ?? 8)
            spacing: Math.max(0, Config.options.background.widgets.clock.quote.iconTextSpacing ?? 4)

            MaterialSymbol {
                id: quoteIcon

                visible: Config.options.background.widgets.clock.quote.showQuoteIcon !== false
                Layout.alignment: Qt.AlignTop
                iconSize: Appearance.font.pixelSize.huge
                text: "format_quote"
                color: Appearance.colors.colOnSecondaryContainer
                opacity: Config.options.background.widgets.clock.quote.opacity
            }

            StyledText {
                id: quoteStyledText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                text: root.quoteLineShown
                opacity: Config.options.background.widgets.clock.quote.opacity
                color: Appearance.colors.colOnSecondaryContainer
                style: Config.options.background.widgets.clock.quote.textShadow ? Text.Raised : Text.Normal
                styleColor: Config.options.background.widgets.clock.quote.textShadow ? Appearance.colors.colShadow : "transparent"
                lineHeightMode: Text.ProportionalHeight
                lineHeight: (Config.options.background.widgets.clock.quote.lineHeight ?? 0) > 0 ? Config.options.background.widgets.clock.quote.lineHeight : 1

                font {
                    family: Config.options.background.widgets.clock.quote.fontFamily.length > 0 ? Config.options.background.widgets.clock.quote.fontFamily : Appearance.font.family.reading
                    pixelSize: Config.options.background.widgets.clock.quote.fontSize > 0 ? Config.options.background.widgets.clock.quote.fontSize : Appearance.font.pixelSize.large
                    weight: Font.Normal
                    italic: Config.options.background.widgets.clock.quote.italic
                }

            }

        }

    }

}
