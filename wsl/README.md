# minipc WSL dev environment

Terminal + shell setup for the **Ubuntu (WSL2)** environment on the minipc, made to look/feel
identical whether accessed locally at the machine or over SSH from the MacBook.

## Files (live at `$HOME` inside WSL)
- **`.zshrc`** — zsh + oh-my-zsh + Powerlevel10k (lean), plugins, an fzf tmux session chooser, and an `LS_COLORS` fix.
- **`.p10k.zsh`** — Powerlevel10k **lean** style (single-line, no inverted blocks).
- **`.tmux.conf`** — truecolor + a flat Gruvbox status bar.
- **`setup.sh`** — one-shot bootstrap for a fresh box: packages, oh-my-zsh, theme, plugins, and these configs. Idempotent.
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
- **Prefix is `Ctrl-a`**, not tmux's default `Ctrl-b` (screen-style, and adjacent to the Caps Lock->Ctrl remap).
  `Ctrl-a a` sends a literal prefix through — useful for beginning-of-line in readline, or for a nested tmux.
  `Ctrl-a Ctrl-a` is **last-window** (double-tap to bounce between the two most recent windows).
- **Switch sessions from inside tmux:** `Ctrl-a s` (chooser), `Ctrl-a (` / `Ctrl-a )` (prev/next), `Ctrl-a L` (last).

## Clipboard (one clipboard, not two)

With `mouse on`, tmux captures mouse selection and copies into its **own** buffer stack — nothing
reaches the system clipboard, so pasting elsewhere silently gives you whatever was last copied by a
normal app. `set -g set-clipboard on` plus `set -as terminal-features ",*:clipboard"` makes tmux emit
**OSC 52** so its copies land in the real clipboard.

The outer terminal must also permit OSC 52 writes. Windows Terminal allows this by default
(`compatibility.allowOSC52`). If it is ever disabled, Shift+drag bypasses tmux's mouse handling and
lets the terminal do a native selection instead.

## `ls` colors
WSL marks everything on the Windows filesystem (`/mnt/c/...`) world-writable, which `ls` renders with an
ugly green background. `.zshrc` overrides `LS_COLORS` so other-writable/sticky dirs render as normal blue.

## Access from the MacBook
- WSL runs its own Tailscale node (`minipc-wsl`) with sshd on **port 2222** — `ssh -p 2222 nolfonzo@minipc-wsl`
  works directly and is the simplest route. An earlier MTU problem made this unreliable; it is currently fine.
- Fallback if the WSL node misbehaves: go via the **Windows** node (`minipc`, port 22) with `RemoteCommand wsl`.
  Note Windows OpenSSH runs `cmd.exe`, so `ssh-copy-id` fails against it (`'exec' is not recognized`) — an admin
  account's key must be placed in `C:\ProgramData\ssh\administrators_authorized_keys`, not `~/.ssh/authorized_keys`.
- `~/.ssh/config` (not in this public repo): `Host wsl` → `HostName <windows-tailscale-ip>`, `RequestTTY yes`,
  `RemoteCommand wsl`, `SetEnv TERM=xterm-256color`. Then `ssh wsl` drops straight into WSL.
- Mac alias: `alias wsl='ssh wsl'`.

## Persistence (WSL doesn't self-sustain)
Modern WSL idle-shuts the VM ~60s after the last session, killing tmux/containers. A Windows Scheduled Task
**"Start WSL on Boot"** runs as the user with `wsl -d Ubuntu -u root -e sleep infinity` to hold the VM up
(and survive reboots).
