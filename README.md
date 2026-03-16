# Claude Code Status Line

Custom status line for Claude Code CLI showing:
- **Working directory** — bold blue, basename of the current working directory
- **Context window usage** — color-coded progress bar (green < 70%, yellow 70-89%, red 90%+) showing the **main conversation's** context window usage only
- **Session cost** — total cost in USD including main conversation and all subagent usage
- **Token counts** — cumulative input/output tokens including main conversation and all subagent usage

![Status line example](Example.png)

## Install

```bash
git clone git@github.com:wynandw87/claude-code-statusline.git
cd claude-code-statusline
bash install.sh
```

Restart Claude Code after installing.

## How it works

The status line script receives a JSON payload from Claude Code via stdin containing session metrics. It parses and formats the following:

| Indicator | Scope | Description |
|-----------|-------|-------------|
| Directory | Main session | Basename of the current working directory |
| Context bar | Main session only | Percentage of the main conversation's context window used |
| Cost | Main + subagents | Total session cost in USD across all agents |
| Tokens (in/out) | Main + subagents | Cumulative input and output tokens across all agents |

The context window bar intentionally shows only the main conversation's usage, since each subagent has its own independent context window. The cost and token counters reflect the full session activity including any spawned subagents.

## Requirements

- `node` (for JSON parsing)
- Claude Code CLI
