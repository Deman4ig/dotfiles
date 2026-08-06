#!/bin/bash

# Usage: start-cc-ui [--config VARIANT] [WORKTREE]
#   --config VARIANT  selects .config-VARIANT (default: .config)
#   WORKTREE          launches in $PROJECT_DIR/worktrees/WORKTREE instead of the main repo
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

CONFIG_VARIANT=""
if [ "$1" = "--config" ]; then
    CONFIG_VARIANT="$2"
    shift 2
fi
WORKTREE="$1"

CONFIG_FILE="$SCRIPT_DIR/.config${CONFIG_VARIANT:+-$CONFIG_VARIANT}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"
# Default: project has a dev server unless config opts out
HAS_DEV_SERVER="${HAS_DEV_SERVER:-true}"

# Resolve worktree if requested: $PROJECT_DIR/worktrees/$WORKTREE
if [ -n "$WORKTREE" ]; then
    WORKTREE_DIR="${PROJECT_DIR%/}/worktrees/$WORKTREE"
    if [ ! -d "$WORKTREE_DIR" ]; then
        echo "Worktree not found: $WORKTREE_DIR"
        echo "Create it first, e.g.: git -C \"${PROJECT_DIR%/}\" worktree add \"worktrees/$WORKTREE\" <branch>"
        exit 1
    fi
    PROJECT_DIR="$WORKTREE_DIR"
    SESSION_NAME="${SESSION_NAME}-${WORKTREE}"
fi
# Window names
WINDOW_IDE=" ide"
WINDOW_AI="󱚞  ai slave"
WINDOW_TERMINAL="  terminal"
WINDOW_GIT="  git"

# Pane names
PANE_NVIM="nvim"
PANE_AI="ai"
PANE_DEV="dev"
PANE_GIT="git"
PANE_LAZYGIT="lazygit"

# Commands
NAV="cd $PROJECT_DIR"
CMD_EDITOR="nvim ."
CMD_CLAUDE="claude"
CMD_DEV_SERVER="npm run dev"
CMD_BTOP="btop"
# Check if session already exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t $SESSION_NAME
    exit 0
fi

# Prompt for npm run dev
if [ "$HAS_DEV_SERVER" = true ]; then
    echo -n "Start dev server? [y/N]: "
    read -r devServerResponse
fi

if ! command -v $CMD_CLAUDE &>/dev/null; then
    echo "ai assistant is not installed"
else
    echo -n "Start ai assistant? [y/N]: "
    read -r aiAssistancResponse
fi

# Process responses
case "$devServerResponse" in
    [yY][eE][sS]|[yY])
        START_DEV=true
        ;;
    *)
        START_DEV=false
        ;;
esac
case "$aiAssistancResponse" in
    [yY][eE][sS]|[yY])
        START_AI=true
        ;;
    *)
        START_AI=false
        ;;
esac

echo "Creating new session '$SESSION_NAME'..."

# Create new session in detached mode
tmux new-session -d -s $SESSION_NAME -c $PROJECT_DIR

# Setup IDE window
tmux rename-window -t $SESSION_NAME:0 "$WINDOW_IDE"

# Conditionally create ai agent window
if [ "$START_AI" = true ]; then
    echo "Starting ai assistant..."
    tmux new-window -t $SESSION_NAME:1 -n "$WINDOW_AI" -c $PROJECT_DIR
    tmux select-pane -t $SESSION_NAME:1.0 -T $PANE_AI
    tmux send-keys -t $SESSION_NAME:1 "$CMD_CLAUDE" Enter
else
    echo "Skipping ai assistant window."
fi

# Create terminal window with complex layout
tmux new-window -t $SESSION_NAME:2 -n "$WINDOW_TERMINAL" -c $PROJECT_DIR

# Step 1: Split vertically (left/right) - creates pane 0 (left) and pane 1 (right)
tmux split-window -t $SESSION_NAME:2 -h -c $PROJECT_DIR

# Create lazygit window
tmux new-window -t $SESSION_NAME:3 -n "$WINDOW_GIT" -c $PROJECT_DIR

# Name the panes
tmux select-pane -t $SESSION_NAME:0.0 -T $PANE_NVIM
tmux select-pane -t $SESSION_NAME:2.0 -T $PANE_DEV
tmux select-pane -t $SESSION_NAME:2.1 -T $PANE_GIT
tmux select-pane -t $SESSION_NAME:3.0 -T $PANE_LAZYGIT

# Start npm run dev in the left pane (pane 0)
if [ "$START_DEV" = true ]; then
    tmux send-keys -t $SESSION_NAME:2.0 "$CMD_DEV_SERVER" Enter
fi

# Start commands in each window/pane
tmux send-keys -t $SESSION_NAME:0 "$CMD_EDITOR" Enter
tmux send-keys -t $SESSION_NAME:3 "lazygit" Enter

# Switch to the first window
tmux select-window -t $SESSION_NAME:0

# Attach to the session
tmux attach-session -t $SESSION_NAME
