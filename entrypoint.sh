#!/usr/bin/env bash
set -euo pipefail

# Copy git credentials to a writable location so git can update them.
# Bind-mounting the file directly causes EBUSY on credential store writes
# because git uses rename() for atomic updates.
if [[ -f /tmp/git-credentials-in ]]; then
  cp /tmp/git-credentials-in /root/.git-credentials
  chmod 600 /root/.git-credentials
fi

# Initialize Bazinga in the workspace if not already done
if [[ ! -d bazinga ]]; then
  uvx --from git+https://github.com/mehdic/bazinga.git bazinga init --here --no-git || true
fi

# Use Ctrl-a as tmux prefix to avoid conflicts with host tmux.
# Mouse mode is off so the terminal emulator handles text selection and
# copy natively (and to avoid tmux's right-click context menu).
export TMUX_CONF
TMUX_CONF=$(mktemp)
cat > "$TMUX_CONF" <<'CONF'
set -g prefix C-a
unbind C-b
bind C-a send-prefix
bind Q kill-session
set -g status off
CONF

# Size the detached session to the actual terminal so the 85% split is
# calculated against real dimensions; otherwise tmux's virtual canvas
# diverges from the attached client size and panes get mis-sized.
cols=$(tput cols 2>/dev/null || echo 200)
rows=$(tput lines 2>/dev/null || echo 50)

# Top pane: bash shell (15%)
# Bottom pane: claude (85%), focused
tmux -f "$TMUX_CONF" new-session -d -x "$cols" -y "$rows" -s cbox -c "$PWD"
tmux split-window -v -l 85% -t cbox -c "$PWD" "claude --dangerously-skip-permissions $*"
tmux select-pane -t cbox:0.1
tmux attach -t cbox
