import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.sidebarLeft.aiChat
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Item {
    id: root
    property real padding: 4
    property var inputField: messageInputField
    property string commandPrefix: "/"

    property var suggestionQuery: ""
    property var suggestionList: []

    readonly property var hubCapabilityModels: Ai.availableTools.map(tool => {
        return {
            id: tool,
            icon: tool === "search" ? "search" : tool === "none" ? "chat" : "build",
            title: tool.charAt(0).toUpperCase() + tool.slice(1),
            sub: Ai.toolDescriptions[tool] ?? ""
        };
    })

    function shortenModelDescription(modelId) {
        const d = Ai.models[modelId]?.description ?? "";
        if (d.length <= 140)
            return d;
        return d.slice(0, 137) + "…";
    }

    function positionPopupNearInput(popup) {
        const m = 8;
        popup.x = Math.round(Math.max(m, Math.min(root.width - popup.width - m, (root.width - popup.width) / 2)));
        popup.y = Math.round(Math.max(m, root.height - popup.height - m));
    }

    onFocusChanged: focus => {
        if (focus) {
            root.inputField.forceActiveFocus();
        }
    }

    Keys.onPressed: event => {
        messageInputField.forceActiveFocus();
        if (event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageUp) {
                messageListView.contentY = Math.max(0, messageListView.contentY - messageListView.height / 2);
                event.accepted = true;
            } else if (event.key === Qt.Key_PageDown) {
                messageListView.contentY = Math.min(messageListView.contentHeight - messageListView.height / 2, messageListView.contentY + messageListView.height / 2);
                event.accepted = true;
            }
        }
        if ((event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier) && event.key === Qt.Key_O) {
            Ai.clearMessages();
        }
    }

    property var allCommands: [
        {
            name: "attach",
            description: Translation.tr("Attach a file. Only works with Gemini."),
            execute: args => {
                Ai.attachFile(args.join(" ").trim());
            }
        },
        {
            name: "model",
            description: Translation.tr("Choose model"),
            execute: args => {
                Ai.setModel(args[0]);
            }
        },
        {
            name: "tool",
            description: Translation.tr("Set the tool to use for the model."),
            execute: args => {
                // console.log(args)
                if (args.length == 0 || args[0] == "get") {
                    Ai.addMessage(Translation.tr("Usage: %1tool TOOL_NAME").arg(root.commandPrefix), Ai.interfaceRole);
                } else {
                    const tool = args[0];
                    const switched = Ai.setTool(tool);
                    if (switched) {
                        Ai.addMessage(Translation.tr("Tool set to: %1").arg(tool), Ai.interfaceRole);
                    }
                }
            }
        },
        {
            name: "prompt",
            description: Translation.tr("Set the system prompt for the model."),
            execute: args => {
                if (args.length === 0 || args[0] === "get") {
                    Ai.printPrompt();
                    return;
                }
                Ai.loadPrompt(args.join(" ").trim());
            }
        },
        {
            name: "key",
            description: Translation.tr("Set API key"),
            execute: args => {
                if (args[0] == "get") {
                    Ai.printApiKey();
                } else {
                    Ai.setApiKey(args[0]);
                }
            }
        },
        {
            name: "save",
            description: Translation.tr("Save chat"),
            execute: args => {
                const joinedArgs = args.join(" ");
                if (joinedArgs.trim().length == 0) {
                    Ai.addMessage(Translation.tr("Usage: %1save CHAT_NAME").arg(root.commandPrefix), Ai.interfaceRole);
                    return;
                }
                Ai.saveChat(joinedArgs);
            }
        },
        {
            name: "load",
            description: Translation.tr("Load chat"),
            execute: args => {
                const joinedArgs = args.join(" ");
                if (joinedArgs.trim().length == 0) {
                    Ai.addMessage(Translation.tr("Usage: %1load CHAT_NAME").arg(root.commandPrefix), Ai.interfaceRole);
                    return;
                }
                Ai.loadChat(joinedArgs);
            }
        },
        {
            name: "clear",
            description: Translation.tr("Clear chat history"),
            execute: () => {
                Ai.clearMessages();
            }
        },
        {
            name: "temp",
            description: Translation.tr("Set temperature (randomness) of the model. Values range between 0 to 2 for Gemini, 0 to 1 for other models. Default is 0.5."),
            execute: args => {
                // console.log(args)
                if (args.length == 0 || args[0] == "get") {
                    Ai.printTemperature();
                } else {
                    const temp = parseFloat(args[0]);
                    Ai.setTemperature(temp);
                }
            }
        },
        {
            name: "test",
            description: Translation.tr("Markdown test"),
            execute: () => {
                Ai.addMessage(`
<think>
A longer think block to test revealing animation
OwO wem ipsum dowo sit amet, consekituwet awipiscing ewit, sed do eiuwsmod tempow inwididunt ut wabowe et dowo mawa. Ut enim ad minim weniam, quis nostwud exeucitation uwuwamcow bowowis nisi ut awiquip ex ea commowo consequat. Duuis aute iwuwe dowo in wepwependewit in wowuptate velit esse ciwwum dowo eu fugiat nuwa pawiatuw. Excepteuw sint occaecat cupidatat non pwowoident, sunt in cuwpa qui officia desewunt mowit anim id est wabowum. Meouw! >w<
Mowe uwu wem ipsum!
</think>
## ✏️ Markdown test
### Formatting

- *Italic*, \`Monospace\`, **Bold**, [Link](https://example.com)
- Arch lincox icon <img src="${Quickshell.shellPath("assets/icons/arch-symbolic.svg")}" height="${Appearance.font.pixelSize.small}"/>

### Table

Quickshell vs AGS/Astal

|                          | Quickshell       | AGS/Astal         |
|--------------------------|------------------|-------------------|
| UI Toolkit               | Qt               | Gtk3/Gtk4         |
| Language                 | QML              | Js/Ts/Lua         |
| Reactivity               | Implied          | Needs declaration |
| Widget placement         | Mildly difficult | More intuitive    |
| Bluetooth & Wifi support | ❌               | ✅                |
| No-delay keybinds        | ✅               | ❌                |
| Development              | New APIs         | New syntax        |

### Code block

Just a hello world...

\`\`\`cpp
#include <bits/stdc++.h>
// This is intentionally very long to test scrolling
const std::string GREETING = \"UwU\";
int main(int argc, char* argv[]) {
    std::cout << GREETING;
}
\`\`\`

### LaTeX


Inline w/ dollar signs: $\\frac{1}{2} = \\frac{2}{4}$

Inline w/ double dollar signs: $$\\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}$$

Inline w/ backslash and square brackets \\[\\int_0^\\infty \\frac{1}{x^2} dx = \\infty\\]

Inline w/ backslash and round brackets \\(e^{i\\pi} + 1 = 0\\)
`, Ai.interfaceRole);
            }
        },
    ]

    function handleInput(inputText) {
        if (inputText.startsWith(root.commandPrefix)) {
            // Handle special commands
            const command = inputText.split(" ")[0].substring(1);
            const args = inputText.split(" ").slice(1);
            const commandObj = root.allCommands.find(cmd => cmd.name === `${command}`);
            if (commandObj) {
                commandObj.execute(args);
            } else {
                Ai.addMessage(Translation.tr("Unknown command: ") + command, Ai.interfaceRole);
            }
        } else {
            Ai.sendUserMessage(inputText);
        }

        // Always scroll to bottom when user sends a message
        messageListView.positionViewAtEnd();
    }

    Process {
        id: decodeImageAndAttachProc
        property string imageDecodePath: Directories.cliphistDecode
        property string imageDecodeFileName: "image"
        property string imageDecodeFilePath: `${imageDecodePath}/${imageDecodeFileName}`
        function handleEntry(entry: string) {
            imageDecodeFileName = parseInt(entry.match(/^(\d+)\t/)[1]);
            decodeImageAndAttachProc.exec(["bash", "-c", `[ -f ${imageDecodeFilePath} ] || echo '${StringUtils.shellSingleQuoteEscape(entry)}' | ${Cliphist.cliphistBinary} decode > '${imageDecodeFilePath}'`]);
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                Ai.attachFile(imageDecodeFilePath);
            } else {
                console.error("[AiChat] Failed to decode image in clipboard content");
            }
        }
    }

    component StatusItem: MouseArea {
        id: statusItem
        property string icon
        property string statusText
        property string description
        hoverEnabled: true
        implicitHeight: statusItemRowLayout.implicitHeight
        implicitWidth: statusItemRowLayout.implicitWidth

        RowLayout {
            id: statusItemRowLayout
            spacing: 0
            MaterialSymbol {
                text: statusItem.icon
                iconSize: Appearance.font.pixelSize.huge
                color: Appearance.colors.colSubtext
            }
            StyledText {
                font.pixelSize: Appearance.font.pixelSize.small
                text: statusItem.statusText
                color: Appearance.colors.colSubtext
                animateChange: true
            }
        }

        StyledToolTip {
            text: statusItem.description
            extraVisibleCondition: false
            alternativeVisibleCondition: statusItem.containsMouse
        }
    }

    component StatusSeparator: Rectangle {
        implicitWidth: 4
        implicitHeight: 4
        radius: implicitWidth / 2
        color: Appearance.colors.colOutlineVariant
    }

    ColumnLayout {
        id: columnLayout
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: root.padding

        Item {
            id: messageArea
            // Messages
            Layout.fillWidth: true
            Layout.fillHeight: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: messageArea.width
                    height: messageArea.height
                    radius: Appearance.rounding.small
                }
            }

            StyledRectangularShadow {
                z: 1
                target: statusBg
                opacity: messageListView.atYBeginning ? 0 : 1
                visible: opacity > 0
                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
            Rectangle {
                id: statusBg
                z: 2
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 4
                }
                implicitWidth: statusRowLayout.implicitWidth + 10 * 2
                implicitHeight: Math.max(statusRowLayout.implicitHeight, 38)
                radius: Appearance.rounding.normal - root.padding
                color: messageListView.atYBeginning ? Appearance.colors.colLayer2 : Appearance.colors.colLayer2Base
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
                RowLayout {
                    id: statusRowLayout
                    anchors.centerIn: parent
                    spacing: 10

                    StatusItem {
                        icon: Ai.currentModelHasApiKey ? "key" : "key_off"
                        statusText: ""
                        description: Ai.currentModelHasApiKey
                            ? Translation.tr("API key is set\nChange with /key or illogical-impulse config (ai.*)")
                            : Translation.tr("No API key\nUse /key or edit illogical-impulse config (ai.*)")
                    }
                    StatusSeparator {}
                    StatusItem {
                        visible: Ai.currentTool !== "none"
                        icon: Ai.currentTool === "search" ? "search" : "build"
                        statusText: ""
                        description: Ai.currentTool === "search"
                            ? Translation.tr("Tool mode: search (Gemini)\nChange with /tool")
                            : Translation.tr("Tool mode: agent (functions)\nChange with /tool or illogical-impulse config")
                    }
                    StatusSeparator {
                        visible: Ai.currentTool !== "none"
                    }
                    StatusItem {
                        icon: "device_thermostat"
                        statusText: Ai.temperature.toFixed(1)
                        description: Translation.tr("Temperature\nChange with /temp VALUE")
                    }
                    StatusSeparator {
                        visible: Ai.tokenCount.total > 0
                    }
                    StatusItem {
                        visible: Ai.tokenCount.total > 0
                        icon: "token"
                        statusText: Ai.tokenCount.total
                        description: Translation.tr("Total token count\nInput: %1\nOutput: %2").arg(Ai.tokenCount.input).arg(Ai.tokenCount.output)
                    }
                }
            }

            ScrollEdgeFade {
                z: 1
                target: messageListView
                vertical: true
            }

            StyledListView { // Message list
                id: messageListView
                z: 0
                anchors.fill: parent
                spacing: 10
                popin: false
                topMargin: statusBg.implicitHeight + statusBg.anchors.topMargin * 2

                touchpadScrollFactor: Config.options.interactions.scrolling.touchpadScrollFactor * 1.4
                mouseScrollFactor: Config.options.interactions.scrolling.mouseScrollFactor * 1.4

                property int lastResponseLength: 0
                onContentHeightChanged: {
                    if (atYEnd)
                        Qt.callLater(positionViewAtEnd);
                }
                onCountChanged: {
                    // Auto-scroll when new messages are added
                    if (atYEnd)
                        Qt.callLater(positionViewAtEnd);
                }

                add: null // Prevent function calls from being janky

                model: ScriptModel {
                    values: Ai.messageIDs.filter(id => {
                        const message = Ai.messageByID[id];
                        return message?.visibleToUser ?? true;
                    })
                }
                delegate: AiMessage {
                    required property var modelData
                    required property int index
                    messageIndex: index
                    messageData: {
                        Ai.messageByID[modelData];
                    }
                    messageInputField: root.inputField
                }
            }

            PagePlaceholder {
                z: 2
                shown: Ai.messageIDs.length === 0
                icon: "neurology"
                title: Translation.tr("Large language models")
                description: Translation.tr("Type /key to get started with online models\nCtrl+O to expand sidebar\nCtrl+P to pin sidebar\nCtrl+D to detach sidebar")
                shape: MaterialShape.Shape.PixelCircle
            }

            ScrollToBottomButton {
                z: 3
                target: messageListView
            }
        }

        DescriptionBox {
            text: root.suggestionList[suggestions.selectedIndex]?.description ?? ""
            showArrows: root.suggestionList.length > 1
        }

        FlowButtonGroup { // Suggestions
            id: suggestions
            visible: root.suggestionList.length > 0 && messageInputField.text.length > 0
            property int selectedIndex: 0
            Layout.fillWidth: true
            spacing: 5

            Repeater {
                id: suggestionRepeater
                model: {
                    suggestions.selectedIndex = 0;
                    return root.suggestionList.slice(0, 10);
                }
                delegate: ApiCommandButton {
                    id: commandButton
                    colBackground: suggestions.selectedIndex === index ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colSecondaryContainer
                    bounce: false
                    contentItem: StyledText {
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.m3colors.m3onSurface
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.displayName ?? modelData.name
                    }

                    onHoveredChanged: {
                        if (commandButton.hovered) {
                            suggestions.selectedIndex = index;
                        }
                    }
                    onClicked: {
                        suggestions.acceptSuggestion(modelData.name);
                    }
                }
            }

            function acceptSuggestion(word) {
                const words = messageInputField.text.trim().split(/\s+/);
                if (words.length > 0) {
                    words[words.length - 1] = word;
                } else {
                    words.push(word);
                }
                const updatedText = words.join(" ") + " ";
                messageInputField.text = updatedText;
                messageInputField.cursorPosition = messageInputField.text.length;
                messageInputField.forceActiveFocus();
            }

            function acceptSelectedWord() {
                if (suggestions.selectedIndex >= 0 && suggestions.selectedIndex < suggestionRepeater.count) {
                    const word = root.suggestionList[suggestions.selectedIndex].name;
                    suggestions.acceptSuggestion(word);
                }
            }
        }

        Rectangle { // Input area
            id: inputWrapper
            Layout.fillWidth: true
            implicitHeight: inputColumnLayout.implicitHeight + 12
            radius: Appearance.rounding.normal - root.padding
            color: Appearance.colors.colLayer2
            clip: true

            ColumnLayout {
                id: inputColumnLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 6
                spacing: 6

                AttachedFileIndicator {
                    id: attachedFileIndicator
                    Layout.fillWidth: true
                    filePath: Ai.pendingFilePath
                    onRemove: Ai.attachFile("")
                }

                RowLayout {
                    id: inputQuickRow
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        spacing: 2
                        MouseArea {
                            id: keyStatusHit
                            implicitWidth: 28
                            implicitHeight: 28
                            hoverEnabled: true
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: Ai.currentModelHasApiKey ? "key" : "key_off"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colSubtext
                            }
                            StyledToolTip {
                                text: Ai.currentModelHasApiKey
                                    ? Translation.tr("API key saved (keyring)\nChange with /key or config (ai.*)")
                                    : Translation.tr("No key for this model\nUse /key or config (ai.*)")
                                alternativeVisibleCondition: keyStatusHit.containsMouse
                            }
                        }
                        Rectangle {
                            visible: Ai.currentTool !== "none"
                            implicitWidth: 4
                            implicitHeight: 4
                            radius: 2
                            color: Appearance.colors.colOutlineVariant
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RowLayout {
                            visible: Ai.currentTool !== "none"
                            spacing: 2
                            MaterialSymbol {
                                text: Ai.currentTool === "search" ? "search" : "build"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colSubtext
                            }
                            StyledText {
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                                text: Ai.currentTool === "search" ? Translation.tr("Search") : Translation.tr("Agent")
                            }
                        }
                        Rectangle {
                            implicitWidth: 4
                            implicitHeight: 4
                            radius: 2
                            color: Appearance.colors.colOutlineVariant
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RowLayout {
                            spacing: 2
                            MaterialSymbol {
                                text: "device_thermostat"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colSubtext
                            }
                            StyledText {
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                                text: Ai.temperature.toFixed(1)
                            }
                        }
                        Rectangle {
                            visible: Ai.tokenCount.total > 0
                            implicitWidth: 4
                            implicitHeight: 4
                            radius: 2
                            color: Appearance.colors.colOutlineVariant
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RowLayout {
                            visible: Ai.tokenCount.total > 0
                            spacing: 2
                            MaterialSymbol {
                                text: "token"
                                iconSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colSubtext
                            }
                            StyledText {
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                                text: Ai.tokenCount.total
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RippleButton {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 38
                        buttonRadius: 15
                        buttonText: "/"
                        colBackground: Appearance.colors.colLayer1
                        colBackgroundHover: Appearance.colors.colLayer1Hover
                        onClicked: {
                            messageInputField.text = root.commandPrefix;
                            messageInputField.cursorPosition = messageInputField.text.length;
                            messageInputField.forceActiveFocus();
                        }
                    }

                    RippleButton {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 76
                        buttonRadius: 15
                        buttonText: "/clear"
                        colBackground: Appearance.colors.colLayer1
                        colBackgroundHover: Appearance.colors.colLayer1Hover
                        onClicked: Ai.clearMessages()
                    }
                }

                RowLayout {
                    id: inputFieldRowLayout
                    Layout.fillWidth: true
                    Layout.preferredHeight: 96
                    spacing: 0

                    StyledTextArea { // The actual TextArea
                        id: messageInputField
                        wrapMode: TextArea.Wrap
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        padding: 10
                    color: activeFocus ? Appearance.m3colors.m3onSurface : Appearance.m3colors.m3onSurfaceVariant
                    placeholderText: Translation.tr('Message the model... "%1" for commands').arg(root.commandPrefix)

                    background: null

                    onTextChanged: {
                        // Handle suggestions
                        if (messageInputField.text.length === 0) {
                            root.suggestionQuery = "";
                            root.suggestionList = [];
                            return;
                        } else if (messageInputField.text.startsWith(`${root.commandPrefix}model`)) {
                            root.suggestionQuery = messageInputField.text.split(" ")[1] ?? "";
                            const modelResults = Fuzzy.go(root.suggestionQuery, Ai.modelList.map(model => {
                                return {
                                    name: Fuzzy.prepare(model),
                                    obj: model
                                };
                            }), {
                                all: true,
                                key: "name"
                            });
                            root.suggestionList = modelResults.map(model => {
                                return {
                                    name: `${messageInputField.text.trim().split(" ").length == 1 ? (root.commandPrefix + "model ") : ""}${model.target}`,
                                    displayName: `${Ai.models[model.target].name}`,
                                    description: `${Ai.models[model.target].description}`
                                };
                            });
                        } else if (messageInputField.text.startsWith(`${root.commandPrefix}prompt`)) {
                            root.suggestionQuery = messageInputField.text.split(" ")[1] ?? "";
                            const promptFileResults = Fuzzy.go(root.suggestionQuery, Ai.promptFiles.map(file => {
                                return {
                                    name: Fuzzy.prepare(file),
                                    obj: file
                                };
                            }), {
                                all: true,
                                key: "name"
                            });
                            root.suggestionList = promptFileResults.map(file => {
                                return {
                                    name: `${messageInputField.text.trim().split(" ").length == 1 ? (root.commandPrefix + "prompt ") : ""}${file.target}`,
                                    displayName: `${FileUtils.trimFileExt(FileUtils.fileNameForPath(file.target))}`,
                                    description: Translation.tr("Load prompt from %1").arg(file.target)
                                };
                            });
                        } else if (messageInputField.text.startsWith(`${root.commandPrefix}save`)) {
                            root.suggestionQuery = messageInputField.text.split(" ")[1] ?? "";
                            const promptFileResults = Fuzzy.go(root.suggestionQuery, Ai.savedChats.map(file => {
                                return {
                                    name: Fuzzy.prepare(file),
                                    obj: file
                                };
                            }), {
                                all: true,
                                key: "name"
                            });
                            root.suggestionList = promptFileResults.map(file => {
                                const chatName = FileUtils.trimFileExt(FileUtils.fileNameForPath(file.target)).trim();
                                return {
                                    name: `${messageInputField.text.trim().split(" ").length == 1 ? (root.commandPrefix + "save ") : ""}${chatName}`,
                                    displayName: `${chatName}`,
                                    description: Translation.tr("Save chat to %1").arg(chatName)
                                };
                            });
                        } else if (messageInputField.text.startsWith(`${root.commandPrefix}load`)) {
                            root.suggestionQuery = messageInputField.text.split(" ")[1] ?? "";
                            const promptFileResults = Fuzzy.go(root.suggestionQuery, Ai.savedChats.map(file => {
                                return {
                                    name: Fuzzy.prepare(file),
                                    obj: file
                                };
                            }), {
                                all: true,
                                key: "name"
                            });
                            root.suggestionList = promptFileResults.map(file => {
                                const chatName = FileUtils.trimFileExt(FileUtils.fileNameForPath(file.target)).trim();
                                return {
                                    name: `${messageInputField.text.trim().split(" ").length == 1 ? (root.commandPrefix + "load ") : ""}${chatName}`,
                                    displayName: `${chatName}`,
                                    description: Translation.tr(`Load chat from %1`).arg(file.target)
                                };
                            });
                        } else if (messageInputField.text.startsWith(`${root.commandPrefix}tool`)) {
                            root.suggestionQuery = messageInputField.text.split(" ")[1] ?? "";
                            const toolResults = Fuzzy.go(root.suggestionQuery, Ai.availableTools.map(tool => {
                                return {
                                    name: Fuzzy.prepare(tool),
                                    obj: tool
                                };
                            }), {
                                all: true,
                                key: "name"
                            });
                            root.suggestionList = toolResults.map(tool => {
                                const toolName = tool.target;
                                return {
                                    name: `${messageInputField.text.trim().split(" ").length == 1 ? (root.commandPrefix + "tool ") : ""}${tool.target}`,
                                    displayName: toolName,
                                    description: Ai.toolDescriptions[toolName]
                                };
                            });
                        } else if (messageInputField.text.startsWith(root.commandPrefix)) {
                            root.suggestionQuery = messageInputField.text;
                            root.suggestionList = root.allCommands.filter(cmd => cmd.name.startsWith(messageInputField.text.substring(1))).map(cmd => {
                                return {
                                    name: `${root.commandPrefix}${cmd.name}`,
                                    description: `${cmd.description}`
                                };
                            });
                        }
                    }

                    function accept() {
                        root.handleInput(text);
                        text = "";
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Tab) {
                            suggestions.acceptSelectedWord();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up && suggestions.visible) {
                            suggestions.selectedIndex = Math.max(0, suggestions.selectedIndex - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down && suggestions.visible) {
                            suggestions.selectedIndex = Math.min(root.suggestionList.length - 1, suggestions.selectedIndex + 1);
                            event.accepted = true;
                        } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)) {
                            if (event.modifiers & Qt.ShiftModifier) {
                                // Insert newline
                                messageInputField.insert(messageInputField.cursorPosition, "\n");
                                event.accepted = true;
                            } else {
                                // Accept text
                                const inputText = messageInputField.text;
                                messageInputField.clear();
                                root.handleInput(inputText);
                                event.accepted = true;
                            }
                        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) {
                            // Intercept Ctrl+V to handle image/file pasting
                            if (event.modifiers & Qt.ShiftModifier) {
                                // Let Shift+Ctrl+V = plain paste
                                messageInputField.text += Quickshell.clipboardText;
                                event.accepted = true;
                                return;
                            }
                            // Try image paste first
                            const currentClipboardEntry = Cliphist.entries[0];
                            const cleanCliphistEntry = StringUtils.cleanCliphistEntry(currentClipboardEntry);
                            if (/^\d+\t\[\[.*binary data.*\d+x\d+.*\]\]$/.test(currentClipboardEntry)) {
                                // First entry = currently copied entry = image?
                                decodeImageAndAttachProc.handleEntry(currentClipboardEntry);
                                event.accepted = true;
                                return;
                            } else if (cleanCliphistEntry.startsWith("file://")) {
                                // First entry = currently copied entry = image?
                                const fileName = decodeURIComponent(cleanCliphistEntry);
                                Ai.attachFile(fileName);
                                event.accepted = true;
                                return;
                            }
                            event.accepted = false; // No image, let text pasting proceed
                        } else if (event.key === Qt.Key_Escape) {
                            // Esc to detach file
                            if (Ai.pendingFilePath.length > 0) {
                                Ai.attachFile("");
                                event.accepted = true;
                            } else {
                                event.accepted = false;
                            }
                        }
                    }
                }

                RippleButton { // Send button
                    id: sendButton
                    Layout.alignment: Qt.AlignTop
                    Layout.rightMargin: 5
                    implicitWidth: 40
                    implicitHeight: 40
                    buttonRadius: Appearance.rounding.small
                    enabled: messageInputField.text.length > 0
                    toggled: enabled

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: sendButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            const inputText = messageInputField.text;
                            root.handleInput(inputText);
                            messageInputField.clear();
                        }
                    }

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        iconSize: 22
                        color: sendButton.enabled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer2Disabled
                        text: "arrow_upward"
                    }
                }
            }

            RowLayout { // Model, agent hub, spacer
                id: inputFooterRow
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    id: modelChip
                    radius: height / 2
                    implicitHeight: 34
                    implicitWidth: Math.min(modelChipContent.implicitWidth + 20, inputWrapper.width * 0.5)
                    color: modelChipMa.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
                    border.width: modelPickerPopup.visible ? 1 : 0
                    border.color: Appearance.colors.colPrimary

                    RowLayout {
                        id: modelChipContent
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialSymbol {
                            text: Ai.getModel()?.icon ?? "smart_toy"
                            iconSize: 20
                            color: Appearance.m3colors.m3onSurface
                        }
                        StyledText {
                            Layout.maximumWidth: inputWrapper.width * 0.38
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.m3colors.m3onSurface
                            elide: Text.ElideRight
                            text: Ai.getModel()?.name ?? Translation.tr("Choose model")
                        }
                        MaterialSymbol {
                            text: "expand_more"
                            iconSize: 18
                            color: Appearance.colors.colSubtext
                        }
                    }
                    MouseArea {
                        id: modelChipMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.positionPopupNearInput(modelPickerPopup);
                            modelPickerPopup.open();
                        }
                    }
                }

                Rectangle {
                    id: hubChip
                    radius: height / 2
                    implicitHeight: 34
                    implicitWidth: Math.min(hubChipContent.implicitWidth + 20, inputWrapper.width * 0.42)
                    color: hubChipMa.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer2
                    border.width: agentHubPopup.visible ? 1 : 0
                    border.color: Appearance.colors.colPrimary

                    RowLayout {
                        id: hubChipContent
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialSymbol {
                            text: "widgets"
                            iconSize: 20
                            color: Appearance.m3colors.m3onSurface
                        }
                        ColumnLayout {
                            spacing: 0
                            StyledText {
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                                color: Appearance.m3colors.m3onSurface
                                text: Translation.tr("Tools & skills")
                            }
                            StyledText {
                                font.pixelSize: Appearance.font.pixelSize.smaller - 1
                                color: Appearance.colors.colSubtext
                                text: Ai.currentTool === "search"
                                    ? Translation.tr("Web search")
                                    : (Ai.currentTool === "none" ? Translation.tr("Chat only") : Translation.tr("Agent"))
                            }
                        }
                        MaterialSymbol {
                            text: "expand_more"
                            iconSize: 18
                            color: Appearance.colors.colSubtext
                        }
                    }
                    MouseArea {
                        id: hubChipMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.positionPopupNearInput(agentHubPopup);
                            agentHubPopup.open();
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
    }

    Popup {
        id: modelPickerPopup
        parent: root
        modal: true
        dim: true
        padding: 0
        width: Math.min(400, root.width - 12)
        height: Math.min(root.height * 0.55, 380)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            border.color: Appearance.colors.colOutlineVariant
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            StyledText {
                text: Translation.tr("Models")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
            }
            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                text: Translation.tr("Scroll and tap to switch. Cloud models need a key in illogical-impulse config or /key.")
            }

            StyledListView {
                id: modelPickerList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                popin: false
                model: ScriptModel {
                    values: Ai.modelList
                }
                delegate: Rectangle {
                    required property var modelData
                    width: modelPickerList.width
                    height: Math.max(48, modelDescLine.implicitHeight > 0 ? 56 : 48)
                    radius: Appearance.rounding.small
                    color: rowMa.containsMouse
                        ? Appearance.colors.colLayer2Hover
                        : (modelData === Ai.currentModelId ? Appearance.colors.colSecondaryContainer : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        MaterialSymbol {
                            text: Ai.models[modelData]?.icon ?? "smart_toy"
                            iconSize: 22
                            color: Appearance.m3colors.m3onSurface
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                id: modelTitleLine
                                Layout.fillWidth: true
                                text: Ai.models[modelData]?.name ?? modelData
                                elide: Text.ElideRight
                                font.pixelSize: Appearance.font.pixelSize.small
                            }
                            StyledText {
                                id: modelDescLine
                                Layout.fillWidth: true
                                visible: text.length > 0
                                maximumLineCount: 2
                                wrapMode: Text.WordWrap
                                text: root.shortenModelDescription(modelData)
                                elide: Text.ElideRight
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                        MaterialSymbol {
                            visible: modelData === Ai.currentModelId
                            text: "check"
                            iconSize: 20
                            color: Appearance.colors.colPrimary
                        }
                    }
                    MouseArea {
                        id: rowMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Ai.setModel(modelData, true, true);
                            modelPickerPopup.close();
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: agentHubPopup
        parent: root
        modal: true
        dim: true
        padding: 0
        width: Math.min(420, root.width - 12)
        height: Math.min(root.height * 0.72, 520)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Appearance.colors.colLayer2
            radius: Appearance.rounding.normal
            border.color: Appearance.colors.colOutlineVariant
            border.width: 1
        }

        Flickable {
            id: hubFlick
            anchors.fill: parent
            anchors.margins: 12
            contentWidth: width
            contentHeight: hubColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ColumnLayout {
                id: hubColumn
                width: hubFlick.width
                spacing: 14

                StyledText {
                    text: Translation.tr("Capabilities")
                    font.weight: Font.Medium
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    text: Translation.tr("How the assistant is allowed to act on your system.")
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: root.hubCapabilityModels
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 52
                            radius: Appearance.rounding.small
                            color: capMa.containsMouse ? Appearance.colors.colLayer2Hover : Appearance.colors.colLayer1
                            border.width: Config.options.ai.tool === modelData.id ? 2 : 1
                            border.color: Config.options.ai.tool === modelData.id ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                MaterialSymbol {
                                    text: modelData.icon
                                    iconSize: 22
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    StyledText {
                                        text: modelData.title
                                        font.weight: Font.Medium
                                        font.pixelSize: Appearance.font.pixelSize.small
                                    }
                                    StyledText {
                                        Layout.fillWidth: true
                                        wrapMode: Text.Wrap
                                        text: modelData.sub
                                        font.pixelSize: Appearance.font.pixelSize.smaller
                                        color: Appearance.colors.colSubtext
                                    }
                                }
                            }
                            MouseArea {
                                id: capMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (Ai.setTool(modelData.id))
                                        agentHubPopup.close();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.colOutlineVariant
                }

                StyledText {
                    text: Translation.tr("Prompt skills")
                    font.weight: Font.Medium
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    text: Translation.tr("Load a saved system prompt from disk (same as %1prompt).").arg(root.commandPrefix)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: Ai.promptFiles.length > 0
                    spacing: 4
                    Repeater {
                        model: Ai.promptFiles
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 40
                            radius: Appearance.rounding.small
                            color: skillMa.containsMouse ? Appearance.colors.colLayer2Hover : "transparent"
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                MaterialSymbol {
                                    text: "description"
                                    iconSize: 20
                                    color: Appearance.colors.colSubtext
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    text: FileUtils.trimFileExt(FileUtils.fileNameForPath(modelData))
                                    elide: Text.ElideRight
                                    font.pixelSize: Appearance.font.pixelSize.small
                                }
                            }
                            MouseArea {
                                id: skillMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Ai.loadPrompt(modelData);
                                    agentHubPopup.close();
                                }
                            }
                        }
                    }
                }
                StyledText {
                    visible: Ai.promptFiles.length === 0
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    text: Translation.tr("No prompt files found in the prompts folders.")
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.colOutlineVariant
                }

                StyledText {
                    text: Translation.tr("MCP & extensions")
                    font.weight: Font.Medium
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    text: Translation.tr("Model Context Protocol servers are not wired into this sidebar yet. Built-in tools (config, shell with approval, window info) are available in Agent mode.")
                }
            }
        }
    }
}
