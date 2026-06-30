# Open Questions

## Dotfiles Modernization - 2026-06-30

### Resolved (user decisions, this revision)
- [x] Shell fate: **fish-exclusive** — delete `zshrc`, port env/aliases to fish (Phase 0).
- [x] Runtime manager: **mise** (not fnm) — covers node/go/python/java (ADR-4).
- [x] Prompt: starship is a **new fish integration** — `graf009/fish_prompt.fish` is the stock default, not custom (ADR-3).
- [x] Git history scrub: **accepted, not rewritten** — affiliation in history is a documented, deliberate decision.

### Still open
- [ ] Which installed tools to drop vs keep (siege, sloccount, telnet, lima)? — Needed to finalize Brewfile curation in Phase 2.
- [x] Which global runtime versions should mise pin? — **Resolved:** `node = "lts"`, `go = "latest"` committed in `mise/config.toml` (required, dotbot-linked). java/python deferred to follow-up.
- [ ] Adopt XDG `~/.config` layout now or defer? — Affects dotbot target paths and number of files moved.
- [ ] Adopt atuin for shell history (ai/env inspiration)? — Adds a tool + shell init; in or out of scope for this pass.
- [ ] Should `macos-defaults.sh` carry more than dock `no-bouncing` (key-repeat, finder prefs)? — Affects Phase 2 script scope.
