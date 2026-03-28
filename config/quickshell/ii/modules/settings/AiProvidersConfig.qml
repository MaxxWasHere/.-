import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root
    forceWidth: true

    readonly property bool localAiOnly: Config.options.policies.ai === 2

    property var modelPickerOptions: {
        const ids = Ai.modelList || [];
        const out = [];
        for (let i = 0; i < ids.length; ++i) {
            const id = ids[i];
            const m = Ai.models[id];
            out.push({
                value: id,
                displayName: m ? m.name : id,
                icon: (m && m.icon) ? m.icon : "smart_toy"
            });
        }
        return out;
    }

    Component.onCompleted: KeyringStorage.fetchKeyringData()

    ContentSection {
        icon: "neurology"
        title: Translation.tr("Sidebar AI assistant")
        subtitle: Translation.tr("Keys are stored in your system keyring (secret-tool), not in plain text in config. Pick a default model and tool mode here; switch models anytime from the sidebar.")

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            visible: root.localAiOnly
            color: Appearance.colors.colSubtext
            text: Translation.tr("Privacy mode is on (policies.ai = 2): only local and Ollama-style endpoints are listed. Cloud keys below are hidden.")
        }
    }

    ContentSection {
        icon: "vpn_key"
        title: Translation.tr("Cloud provider keys")
        subtitle: Translation.tr("Paste each provider’s secret key, then Save. Use “Get key” to open their console. Extra models (OpenRouter, Bedrock, …) can be added under ai.extraModels in the shell config.")

        ColumnLayout {
            Layout.fillWidth: true
            visible: !root.localAiOnly
            spacing: 20

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Google & chat APIs")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSecondaryContainer
            }

            ApiKeyRow {
                rowKeyId: "gemini"
                rowLabel: Translation.tr("Google Gemini")
                rowHint: Translation.tr("Native Gemini API (not OpenAI-compatible).")
                rowLink: "https://aistudio.google.com/app/apikey"
            }
            ApiKeyRow {
                rowKeyId: "openai"
                rowLabel: Translation.tr("OpenAI")
                rowHint: Translation.tr("Official API key for api.openai.com and compatible proxies.")
                rowLink: "https://platform.openai.com/api-keys"
            }
            ApiKeyRow {
                rowKeyId: "mistral"
                rowLabel: Translation.tr("Mistral AI")
                rowHint: Translation.tr("Mistral chat API.")
                rowLink: "https://console.mistral.ai/api-keys"
            }

            StyledText {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: Translation.tr("Routers & fast inference")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSecondaryContainer
            }

            ApiKeyRow {
                rowKeyId: "openrouter"
                rowLabel: Translation.tr("OpenRouter")
                rowHint: Translation.tr("One key for many models; billing on OpenRouter.")
                rowLink: "https://openrouter.ai/settings/keys"
            }
            ApiKeyRow {
                rowKeyId: "groq"
                rowLabel: Translation.tr("Groq")
                rowHint: Translation.tr("GroqCloud LPU inference.")
                rowLink: "https://console.groq.com/keys"
            }
            ApiKeyRow {
                rowKeyId: "together"
                rowLabel: Translation.tr("Together AI")
                rowHint: Translation.tr("Together-hosted open models.")
                rowLink: "https://api.together.ai/settings/api-keys"
            }
            ApiKeyRow {
                rowKeyId: "xai"
                rowLabel: Translation.tr("xAI (Grok)")
                rowHint: Translation.tr("xAI console API key.")
                rowLink: "https://console.x.ai/"
            }

            StyledText {
                Layout.fillWidth: true
                Layout.topMargin: 4
                text: Translation.tr("Hyperscalers")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnSecondaryContainer
            }

            ApiKeyRow {
                rowKeyId: "bedrock"
                rowLabel: Translation.tr("AWS Bedrock")
                rowHint: Translation.tr("Use where Bedrock exposes an OpenAI-compatible route; region and model id must match your account (SigV4 may require a proxy).")
                rowLink: "https://console.aws.amazon.com/bedrock/"
            }
        }
    }

    ContentSection {
        icon: "dns"
        title: Translation.tr("Ollama (local models)")
        subtitle: Translation.tr("Ollama serves an OpenAI-compatible /v1/chat/completions URL. Set the host if Ollama runs on another PC; then refresh so the sidebar model list updates.")

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("http://localhost:11434")
            text: Config.options.ai.ollama.baseUrl
            onTextChanged: {
                Qt.callLater(() => {
                    Config.options.ai.ollama.baseUrl = text;
                });
            }
        }

        RippleButtonWithIcon {
            materialIcon: "refresh"
            mainText: Translation.tr("Scan for Ollama models again")
            onClicked: Ai.refreshOllamaModels()
        }
    }

    ContentSection {
        icon: "tune"
        title: Translation.tr("Default chat behavior")
        subtitle: Translation.tr("These apply to new messages. Temperature is remembered per device. Tool mode “Agent” enables shell/config tools; “Web search” only applies to Gemini.")

        ConfigSelectionArray {
            Layout.fillWidth: true
            currentValue: Config.options.ai.tool
            onSelected: newValue => {
                Config.options.ai.tool = newValue;
            }
            options: [
                { value: "functions", displayName: Translation.tr("Agent (tools)"), icon: "build" },
                { value: "search", displayName: Translation.tr("Web search"), icon: "search" },
                { value: "none", displayName: Translation.tr("No tools"), icon: "block" },
            ]
        }

        ConfigSpinBox {
            icon: "device_thermostat"
            text: Translation.tr("Temperature (randomness)")
            value: Persistent.states.ai.temperature
            from: 0
            to: 2
            stepSize: 0.1
            onValueChanged: {
                Persistent.states.ai.temperature = value;
                Ai.temperature = value;
            }
        }

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            visible: root.modelPickerOptions.length > 0
            color: Appearance.colors.colSubtext
            text: Translation.tr("Model to use when the sidebar opens (you can still change it from the chat header).")
        }

        ConfigSelectionArray {
            Layout.fillWidth: true
            visible: root.modelPickerOptions.length > 0
            currentValue: Persistent.states.ai.model
            onSelected: newValue => {
                Ai.setModel(String(newValue), false, true);
            }
            options: root.modelPickerOptions
        }
    }

    ContentSection {
        icon: "edit_note"
        title: Translation.tr("Instructions for the AI (system prompt)")
        subtitle: Translation.tr("Persistent personality and rules. Placeholders like {DISTRO} are filled automatically.")

        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("How the assistant should behave…")
            text: Config.options.ai.systemPrompt
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Qt.callLater(() => {
                    Config.options.ai.systemPrompt = text;
                });
            }
        }
    }

    ContentSection {
        icon: "folder_special"
        title: Translation.tr("Advanced: config file")
        subtitle: Translation.tr("Custom endpoints and model ids live in JSON. Prefer editing when adding rare providers or fixing Bedrock regions.")

        StyledText {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: Translation.tr("File path:\n%1").arg(Config.filePath)
            textFormat: Text.PlainText
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
        }

        RippleButtonWithIcon {
            materialIcon: "draft"
            mainText: Translation.tr("Open config in default editor")
            onClicked: Quickshell.execDetached(["xdg-open", Config.filePath])
        }
    }

    component ApiKeyRow: ColumnLayout {
        property string rowKeyId: ""
        property string rowLabel: ""
        property string rowHint: ""
        property string rowLink: ""

        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                StyledText {
                    text: rowLabel
                    font.weight: Font.Medium
                }
                StyledText {
                    visible: rowHint.length > 0
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: rowHint
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }
            RippleButtonWithIcon {
                materialIcon: "open_in_new"
                mainText: Translation.tr("Get key")
                visible: rowLink.length > 0
                onClicked: Qt.openUrlExternally(rowLink)
            }
            StyledText {
                color: Appearance.colors.colSubtext
                text: (KeyringStorage.keyringData.apiKeys?.[rowKeyId] || "").length > 0
                    ? Translation.tr("Saved")
                    : Translation.tr("Empty")
            }
        }

        MaterialTextField {
            id: keyInput
            Layout.fillWidth: true
            echoMode: TextInput.Password
            placeholderText: Translation.tr("Paste secret key…")
        }

        RippleButtonWithIcon {
            materialIcon: "save"
            mainText: Translation.tr("Save to keyring")
            onClicked: {
                const t = keyInput.text.trim();
                if (t.length > 0)
                    KeyringStorage.setNestedField(["apiKeys", rowKeyId], t);
            }
        }
    }
}
