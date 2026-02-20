#!/bin/sh
# Use /bin/sh for maximum compatibility across all environments
set -e

DOTFILES_DIR="$HOME/dotfiles"

# 1. Self-Cloning logic
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning Sruinard/dotfiles..."
    git clone https://github.com/Sruinard/dotfiles.git "$DOTFILES_DIR"
fi

OS=$(uname -s)
ARCH=$(uname -m)

# 2. Package Installation
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ "$ARCH" = "arm64" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    brew install btop lazygit jesseduffield/lazydocker/lazydocker jq google-cloud-sdk
else
    # Linux (DevContainer/VM)
    sudo apt-get update && sudo apt-get install -y zsh btop jq curl git
    for tool in lazygit lazydocker; do
        REPO_PATH="jesseduffield/$tool"
        VERSION=$(curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest" | jq -r .tag_name | sed 's/v//')
        curl -Lo "${tool}.tar.gz" "https://github.com/$REPO_PATH/releases/latest/download/${tool}_${VERSION}_Linux_x86_64.tar.gz"
        tar xf "${tool}.tar.gz" "$tool" && sudo install "$tool" /usr/local/bin && rm "${tool}.tar.gz" "$tool"
    done
fi

# 3. Tool Installers
! command -v uv >/dev/null 2>&1 && curl -LsSf https://astral.sh/uv/install.sh | sh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# 5. The Hook & Shell Switch
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"
HOOK="source $DOTFILES_DIR/zsh/.zshrc"

# Clean previous errors
[ -f "$ZSHRC" ] && sed -i '/^-e /d' "$ZSHRC"

# Add hook if missing
if ! grep -q "$HOOK" "$ZSHRC" 2>/dev/null; then
    printf "\n%s\n" "$HOOK" >> "$ZSHRC"
fi

# THE KEY: Ensure the session switches to Zsh immediately on login
AUTO_SWITCH='if [ -t 1 ]; then exec zsh; fi'
if ! grep -q "exec zsh" "$BASHRC" 2>/dev/null; then
    printf "\n# Auto-switch to zsh\n%s\n" "$AUTO_SWITCH" >> "$BASHRC"
fi

echo "✨ Installation complete! Launching Zsh..."
exec zsh
