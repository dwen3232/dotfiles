import type { Plugin } from "@opencode-ai/plugin";
import { renderMermaidASCII } from "beautiful-mermaid";

const MERMAID_BLOCK_REGEX = /```mermaid\n([\s\S]*?)```/g;

export const CodeBlockRenderPlugin: Plugin = async ({ client }) => {
  const log = (
    level: "debug" | "info" | "warn" | "error",
    message: string,
    extra?: Record<string, unknown>,
  ) =>
    client.app.log({
      body: { service: CodeBlockRenderPlugin.name, level, message, extra },
    });

  log("info", "plugin loaded");

  const renderMermaidCodeBlocks = (input: string): string => {
    return input.replace(
      MERMAID_BLOCK_REGEX,
      (_match, mermaidBlock: string) => {
        try {
          const asciiBlock = renderMermaidASCII(mermaidBlock, {
            // Opencode doesn't support ansi colors or true color
            colorMode: "none",
            useAscii: false,
          });
          log("debug", "rendered mermaid block");
          return "```\n" + asciiBlock + "\n```";
        } catch (e) {
          log("warn", "failed to render mermaid block, leaving as-is", {
            error: String(e),
          });
          return "```mermaid\n" + mermaidBlock + "\n```";
        }
      },
    );
  };

  return {
    "experimental.text.complete": async (_input, output) => {
      output.text = renderMermaidCodeBlocks(output.text);
    },
  };
};
