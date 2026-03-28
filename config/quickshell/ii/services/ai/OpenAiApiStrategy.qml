import QtQuick

/**
 * OpenAI-compatible chat completions (SSE), including tool_calls with delta accumulation.
 * Used for OpenRouter, Groq, Ollama /v1/chat/completions, Mistral, etc.
 */
ApiStrategy {
    id: root
    property bool isReasoning: false
    /// index string -> { id, name, args }
    property var toolCallAcc: ({})

    function buildEndpoint(model: AiModel): string {
        return model.endpoint;
    }

    function mapMessageToOpenAi(message) {
        const hasToolResult = message.toolCallId && message.toolCallId.length > 0
            && message.functionResponse !== undefined
            && message.functionResponse !== null;
        if (hasToolResult) {
            const body = typeof message.functionResponse === "string"
                ? message.functionResponse
                : JSON.stringify(message.functionResponse);
            return {
                "role": "tool",
                "tool_call_id": message.toolCallId,
                "content": body,
            };
        }
        if (message.role === "assistant" && message.openAiToolCalls && message.openAiToolCalls.length > 0) {
            return {
                "role": "assistant",
                "content": message.openAiAssistantContent || "",
                "tool_calls": message.openAiToolCalls,
            };
        }
        return {
            "role": message.role,
            "content": message.rawContent,
        };
    }

    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string) {
        const baseData = {
            "model": model.model,
            "messages": [
                { "role": "system", "content": systemPrompt },
                ...messages.map(m => mapMessageToOpenAi(m)),
            ],
            "stream": true,
            "temperature": temperature,
        };
        if (tools && tools.length > 0)
            baseData.tools = tools;
        return model.extraParams ? Object.assign({}, baseData, model.extraParams) : baseData;
    }

    function buildAuthorizationHeader(apiKeyEnvVarName: string): string {
        return `-H "Authorization: Bearer \$\{${apiKeyEnvVarName}\}"`;
    }

    function mergeToolCallDeltas(deltaArr) {
        if (!deltaArr || deltaArr.length === 0)
            return;
        for (let i = 0; i < deltaArr.length; ++i) {
            const d = deltaArr[i];
            const idx = d.index !== undefined && d.index !== null ? String(d.index) : "0";
            if (!root.toolCallAcc[idx])
                root.toolCallAcc[idx] = { id: "", name: "", args: "" };
            const slot = root.toolCallAcc[idx];
            if (d.id)
                slot.id = d.id;
            if (d.function) {
                if (d.function.name)
                    slot.name += d.function.name;
                if (d.function.arguments)
                    slot.args += d.function.arguments;
            }
        }
    }

    function flushToolCallsToMessage(message) {
        const keys = Object.keys(root.toolCallAcc).sort((a, b) => Number(a) - Number(b));
        if (keys.length === 0)
            return null;

        const toolCallsArr = [];
        let firstInvocation = null;
        for (let k = 0; k < keys.length; ++k) {
            const slot = root.toolCallAcc[keys[k]];
            if (!slot.name || slot.name.length === 0)
                continue;
            let argsObj = {};
            try {
                if (slot.args && slot.args.length > 0)
                    argsObj = JSON.parse(slot.args);
            } catch (e) {
                argsObj = {};
            }
            const argStr = slot.args && slot.args.length > 0 ? slot.args : "{}";
            toolCallsArr.push({
                "id": slot.id || ("call_" + keys[k]),
                "type": "function",
                "function": {
                    "name": slot.name,
                    "arguments": argStr,
                },
            });
            if (!firstInvocation) {
                firstInvocation = {
                    "name": slot.name,
                    "args": argsObj,
                    "id": slot.id || ("call_" + keys[k]),
                };
            }
        }
        root.toolCallAcc = ({});

        if (toolCallsArr.length === 0)
            return null;

        message.openAiToolCalls = toolCallsArr;
        message.functionName = firstInvocation.name;
        return firstInvocation;
    }

    function parseResponseLine(line, message) {
        let cleanData = line.trim();
        if (cleanData.startsWith("data:"))
            cleanData = cleanData.slice(5).trim();

        if (!cleanData || cleanData.startsWith(":"))
            return {};
        if (cleanData === "[DONE]")
            return { "finished": true };

        try {
            const dataJson = JSON.parse(cleanData);

            if (dataJson.error) {
                const errorMsg = `**Error**: ${dataJson.error.message || JSON.stringify(dataJson.error)}`;
                message.rawContent += errorMsg;
                message.content += errorMsg;
                return { "finished": true };
            }

            const choice = dataJson.choices && dataJson.choices[0];
            const delta = choice?.delta;
            const finishReason = choice?.finish_reason;

            if (delta?.tool_calls)
                mergeToolCallDeltas(delta.tool_calls);

            let newContent = "";
            const responseContent = delta?.content || dataJson.message?.content;
            const responseReasoning = delta?.reasoning || delta?.reasoning_content;

            if (responseContent && responseContent.length > 0) {
                if (isReasoning) {
                    isReasoning = false;
                    const endBlock = "\n\n</think>\n\n";
                    message.content += endBlock;
                    message.rawContent += endBlock;
                }
                newContent = responseContent;
                if (!message.openAiAssistantContent)
                    message.openAiAssistantContent = "";
                message.openAiAssistantContent += responseContent;
            } else if (responseReasoning && responseReasoning.length > 0) {
                if (!isReasoning) {
                    isReasoning = true;
                    const startBlock = "\n\n<think>\n\n";
                    message.rawContent += startBlock;
                    message.content += startBlock;
                }
                newContent = responseReasoning;
            }

            message.content += newContent;
            message.rawContent += newContent;

            if (dataJson.usage) {
                return {
                    "tokenUsage": {
                        "input": dataJson.usage.prompt_tokens ?? -1,
                        "output": dataJson.usage.completion_tokens ?? -1,
                        "total": dataJson.usage.total_tokens ?? -1,
                    },
                };
            }

            if (dataJson.done)
                return { "finished": true };

        } catch (e) {
            console.log("[AI] OpenAI: Could not parse line: ", e);
            message.rawContent += line;
            message.content += line;
        }

        return {};
    }

    function onRequestFinished(message) {
        const inv = flushToolCallsToMessage(message);
        if (inv) {
            const dbg = `\n\n[[ Function: ${inv.name}(${JSON.stringify(inv.args)}) ]]\n`;
            message.rawContent += dbg;
            message.content += dbg;
            message.functionCall = { "name": inv.name, "args": inv.args, "id": inv.id };
            return {
                "functionCall": {
                    "name": inv.name,
                    "args": inv.args,
                    "id": inv.id,
                },
            };
        }
        return {};
    }

    function reset() {
        isReasoning = false;
        toolCallAcc = ({});
    }
}
