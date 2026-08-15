# minipc WSL dev environment

Terminal + shell setup for the **Ubuntu (WSL2)** environment on the minipc, made to look/feel
identical whether accessed locally at the machine or over SSH from the MacBook.

## Files (live at `$HOME` inside WSL)
- **`.zshrc`** — zsh + oh-my-zsh + Powerlevel10k (lean), plugins, an fzf tmux session chooser, and an `LS_COLORS` fix.
- **`.p10k.zsh`** — Powerlevel10k **lean** style (single-line, no inverted blocks).
- **`.tmux.conf`** — truecolor + a flat Gruvbox status bar.
- **`reference/`** — the matching Mac Ghostty theme line and the Windows Terminal Gruvbox scheme.

## Look & feel
- **Theme:** Gruvbox Dark Hard everywhere.
  - Mac: Ghostty `theme = Gruvbox Dark Hard` (see `reference/ghostty-mac.config`).
  - minipc: Windows Terminal — add `reference/windows-terminal-gruvbox-dark-hard.json` to `schemes`,
    set it as the profile/default `colorScheme`, and make Windows Terminal the **default terminal app**
    (otherwise the Ubuntu tile opens the old console with the purple Ubuntu background).
- **Prompt:** Powerlevel10k lean — compact single line (`POWERLEVEL9K_PROMPT_ADD_NEWLINE=false`, no `newline` element).
- **Font:** any Nerd Font on the *client* terminal (Ghostty falls back automatically; Windows Terminal set to JetBrainsMono Nerd Font). Fonts are client-side — the remote needs no font.

## tmux
- `.tmux.conf` forces truecolor (`terminal-features ",*:RGB"`) so Gruvbox/p10k colors aren't quantized inside tmux.
- **Session chooser:** on an interactive login (not already inside tmux), `.zshrc` shows an fzf menu:
  `＋ new session` (default — Enter/Esc), any existing sessions to attach, or `✗ no tmux`.
  Bypass entirely with `NO_TMUX=1`.
- **Switch sessions from inside tmux:** `Ctrl-b s` (chooser), `Ctrl-b (` / `Ctrl-b )` (prev/next), `Ctrl-b L` (last).

## `ls` colors
WSL marks everything on the Windows filesystem (`/mnt/c/...`) world-writable, which `ls` renders with an
ugly green background. `.zshrc` overrides `LS_COLORS` so other-writable/sticky dirs render as normal blue.

## Access from the MacBook
- WSL runs a Tailscale node but Tailscale-in-WSL is flaky (MTU); reach it via the **Windows** Tailscale node instead.
- `~/.ssh/config` (not in this public repo): `Host wsl` → `HostName <windows-tailscale-ip>`, `RequestTTY yes`,
  `RemoteCommand wsl`, `SetEnv TERM=xterm-256color`. Then `ssh wsl` drops straight into WSL.
- Mac alias: `alias wsl='ssh wsl'`.

## Persistence (WSL doesn't self-sustain)
Modern WSL idle-shuts the VM ~60s after the last session, killing tmux/containers. A Windows Scheduled Task
**"Start WSL on Boot"** runs as the user with `wsl -d Ubuntu -u root -e sleep infinity` to hold the VM up
(and survive reboots).
