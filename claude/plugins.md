# Claude Code Plugins

`claude/settings.json` (symlinked to `~/.claude/settings.json`) already declares
the `omc` marketplace and enables the plugins below, so they load on first launch.
To add or manage them manually, use the `/plugin` command in Claude Code.

| Plugin | Marketplace | Purpose |
|---|---|---|
| `oh-my-claudecode` | `omc` | Multi-agent orchestration (autopilot, ralph, ralplan, team) |
| `claude-code-setup` | `claude-plugins-official` | Machine setup workflows |
| `claude-md-management` | `claude-plugins-official` | CLAUDE.md lifecycle management |

## Install steps

1. Open Claude Code
2. Add the omc marketplace: `/plugin marketplace add Yeachan-Heo/oh-my-claudecode`
3. Install plugins:
   - `/plugin install oh-my-claudecode@omc`
   - `/plugin install claude-code-setup@claude-plugins-official`
   - `/plugin install claude-md-management@claude-plugins-official`
4. Run `setup omc` to initialise oh-my-claudecode (writes CLAUDE.md)

`/plugin` (no args) opens the interactive plugin manager if you prefer a UI.
