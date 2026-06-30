# Dotfiles Modernization Plan `[approved — ready for execution]`

Mode: CONSENSUS / RALPLAN-DR (SHORT). Owner: @orlovoleg. Target repo: `~/project/public/dotfiles` (public).

> **Final revision (APPROVE verdict).** All Critic issues resolved across three review passes: zoxide/cdpath contradiction fixed, all phase numbering corrected (0:1-5, 1:1-8, 2:1-4, 3:1-8, 4:1-6, 5:1-4), gpg.fish + postgres.fish added to dead-tool audit, settings.json2 typo and ripgreprc symlink path added as explicit Phase 1 tasks, maven added to Brewfile, yandex browser added to Dropped, Open Questions cleaned to 3 genuinely open items, conf.d loading order documented in Phase 3.

---

## User Decisions (open questions resolved)

1. **Shell fate — fish-exclusive.** `zshrc` is deleted entirely. All env/aliases are ported to fish. No zsh fallback is kept.
2. **History scrub — accepted, not rewritten.** Employer affiliation in the existing git history (and the `oorlov@alfabank.ru` identity it reveals) is accepted as-is. We do **not** rewrite history. This is a documented, deliberate decision (see Principle 5 and the Phase 5 note).
3. **Runtime manager — `mise`.** One tool manages node, go, python, and java. Chosen over `fnm` because `fnm` is node-only and this user runs Go and JVM/maven workloads too (see revised ADR-4).

---

## RALPLAN-DR Summary

### Principles (5, revised)
1. **Fish-exclusive: zsh is deleted; fish is the only shell config.** No config is duplicated across shells because only one shell is configured.
2. **Maintained tools only.** Every binary in the dotfiles must be actively maintained in 2026. Dead tools are dropped, not symlinked.
3. **Declarative & reproducible.** A fresh Mac should reach a working state from `git clone` + one bootstrap command, with no manual brew incantations and no manual `defaults write`.
4. **Reduced maintenance surface (lighter tools, not necessarily fewer by count).** Prefer lighter mechanisms over heavyweight frameworks: Ansible -> Brewfile + a small `defaults` script, omf -> fisher, antigen -> (gone with zsh). Net tool *headcount* may be similar; the *maintenance weight* (extra runtimes, framework upgrades, plugin churn) goes down.
5. **Safe for a public repo (files only).** No work email as the committed default identity, no hardcoded personal absolute paths, no private cloud config committed. Git **history** is accepted as-is per the user decision — this principle governs the working tree, not the past.

### Decision Drivers (top 3)
1. **Reduce maintenance surface** — the repo rotted in 2 years partly because it ran too many overlapping systems (Ansible + 2 install scripts + omf + antigen + 4 gitconfigs + 2 shells).
2. **Correctness/safety of a public repo** — wrong default git identity, leaked absolute paths, and an unguarded `source` that breaks a fresh shell are the highest-severity issues.
3. **Reproducibility on a fresh Mac** — the bootstrap must work end-to-end. Today it fails on the first step (the brew installer calls a removed Ruby method) and silently loses macOS `defaults` that Ansible used to apply.

### Viable Options

**Option A — Incremental modernization (RECOMMENDED).**
Keep dotbot as the symlink manager. Go fish-exclusive (delete zsh). Replace package management (Ansible -> Brewfile + `macos-defaults.sh`), plugin manager (omf -> fisher), runtime pinning (`node@18` -> `mise`), and dead tools (exa->eza, dog->doggo). Consolidate gitconfigs. Phase the work behind a Phase 0 gate.
- Pros: Low risk; each phase independently verifiable; preserves working `graf009/` fish functions and dotbot wiring; reversible on a branch.
- Cons: dotbot submodule remains a dependency; Phase 0 must complete first or later phases inherit broken shell state.

**Option B — Greenfield rewrite (chezmoi/GNU stow + from-scratch fish).**
Replace dotbot with chezmoi/stow, rewrite fish config from a clean template, drop zsh.
- Pros: Cleanest end state; chezmoi templating handles machine-specific values/secrets natively; smallest long-term surface.
- Cons: High effort/risk; discards working `graf009/` functions; learning curve; over-scoped for "make a 2-year-stale repo modern."

**Option C — Minimal triage only.**
Fix only the breakage (brew installer, exa->eza, runtime, git default identity) and stop.
- Pros: Fastest; near-zero risk.
- Cons: Leaves the structural rot (Ansible, omf, antigen, 2 shells, 4 gitconfigs) that caused staleness; we'd be back here in 2 years. Rejected as the primary path, but its fixes are folded into Phase 1.

**Decision: Option A.** It hits all three drivers without the risk/over-scope of B. B's best idea (declarative machine-specific values) is partially captured by Brewfile + a gitignored local-override file, deferred as a follow-up rather than a rewrite.

---

## Context

A 2-year-stale personal dotfiles repo for a Mac dev who also does infra (k8s/helm), prefers **fish**, uses **pnpm**, and juggles work + public git identities. The repo runs three overlapping provisioning systems (dotbot symlinks, Ansible roles, two `install-*.sh` scripts), two shell ecosystems (fish via omf, zsh via antigen), four gitconfig files (the default-identity one points at a work email; a better `gitconfigV2` exists but is not symlinked), and several unmaintained CLI tools. Daily-driver casks/formulae (helm, kubernetes-cli, lens, wezterm, obsidian, etc.) are installed on the machine but not tracked, so a fresh Mac would not reproduce the current environment. The current `fish/config.fish` hardcodes `node@18`, and `zshrc` ends with an unconditional `source` of a private Yandex Cloud completion file that does not exist on a fresh Mac.

## Work Objectives
1. Make a fresh-Mac bootstrap actually work and be reproducible (packages **and** macOS defaults).
2. Collapse overlapping provisioning systems to: **dotbot (symlinks) + Brewfile (packages) + macos-defaults.sh (system prefs) + fisher (fish plugins)**.
3. Replace all unmaintained tooling with maintained equivalents; manage runtimes with `mise`.
4. Make the repo safe and correct as a public artifact (git identity matrix, no leaked paths, no unguarded sources).
5. Track the tools actually in use (infra + GUI) so the repo matches reality.

## Guardrails

**Must Have**
- Fresh `git clone` + documented bootstrap reaches a working **fish** shell with no manual edits.
- Public/open-source email (`mail@orlovoleg.com`) is the default git identity + signing key; work/podeli identities are opt-in via `includeIf`.
- A single canonical gitconfig (the `gitconfigV2` content), conditionally including work/podeli/public identities.
- No hardcoded `/Users/orlovoleg/...` absolute paths and no unguarded `source` of a non-existent file in committed shell config.
- Every formula/cask in the Brewfile is currently maintained.
- macOS `defaults` previously applied by Ansible are reproduced by a committed, idempotent script.
- All deletions reversible (work on a branch; nothing force-pushed).

**Must NOT Have**
- No `zshrc`, no antigen, no `install-zsh-stuff.sh` (fish-exclusive).
- No work email committed as the global default.
- No Yandex Cloud / private cloud SDK paths hardcoded in committed files (gitignore a local override instead).
- No simultaneous omf + fisher.
- No rewrite of working `graf009/*.fish` functions unless a function is itself broken.
- No new symlink manager (keep dotbot) in this plan.
- No git **history** rewrite (accepted per user decision).

---

## Phased Implementation

### Phase 0 — Resolve the foundation: port zshrc to fish, then delete zsh (HARD GATE)
**This phase must complete before any other phase.** Rationale: `zshrc:85` is an *unconditional* `source /Users/orlovoleg/yandex-cloud/completion.zsh.inc` with no `[ -f ]` guard — on a fresh Mac that line aborts shell init. Going fish-exclusive removes the file entirely, which is why this gate comes first: every later phase assumes a single, working shell. (See Phase 1 note — `zshrc:85` becomes moot here, not in Phase 1.)

Port the following from `zshrc` into fish before deleting it. Target a new `fish/conf.d/env.fish` (auto-sourced) for env, and fish functions/abbreviations for aliases:

1. **Env vars -> `fish/conf.d/env.fish`:**
   - `EDITOR=micro` -> `set -gx EDITOR micro`
   - `RIPGREP_CONFIG_PATH=~/.ripgreprc` -> `set -gx RIPGREP_CONFIG_PATH ~/.config/ripgreprc`
   - `PNPM_HOME="~/.local/share/pnpm"` + PATH prepend -> `set -gx PNPM_HOME ~/.local/share/pnpm` then `fish_add_path $PNPM_HOME`
   - `GOPATH=$HOME/go` + `$GOROOT/bin` + `$GOPATH/bin` on PATH -> `set -gx GOPATH $HOME/go`; `fish_add_path $GOPATH/bin`; add `$GOROOT/bin` only if `GOROOT` is set (`mise` will own Go; keep this guarded).
   - `ELECTRON_TRASH=gio` -> `set -gx ELECTRON_TRASH gio`
   - `~/.local/bin` on PATH -> `fish_add_path ~/.local/bin`
   - **From ai/env:** `set -gx NODE_COMPILE_CACHE ~/.cache/node` (V8 compile cache — ускоряет запуск Node.js)
   - **From ai/env:** `set -gx BAT_THEME ansi` (тема bat, работает в любом терминале)
   - **From ai/env:** `if test -d ~/.local/share/claude; set -gx CLAUDE_CONFIG_DIR ~/.local/share/claude; end` (XDG-совместимый путь конфига Claude)
2. **Navigation — zoxide replaces cdpath:** Do NOT port `cdpath`. `zoxide init fish | source` (wired in Phase 3) learns directories automatically. Add `abbr --add cd z` in `aliases.fish` for muscle-memory migration. No `set -gx cdpath` anywhere in committed files.
3. **Aliases -> fish functions/abbreviations** (in `fish/conf.d/aliases.fish` or as `graf009` functions):
   - `g=git`, `..=cd ..`, `e=code .`
   - `l=eza --all`, `ll=eza --long --all --git` (note: **eza**, not exa — see Phase 1)
   - `cat=bat`
   - `n=pnpm`, and the pnpm family: `pui`, `pu`, `ptr`, `p`, `pui1`, `pu1` (port verbatim from `zshrc:61-67`).
   - Reconcile with existing `graf009/exa.fish` which defines `ls` as `exa $argv` -> update to `eza`.
4. **Private Yandex Cloud completion:** do **not** port the unconditional `source`. fish already has the right pattern at `config.fish:9` (`test -r ~/.fish.env; and ...`). If yc completion is wanted, source it guarded: `test -r ~/.config/local/yandex.fish; and source ~/.config/local/yandex.fish` — and that file is gitignored, never committed.
5. **Remove zsh from provisioning:**
   - Delete the `~/.zshrc: zshrc` link from `install.conf.yaml` (line 17).
   - Remove the `./install-zsh-stuff.sh` shell step from `install.conf.yaml` (line 42) and **delete `install-zsh-stuff.sh`**.
   - `rm zshrc`.

**Acceptance (Phase 0):**
- `zshrc` and `install-zsh-stuff.sh` no longer exist; `git ls-files | grep -E '^(zshrc|install-zsh-stuff.sh)$'` is empty.
- `install.conf.yaml` contains no `zshrc` link and no `install-zsh-stuff.sh` step; `grep -n zsh install.conf.yaml` is empty.
- Opening a fresh fish shell after relinking sets `EDITOR`, `RIPGREP_CONFIG_PATH`, `PNPM_HOME`, `GOPATH`, and PATH entries correctly: `echo $EDITOR` -> `micro`; `echo $PNPM_HOME` resolves; `string match -q '*pnpm*' $PATH`.
- Every alias resolves as a fish function: `type g l ll cat n pui` all succeed.
- No `/Users/orlovoleg` literal and no unguarded `source` remains in any committed shell file: `grep -rn "/Users/orlovoleg" fish/` is empty.

### Phase 1 — Fix remaining breakage (brew installer, exa->eza, git default identity)
With zsh gone, the highest-severity working-tree bugs remain in brew + tooling.
1. Rewrite `install-brew-stuff.sh` to the current Homebrew installer: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`; drop the removed `/usr/bin/ruby -e` method (`install-brew-stuff.sh:4`). Drop the `brew install ansible` line (Ansible is removed in Phase 2).
2. Replace `exa` with `eza` everywhere: `graf009/exa.fish` (`ls` function), the ported `l`/`ll` aliases, and any docs. `grep -rin exa .` should return only `eza` (and the filename `exa.fish`, which we rename to `eza.fish`).
3. **Replace `ripgreprc`** — current file only has `--plain`; replace with config from ai/env:
   ```
   --smart-case
   --hidden
   --glob=!.git/
   --glob=!.yarn/
   --no-heading
   ```
4. Replace the hardcoded `node@18` PATH line in `fish/config.fish:17` (`fish_add_path /opt/homebrew/opt/node@18/bin`) with `mise` activation (wired fully in Phase 3): remove the node@18 line now so it is not left dangling. Note: mise is not yet active at this phase; node on PATH will be absent until Phase 3 completes. This gap is bounded to a single work session on the executor's own machine — no production system is affected.
5. **Git default identity (matrix detailed in Phase 4):** the immediate fix is that the canonical base config's default `[user]` must be the **public** identity (`mail@orlovoleg.com`, signingkey `9C9FAD2FF0B1F7CE`), not the current `o.orlov@podeli.ru` default in `gitconfig`/`gitconfigV2`. Full consolidation lands in Phase 4; this phase just flags it as the highest-severity public-safety bug.
6. **Fix `install.conf.yaml` typo:** `~/.config/Code/User/settings.json2: vscode.json` → `~/.config/Code/User/settings.json: vscode.json`.
7. **Fix ripgreprc symlink path:** update `install.conf.yaml` link from `~/.ripgreprc: ripgreprc` to `~/.config/ripgreprc: ripgreprc` — must match `RIPGREP_CONFIG_PATH=~/.config/ripgreprc` set in `env.fish` (Phase 0). Without this change `rg` ignores the config on a fresh machine.
8. **`zshrc:85` — documented as moot.** The unguarded `source /Users/orlovoleg/yandex-cloud/completion.zsh.inc` (no `[ -f ]` guard) was the reason Phase 0 had to run first. After Phase 0 deletes `zshrc`, this is a non-issue. No action here beyond recording why the ordering mattered.

**Acceptance (Phase 1):**
- `bash install-brew-stuff.sh` runs without the Ruby error on a clean shell (dry-read the script; do not require a real reinstall).
- `grep -rin exa .` returns only `eza`/`eza.fish`.
- No `node@18` reference remains: `grep -rn 'node@18' fish/` is empty.
- `fish/config.fish` no longer hardcodes a node path.
- `grep 'settings.json' install.conf.yaml` returns `settings.json` (no trailing `2`).
- `grep 'ripgreprc' install.conf.yaml` shows `~/.config/ripgreprc: ripgreprc` (XDG path).

### Phase 2 — Ansible -> Brewfile + macos-defaults.sh
Replace Ansible (3 roles) + the package logic in `install-brew-stuff.sh` with one declarative `Brewfile`, **and** reproduce the macOS `defaults` Ansible used to set (Brewfile is packages-only — `osx_defaults` from `ansible/roles/productivity/tasks/main.yml` would otherwise be lost).
1. Generate `Brewfile` from real state via `brew bundle dump --describe`, then curate per the confirmed lists below.

**Confirmed Brewfile contents:**

```ruby
# --- taps ---
tap "homebrew/bundle"

# --- shell & prompt ---
brew "fish"
brew "starship"
brew "fisher"         # installed via script, listed for reference

# --- runtime manager ---
brew "mise"           # node/go/java — replaces node@18, openjdk, go formulae

# --- modern unix replacements ---
brew "eza"            # replaces exa (unmaintained)
brew "bat"
brew "ripgrep"
brew "fd"
brew "git-delta"
brew "xh"             # replaces httpie (faster, Rust, compatible syntax)
brew "doggo"          # replaces dog (unmaintained)

# --- git & signing ---
brew "git"
brew "gh"
brew "bfg"            # git history cleanup (also: git filter-repo is the modern alt)

# --- editors & tools ---
brew "micro"
brew "pv"
brew "tree"
brew "mas"            # App Store CLI

# --- network / infra diagnostics ---
brew "mtr"
brew "nmap"
brew "iperf3"

# --- infra / k8s ---
brew "kubernetes-cli"
brew "helm"
brew "k9s"
brew "kubectx"        # быстрое переключение k8s контекстов (kubectx + kubens)
brew "stern"          # multi-pod log tailing по label
brew "terraform"      # IaC для Яндекс Облака и других провайдеров
brew "ansible-lint"   # linter for Ansible files (work requirement)
brew "asimov"         # excludes node_modules/.git from Time Machine

# --- dev tooling ---
brew "hadolint"       # Dockerfile linter
brew "yamllint"
brew "jsonlint"
brew "jq"             # JSON процессор — незаменим для infra/API работы
brew "yq"             # YAML процессор (как jq для YAML/k8s манифестов)
brew "fzf"            # fuzzy finder — интегрируется с fish, atuin, git
brew "zoxide"         # умный cd — учится куда ты ходишь, заменяет cdpath
brew "lazygit"        # TUI для git — staging по хункам, интерактивный rebase
brew "dive"           # Docker image layer analysis
brew "sqlite"
brew "mmctl"          # Mattermost CLI
brew "atuin"          # shell history — fuzzy search, SQLite, cross-machine sync
brew "maven"          # Java build tool — mise manages JVM runtime, maven is separate

# --- security ---
brew "openssl@3"

# --- fonts ---
cask "font-martian-mono"
cask "font-sauce-code-pro-nerd-font"

# --- terminal & editors ---
cask "kitty"
cask "visual-studio-code"

# --- infra GUI ---
cask "headlamp"       # CNCF k8s GUI, replaces Lens
cask "dbeaver-community"

# --- tunneling ---
cask "cloudflared"    # replaces ngrok — free, permanent URLs, Cloudflare network

# --- Yandex Cloud ---
cask "yandex-cloud-cli"   # yc CLI — управление Яндекс Облаком (cask, installer-based)

# --- productivity ---
cask "obsidian"

# --- communication ---
cask "telegram"
cask "zoom"

# --- media ---
cask "spotify"
cask "vlc"

# --- security / privacy ---
cask "bitwarden"      # NOTE: use App Store version; cask here only as fallback reference
cask "cryptomator"

# --- IoT / infra ---
cask "mqtt-explorer"

# --- hardware / hobby ---
cask "arduino-ide"
cask "betaflight-configurator"
cask "raspberry-pi-imager"
cask "android-platform-tools"

# --- crypto ---
cask "ledger-wallet"

# --- App Store (via mas) ---
mas "Bitwarden",          id: 1352778147   # primary — App Store version preferred
mas "Mattermost",         id: 1614666244
mas "Windows App",        id: 1295203466   # Microsoft Remote Desktop
mas "Tomato One",         id: 907364780
```

**Dropped (confirmed):** ansible, lima, dog, exa, httpie, gnupg, pinentry-mac, lens, ngrok, alfred, firefox, github (Desktop), surfshark, notion, microsoft-office, temurin@8, wezterm, ledger-live, p7zip, siege, sloccount, telnet, zsh, node@18, go (formula), openjdk (formula), yandex (browser cask — not needed).

**Bitwarden:** App Store version is primary (`mas`); cask entry kept as reference only — do not install both simultaneously.
2. **Add `macos-defaults.sh`** — a committed, idempotent script of `defaults write` commands, invoked from bootstrap. It must reproduce the only `osx_defaults` Ansible set: `defaults write com.apple.dock no-bouncing -bool true`. Structure it so future tweaks are one-liners; guard with a comment block and re-running is safe (idempotent by nature of `defaults write`). Optionally `killall Dock` at the end.
3. Delete the `ansible/` tree and `run-ansible.sh`; update `install.conf.yaml` (replace the `run-ansible.sh` shell step with `brew bundle install` + `./macos-defaults.sh`) and `README`.
4. **Rollback safety for cleanup:** if `brew bundle cleanup` is ever used to prune untracked formulae, run it **dry-run first** (`brew bundle cleanup` with no flag, which only lists) and review before `brew bundle cleanup --force`. Document this in README; do not put `--force` in any bootstrap script.

**Acceptance (Phase 2):**
- `brew bundle check --file=Brewfile` passes on the current machine.
- `ansible/` and `run-ansible.sh` are removed; `grep -rni ansible install.conf.yaml install-brew-stuff.sh README.md` is empty.
- `macos-defaults.sh` exists, is executable, contains the `no-bouncing` default, and is idempotent (running twice produces no error and no change on the second run).
- `install.conf.yaml` bootstrap calls `brew bundle install` and `./macos-defaults.sh`; README documents both.
- No unmaintained formula remains in the Brewfile.

### Phase 3 — omf -> fisher; starship as a new fish integration; mise for runtimes
1. Introduce `fish/fish_plugins` (fisher manifest) and a bootstrap step that installs fisher.
2. Remove `fish/omf/`; drop the `~/.config/omf: fish/omf` link (`install.conf.yaml:24`) and the two omf install shell steps (`install.conf.yaml:40-41`). Keep and audit `fish/graf009/*.fish`; port any function that depended on omf. **graf009 dead-tool audit — explicit entries:**
   - `dog.fish` — **update:** the `dog` binary is removed; update the alias to point to `doggo` (doggo is in the Brewfile).
   - `lima.fish` — **delete:** the `lima` binary is removed in Phase 2, so the `docker -> lima nerdctl` alias becomes broken; delete the function.
   - `gpg.fish` — **delete:** `gnupg` is removed from the Brewfile in Phase 2; this function calls a missing binary after removal. Delete the function.
   - `postgres.fish` — **delete:** `libpq`/`psql` is not in the Brewfile; function will silently fail on a fresh machine. Delete the function (or add `brew "libpq"` if psql access is needed).
3. **Starship in fish — new integration (not a swap).** The current `fish/graf009/fish_prompt.fish` is the *stock fish default prompt*, not a bespoke custom prompt; there is nothing custom to preserve. Starship is justified on its own merits: (a) consistency with the prompt config the user already runs, (b) a single prompt config file (`starship.toml`) for the one shell, (c) starship is already installed and configured. Concrete task: add `starship init fish | source` to `fish/config.fish` and remove `graf009/fish_prompt.fish`.
   - **From ai/env:** add `$container` module to `starship.toml` format string — shows when inside a container (useful for infra work).
4. **Add `fish/functions/release.fish`** — npm publish function ported from ai/env:
   ```fish
   function release
       set VERSION (grep -oP '(?<="version": ")[^"]*' package.json)
       git add .
       git commit -S -m "Release $VERSION"
       git tag -s $VERSION -m $VERSION
       git push
   end
   ```
5. **Add `sshconfig`** (new file, dotbot-linked to `~/.ssh/config`):
   ```
   Host *
       ForwardAgent no
       AddKeysToAgent yes
       ServerAliveInterval 3
       GSSAPIAuthentication no
       IdentityFile ~/.ssh/id_ed25519

   Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_ed25519

   Host 127.0.0.1
       StrictHostKeyChecking no
       UserKnownHostsFile=/dev/null
   ```
6. **Add `pnpm/config.yaml`** (new file, dotbot-linked to `~/.config/pnpm/config.yaml`), from ai/env — security + XDG:
   ```yaml
   blockExoticSubdeps: true
   minimumReleaseAge: 1440   # не использовать пакеты < 24ч после публикации
   storeDir: ~/.local/share/pnpm/store
   trustPolicy: true
   ```
7. **mise for runtimes.** Activate mise in fish: add `mise activate fish | source` to `fish/config.fish` (replacing the removed node@18 line from Phase 1). A committed `~/.config/mise/config.toml` (via dotbot link, **required** — not optional) is the source of truth for global runtime versions and drives `mise install` at bootstrap. The committed config pins are resolved now:
   ```toml
   [tools]
   node = "lts"
   go = "latest"
   java = "lts"
   ```
   No manual `mise use -g` is needed — the committed `config.toml` is what `mise install` reads.
8. Ensure `fish/config.fish` activations are in order: `mise activate fish | source`, `starship init fish | source`, `atuin init fish | source`, `zoxide init fish | source`, `fzf --fish | source`. Note: `conf.d/` files load BEFORE `config.fish` in fish — do not move these init calls into `conf.d/` or they will run before the tools are activated.

**Acceptance (Phase 3):**
- No omf references remain: `grep -rn omf fish/ install.conf.yaml` is empty; `fish/omf/` is gone.
- `fish/fish_plugins` exists; after bootstrap `fisher list` shows its plugins.
- Starship renders in fish: `fish/config.fish` contains `starship init fish | source`; `graf009/fish_prompt.fish` is deleted.
- mise is active: `fish/config.fish` contains `mise activate fish | source`; `mise current` resolves node/go after bootstrap.
- The committed `mise/config.toml` drives `mise install`; `node --version` and `go version` succeed after bootstrap with no manual `mise use`.
- graf009 dead-tool audit complete: `dog.fish` updated, `lima.fish` deleted, `gpg.fish` deleted, `postgres.fish` deleted (or libpq added).
- For each retained `graf009` function, the underlying binary exists via a runtime probe — `command -q <binary>` succeeds in fish, not just `type <fn>`.

### Phase 4 — gitconfig consolidation + SSH commit signing

Consolidate four gitconfig files into one canonical base + identity includes. **Switch from GPG to SSH commit signing** — removes the gnupg/pinentry-mac dependency entirely.

1. **`gitconfigV2` is the canonical base.** Replace the content of `gitconfig` with `gitconfigV2` content, then delete `gitconfigV2`. Add the following improvements from ai/env:
   ```ini
   [alias]
     hf = push --force-with-lease   # безопаснее чем --force
     sw = switch                     # современная замена checkout
     ch = "!echo 'Stop using git checkout' && false"

   [push]
     followtags = true   # пушит теги вместе с коммитами

   [rerere]
     enabled = true      # запоминает решения конфликтов — не решать одно и то же дважды

   [diff]
     algorithm = histogram
     colorMoved = true
     indentHeuristic = true
   ```
2. **Switch to SSH signing** in the canonical base:
   ```ini
   [gpg]
       format = ssh
   [gpg "ssh"]
       allowedSignersFile = ~/.config/git/allowed_signers
   [commit]
       gpgsign = true
   ```
   The `allowedSignersFile` maps email → public key for signature verification. Each identity include sets its own `user.signingkey` to the path of the relevant SSH public key.
3. **Fix the default identity** — public identity as default:
   - `name = Oleg Orlov`
   - `email = mail@orlovoleg.com`
   - `signingkey = ~/.ssh/id_ed25519.pub` (or whichever key is registered on GitHub for the public identity)
4. **Identity / signingkey matrix** (via `includeIf "gitdir:..."`):
   | Path scope | Included file | Email | signingkey |
   |---|---|---|---|
   | `~/project/public/**` | `gitconfig-public` | `mail@orlovoleg.com` | `~/.ssh/id_ed25519.pub` |
   | `~/project/podeli/**` | `gitconfig-podeli` | `oorlov@alfabank.ru` | `~/.ssh/id_ed25519_podeli.pub` (or same key if only one) |
   | `~/project/tmp/**` | `gitconfig-public` | `mail@orlovoleg.com` | `~/.ssh/id_ed25519.pub` |
   | Default | (base `[user]`) | `mail@orlovoleg.com` | `~/.ssh/id_ed25519.pub` |
   - Update `gitconfig-public` and `gitconfig-podeli` to use SSH signingkeys (remove old GPG key IDs).
   - Add `git/allowed_signers` file to the repo (dotbot-linked to `~/.config/git/allowed_signers`), listing both identities' public keys.
5. **Register SSH key on GitHub** as a signing key (separate from auth key) if not already done.
6. **Rollback safety:** test-commit on a throwaway branch per scope, verify `git log --show-signature` shows `Good "git" signature` before deleting old configs.

**Acceptance (Phase 4):**
- `git config -l` shows `gpg.format=ssh`, `init.defaultBranch=main`, `core.pager=delta`, `user.email=mail@orlovoleg.com`.
- `cd ~/project/public/<repo> && git config user.email` → `mail@orlovoleg.com`; `cd ~/project/podeli/<repo> && git config user.email` → `oorlov@alfabank.ru`.
- `git log --show-signature` on a test commit shows `Good "git" signature` in each scope.
- `gitconfigV2` deleted; `git/allowed_signers` committed and linked.
- No GPG key IDs remain in any committed config file.

### Phase 5 — Bootstrap docs, README, final hygiene
Rescoped: `.DS_Store` is already untracked/gitignored (near no-op), so the focus is docs and final cleanup after Phase 4.
1. **README bootstrap docs:** document the single path — clone -> `./install` (dotbot) -> `brew bundle install` -> `./macos-defaults.sh` -> fisher install -> `mise install`. Note the `brew bundle cleanup` dry-run-first rule (Phase 2). Add a short note that the optional private override lives at `~/.config/local/*.fish` and is gitignored.
2. **Remove `gitconfigV2`** (after its content is merged into `gitconfig` in Phase 4) — verify the file is gone and dotbot links only `gitconfig`.
3. **Final `git status` hygiene:** confirm a clean tree after bootstrap; confirm `**/.DS_Store` is gitignored (it already is — verify, don't re-add); remove the tracked top-level `.DS_Store` if `git ls-files` shows it tracked (it currently is not — verify only).
4. **Documented history decision:** add a short README/`HISTORY.md` note that the repo's git history contains a prior work-affiliation identity (`oorlov@alfabank.ru`) and that this is **accepted, not scrubbed**, per an explicit decision. No history rewrite is performed.

**Acceptance (Phase 5):**
- README documents the full bootstrap (`./install` + `brew bundle install` + `./macos-defaults.sh` + fisher + `mise install`) and the cleanup dry-run rule.
- `gitconfigV2` is gone; dotbot links only `gitconfig`.
- `git status` is clean after a bootstrap dry-run; no `.DS_Store` is tracked.
- The accepted-history note exists in the repo docs.

---

## File-Level Changes

### Create
- `Brewfile` — curated, commented (taps/brews/casks/fonts/mas), includes `mise`, `atuin`, `cloudflared`, `k9s`, `headlamp`.
- `macos-defaults.sh` — committed, idempotent `defaults write` script (dock `no-bouncing`, extensible), invoked from bootstrap.
- `fish/conf.d/env.fish` — ported env vars (EDITOR, RIPGREP_CONFIG_PATH, PNPM_HOME, GOPATH, ELECTRON_TRASH, PATH, NODE_COMPILE_CACHE, BAT_THEME, CLAUDE_CONFIG_DIR). No cdpath — replaced by zoxide.
- `fish/conf.d/aliases.fish` — ported aliases as fish abbreviations.
- `fish/functions/release.fish` — npm publish function (from ai/env).
- `fish/fish_plugins` — fisher manifest.
- `sshconfig` (linked to `~/.ssh/config`) — SSH defaults, agent forwarding off, keepalive, github host entry.
- `pnpm/config.yaml` (linked to `~/.config/pnpm/config.yaml`) — security + XDG store path (from ai/env).
- `mise/config.toml` (linked to `~/.config/mise/config.toml`) — **required**; pins `node = "lts"`, `go = "latest"`.
- `git/allowed_signers` (linked to `~/.config/git/allowed_signers`) — SSH signing verification file.
- `.gitignore` additions for local overrides.

### Modify
- `install-brew-stuff.sh` — current Homebrew installer; drop removed Ruby method and the `brew install ansible` line.
- `fish/config.fish` — remove `node@18` line; add in order: `mise activate fish | source`, `starship init fish | source`, `atuin init fish | source`, `zoxide init fish | source`, `fzf --fish | source`. Keep these in `config.fish`, not `conf.d/` (conf.d loads first — see Phase 3 item 8).
- `fish/conf.d/aliases.fish` — add `abbr --add cd z` for zoxide muscle-memory migration (replaces cdpath).
- Note: yc CLI completion — add guarded source in `fish/conf.d/env.fish`: `if test -r ~/.config/local/yandex.fish; source ~/.config/local/yandex.fish; end` (gitignored, never committed).
- `fish/graf009/exa.fish` → rename to `eza.fish`, body `eza $argv`.
- `ripgreprc` — replace `--plain` with: `--smart-case`, `--hidden`, `--glob=!.git/`, `--glob=!.yarn/`, `--no-heading` (from ai/env).
- `starship.toml` — add `$container` to format string (useful for infra/container work).
- `gitconfig` — replace content with `gitconfigV2`'s; set default `[user]` to public identity; switch to SSH signing; add `hf`, `sw`, `ch` aliases; add `rerere`, `push.followtags`, `diff.algorithm=histogram`, `diff.colorMoved`, `diff.indentHeuristic`.
- `gitconfig-podeli` + `gitconfig-public` — replace GPG key IDs with SSH key paths.
- `install.conf.yaml` — remove `~/.zshrc` link, remove `~/.config/omf` link, replace `run-ansible.sh` with `brew bundle install` + `./macos-defaults.sh`; fix `settings.json2` typo → `settings.json`; change `~/.ripgreprc` → `~/.config/ripgreprc`; add symlinks for `sshconfig`, `pnpm/config.yaml`, `mise/config.toml`, `git/allowed_signers`; add fisher + `mise install` + `atuin` steps.
- `README.md` — single fish-exclusive bootstrap; remove Ansible/zsh refs; add cleanup dry-run rule + accepted-history note.

### Delete
- `zshrc` (fish-exclusive).
- `install-zsh-stuff.sh` (antigen).
- `ansible/` (entire tree) + `run-ansible.sh`.
- `fish/omf/` (oh-my-fish bundle) + `fish/graf009/fish_prompt.fish` (stock default; starship replaces it).
- `gitconfigV2` (after content merged into `gitconfig`).

### Keep (unchanged or lightly audited)
- `dotbot/` submodule + `install` + `install.conf.yaml` wiring (links updated only).
- `fish/graf009/*.fish` custom functions except `exa.fish` (renamed) and `fish_prompt.fish` (deleted) — audit, don't rewrite.
- `kitty/`, `editorconfig`, `vscode.json`, `gh/config.yml`, `ripgreprc`, `starship.toml`, `gitignore`, `gitconfig-public`, `batconfig`.

---

## ADRs

### ADR-1: Package + system management — Brewfile + macos-defaults.sh (not Ansible)
- **Decision:** Replace the Ansible `common/dev/productivity` roles with a single `Brewfile` (`brew bundle`) for packages **and** a committed idempotent `macos-defaults.sh` for system preferences.
- **Drivers:** Reduced maintenance surface; remove the Python/Ansible runtime dependency for a single-machine setup; declarative + reproducible.
- **Alternatives considered:** Keep Ansible (rejected: heavyweight, extra runtime, overkill for one Mac); nix-darwin (rejected: powerful but high learning curve / over-scoped).
- **Why chosen:** Brewfile is native to Homebrew, zero extra deps, human-readable, round-trips with real state via `brew bundle dump/check`. **Scope-limit acknowledgement:** Brewfile is packages-only and does **not** carry the `osx_defaults` Ansible applied — so `macos-defaults.sh` is added to reproduce them (currently just dock `no-bouncing`, but the script is the home for future `defaults`).
- **Consequences:** Lose Ansible's idempotent multi-host abstraction (not needed). Brewfile = single source of truth for packages; `macos-defaults.sh` = single source for system prefs.
- **Follow-ups:** Periodic `brew bundle dump`; use `brew bundle cleanup` dry-run-first; grow `macos-defaults.sh` as new tweaks appear.

### ADR-2: Fish plugins — fisher (not oh-my-fish)
- **Decision:** Replace omf with fisher; track plugins in `fish/fish_plugins`.
- **Drivers:** Maintained tooling; reduced maintenance surface; fish-exclusive.
- **Alternatives considered:** Keep omf (rejected: stale, heavier); no plugin manager (rejected: loses easy updates).
- **Why chosen:** fisher is the de-facto modern fish plugin manager, single-file, manifest-based, git-trackable.
- **Consequences:** Prompt handled by starship, not an omf theme. Plugin list must be curated small.
- **Follow-ups:** Keep the plugin list minimal.

### ADR-3: Prompt — starship as a new fish integration (not a swap of a custom prompt)
- **Decision:** Add starship to fish via `starship init fish | source`; delete `graf009/fish_prompt.fish`.
- **Drivers:** Single prompt config (`starship.toml`) for the one shell; starship already installed/configured; consistency with the prompt config the user already maintains.
- **Reframing (per Critic):** `graf009/fish_prompt.fish` is the **stock fish default prompt**, not a bespoke custom prompt. So this is a *new integration*, not a swap that discards custom work — there is no custom prompt behavior to preserve.
- **Alternatives considered:** Keep the stock default fish prompt (rejected: no git/k8s/runtime context, inconsistent with the user's existing starship config); tide/pure (rejected: another dependency when starship is already present and configured).
- **Why chosen:** One config file serves the prompt; starship's modules (git, kubernetes, golang, nodejs) suit an infra/node dev; zero new tool added.
- **Consequences:** `starship.toml` becomes the canonical prompt config and may want enrichment (k8s/git/runtime modules).
- **Follow-ups:** Tune `starship.toml` modules.

### ADR-4: Runtime management — mise (not hardcoded node@18, not fnm)
- **Decision:** Manage runtimes via `mise` instead of a pinned `node@18` on PATH; activate with `mise activate fish | source`.
- **Drivers:** node@18 is EOL; reproducibility; this user runs node **and** Go **and** JVM/maven workloads, so a single multi-runtime manager beats a node-only one.
- **Alternatives considered:** `fnm` (rejected: node-only — would still leave Go/Java unmanaged or split across tools); nvm (rejected: slow, bash-oriented); asdf (rejected: mise is its faster, drop-in successor); volta (rejected: node/JS-focused).
- **Why chosen:** mise manages node, go, python, and java in one tool with first-class fish activation and per-project `.tool-versions`/`mise.toml`; it directly replaces the hardcoded `node@18` PATH line and lets Go versioning leave the Brewfile.
- **Consequences:** Go/Java come from mise, not brew formulae (drop those formulae from the Brewfile); global defaults are declared in the committed `mise/config.toml` (`node = "lts"`, `go = "latest"`) and applied by `mise install`; per-project version files honored.
- **Follow-ups:** The committed `~/.config/mise/config.toml` (required) holds the reproducible global pins (`node = "lts"`, `go = "latest"`); extend with java/python as future needs arise.

### ADR-5: Commit signing — SSH (not GPG)
- **Decision:** Switch from GPG commit signing to SSH signing; drop `gnupg` and `pinentry-mac` from the Brewfile.
- **Drivers:** Reduced maintenance surface; SSH keys are already present on the machine and registered with GitHub for auth — reusing them for signing eliminates a separate GPG keyring, agent, and pinentry setup.
- **Alternatives considered:** Keep GPG (rejected: extra runtime deps gnupg/pinentry-mac, separate keyring to manage, pinentry UI friction); sigstore/gitsign (rejected: experimental, requires internet for verification).
- **Why chosen:** SSH signing is natively supported by GitHub since 2022 and git since 2.34; no extra tools needed beyond the existing SSH key; `allowed_signers` file gives verifiable per-identity mapping; same key used for both auth and signing simplifies key management.
- **Consequences:** GPG key IDs removed from all gitconfig files; `git/allowed_signers` file added (committed, dotbot-linked); each git identity maps to an SSH public key path instead of a GPG key ID. Must register the SSH key as a signing key on GitHub (separate from the auth key entry, though it can be the same key).
- **Follow-ups:** If a separate signing key per identity is desired, generate `~/.ssh/id_ed25519_podeli` and register it on the podeli GitHub/GitLab org.

### ADR-6: Kubernetes tooling — k9s + Headlamp (not Lens)
- **Decision:** Replace Lens (closed source since 2022) with **k9s** (TUI) + **Headlamp** (GUI).
- **Drivers:** Maintained open-source tooling; Lens went commercial and is now effectively abandonware for the free tier.
- **Alternatives considered:** OpenLens (rejected: stalled, last update Feb 2026); FreeLens (viable open-source Lens fork, active); Aptakube (viable native macOS app, $9/mo).
- **Why chosen:** k9s is the standard fast TUI for day-to-day k8s work; Headlamp (CNCF sandbox, Apache 2.0, v0.43 June 2026) covers the GUI use-case with active development and zero cost.
- **Consequences:** Lens cask removed from Brewfile; `k9s` formula + `headlamp` cask added.
- **Follow-ups:** None — both install via brew.

---

## Success Criteria
- A clean checkout + documented bootstrap yields a working **fish** shell with starship, eza, mise-managed runtimes, and all retained `graf009` functions — no manual edits, no zsh.
- Provisioning is exactly: dotbot (symlinks), Brewfile (packages), macos-defaults.sh (system prefs), fisher (fish plugins). Ansible, antigen, omf, both ad-hoc install scripts (except the rewritten brew one), and `zshrc` are gone or merged.
- Git commit signing uses SSH; `git log --show-signature` shows `Good "git" signature`; no GPG key IDs remain in committed config; `gnupg`/`pinentry-mac` not in Brewfile.
- Git default identity is the public email + SSH signingkey; podeli identity applies only under `~/project/podeli/**`.
- No unmaintained tool, no hardcoded personal absolute path, and no unguarded `source` remains in committed files.
- Brewfile reflects real daily-driver tools including infra (helm, kubernetes-cli, k9s, headlamp) and GUI casks; macOS `no-bouncing` default is reproduced by `macos-defaults.sh`.
- Git history is left intact by deliberate, documented decision.

---

## Open Questions (deferred — not blocking execution)
- **XDG layout:** Move loose configs (ripgreprc, batconfig) to `~/.config/` uniformly, or keep current paths? Currently only `ripgreprc` is moved to XDG path (required for env.fish alignment); others deferred.
- **macos-defaults.sh scope:** Should it carry more than dock `no-bouncing` (e.g., key-repeat, Finder prefs)? Keep minimal for now; extend as needed post-execution.
- **Docker/OrbStack:** `dive` is in Brewfile but Docker itself not tracked. Add `cask "orbstack"` or `cask "docker"` if needed separately.
