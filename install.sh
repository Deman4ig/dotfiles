#!/bin/bash
#
# Dotfiles installation script.
#
# Symlinks ~/.config/<app> -> <repo>/.config/<app>, bootstraps tpm and the
# tmux plugins, puts start-cc-ui on PATH, and checks fonts + runtime deps.
# Idempotent: safe to re-run.

set -euo pipefail

# Repo root, derived from this script's location so the repo can live anywhere.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"

# Apps to symlink into ~/.config
APPS=("alacritty" "nvim" "opencode" "tmux")

# tpm lives inside the (gitignored) tmux plugins dir
TPM_DIR="$DOTFILES_DIR/.config/tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm"

# Font required by alacritty.toml
FONT_FILE_PREFIX="MesloLGSNerdFont"
FONT_FAMILY="MesloLGS Nerd Font"
FONT_CASK="font-meslo-lg-nerd-font"

# Commands the tmux session layout invokes
DEPS=("tmux" "nvim" "lazygit" "btop" "npm" "git")

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "$*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }
fail()  { echo -e "${RED}✗${NC} $*"; }

# Prompt yes/no. Returns 1 (no) without prompting when stdin isn't a TTY,
# so piping this script into bash can't hang or abort under `set -e`.
confirm() {
    local prompt="$1" reply
    if [ ! -t 0 ]; then
        warn "Not interactive, skipping: $prompt"
        return 1
    fi
    read -r -p "$prompt (y/n) " -n 1 reply
    echo
    [[ $reply =~ ^[Yy]$ ]]
}

info "Setting up dotfiles..."
info "Dotfiles directory: $DOTFILES_DIR"
info "Config directory:   $CONFIG_DIR"
info ""

# ── 1. Symlink configs ──────────────────────────────────────────────────
mkdir -p "$CONFIG_DIR"

for app in "${APPS[@]}"; do
    SOURCE="$DOTFILES_DIR/.config/$app"
    TARGET="$CONFIG_DIR/$app"

    if [ ! -e "$SOURCE" ]; then
        warn "$SOURCE does not exist, skipping..."
        continue
    fi

    # Already pointing where we want it.
    if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
        ok "$app already linked"
        continue
    fi

    if [ -L "$TARGET" ]; then
        info "Replacing symlink: $TARGET -> $(readlink "$TARGET")"
        rm "$TARGET"
    elif [ -e "$TARGET" ]; then
        BACKUP="$TARGET.backup.$(date +%Y%m%d_%H%M%S)"
        info "Backing up existing config: $TARGET -> $BACKUP"
        mv "$TARGET" "$BACKUP"
    fi

    ln -s "$SOURCE" "$TARGET"
    ok "Linked $app"
done

# ── 2. tmux plugins (tpm) ───────────────────────────────────────────────
# The plugins dir is gitignored, so a fresh clone has none of them and
# tmux.conf's `run` line is a silent no-op until tpm is cloned here.
info ""
if [ -d "$TPM_DIR/.git" ]; then
    ok "tpm already installed"
else
    info "Cloning tpm into $TPM_DIR"
    git clone --depth 1 "$TPM_REPO" "$TPM_DIR"
    ok "tpm installed"
fi

if command -v tmux >/dev/null 2>&1; then
    info "Installing tmux plugins..."
    # install_plugins reads @plugin options off a tmux server, so make sure
    # one exists with the config loaded. Sourcing into an already-running
    # server is just the usual config reload.
    tmux start-server
    tmux source-file "$CONFIG_DIR/tmux/tmux.conf"
    if "$TPM_DIR/bin/install_plugins"; then
        ok "tmux plugins installed"
    else
        warn "tpm reported errors; run prefix + I inside tmux to retry"
    fi
else
    warn "tmux not found, skipping plugin install"
fi

# ── 3. start-cc-ui on PATH ──────────────────────────────────────────────
info ""
LAUNCHER_SOURCE="$DOTFILES_DIR/.config/tmux/start-cc-ui.sh"
LAUNCHER_TARGET="$BIN_DIR/start-cc-ui"

if [ -f "$LAUNCHER_SOURCE" ]; then
    mkdir -p "$BIN_DIR"
    chmod +x "$LAUNCHER_SOURCE"
    if [ -L "$LAUNCHER_TARGET" ] && [ "$(readlink "$LAUNCHER_TARGET")" = "$LAUNCHER_SOURCE" ]; then
        ok "start-cc-ui already on PATH"
    else
        ln -sf "$LAUNCHER_SOURCE" "$LAUNCHER_TARGET"
        ok "Linked start-cc-ui -> $LAUNCHER_TARGET"
    fi
    case ":$PATH:" in
        *":$BIN_DIR:"*) ;;
        *) warn "$BIN_DIR is not on your PATH; add it to use start-cc-ui" ;;
    esac
else
    warn "$LAUNCHER_SOURCE not found, skipping launcher link"
fi

# start-cc-ui needs a per-project config file that is deliberately kept out
# of the repo. Tell the user rather than shipping a template.
if ! compgen -G "$DOTFILES_DIR/.config/tmux/.config*" >/dev/null; then
    warn "No start-cc-ui config found. Create $DOTFILES_DIR/.config/tmux/.config with:"
    info "    SESSION_NAME=\"myproject\""
    info "    PROJECT_DIR=\"\$HOME/projects/myproject/\""
    info "    # HAS_DEV_SERVER=false   # optional, defaults to true"
fi

# ── 4. Runtime dependencies ─────────────────────────────────────────────
info ""
MISSING=()
for dep in "${DEPS[@]}"; do
    command -v "$dep" >/dev/null 2>&1 || MISSING+=("$dep")
done
if [ ${#MISSING[@]} -eq 0 ]; then
    ok "All runtime dependencies present"
else
    warn "Missing dependencies: ${MISSING[*]}"
    info "    install with: brew install ${MISSING[*]}"
fi

# ── 5. Font ─────────────────────────────────────────────────────────────
info ""
if find "$HOME/Library/Fonts" -name "${FONT_FILE_PREFIX}*" -print -quit 2>/dev/null | grep -q .; then
    ok "Font '$FONT_FAMILY' is installed"
else
    fail "Font '$FONT_FAMILY' not found"
    if confirm "Install it now with Homebrew?"; then
        # Nerd Fonts live in homebrew/cask now; homebrew/cask-fonts is archived.
        brew install --cask "$FONT_CASK"
        ok "Font installed"
    else
        info "Skipping font installation."
    fi
fi

info ""
ok "Done! Dotfiles installed."
