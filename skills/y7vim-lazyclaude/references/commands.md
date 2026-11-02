# lazyclaude.nvim — reference

## Config scopes it manages

Per the upstream README: memory, skills, agents, MCP servers, permissions,
hooks, instructions (`CLAUDE.md` and rules), keybindings, sessions, usage
stats, plugins, and todos — read directly off disk from Claude Code's own
file layout (`~/.claude/`, `.mcp.json`, `skills/`, `agents/`, `commands/`,
`plugins/`, `todos/`, per-project data under `~/.claude/projects/`). It
watches these files, so edits made elsewhere show up live.

## Setup options (all optional, passed to `setup()`)

| Option | Default | Meaning |
|---|---|---|
| `lazyclaude_cmd` | `"lazyclaude"` | path/name of the binary |
| `floating_window_scaling_factor` | `0.9` | window size, 0.1–1.0 |
| `floating_window_winblend` | `0` | transparency, 0–100 |
| `floating_window_border` | `"rounded"` | border style |
| `project_dir` / `claude_dir` | — | override paths passed to the CLI |
| `on_open` / `on_exit` | — | callbacks |

## CLI-only usage (outside Neovim)

```sh
lazyclaude            # launch the TUI directly
lazyclaude --json     # dump all config as JSON
lazyclaude list mcp   # one source as JSON
lazyclaude paths      # show resolved config paths
```
