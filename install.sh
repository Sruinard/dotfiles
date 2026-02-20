#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning Sruinard/dotfiles..."
    git clone https://github.com/Sruinard/dotfiles.git "$DOTFILES_DIR"
fi

OS=$(uname -s)
ARCH=$(uname -m)

# --- Tool Installation ---
if [ "$OS" = "Darwin" ]; then
    if ! command -v brew >/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [ "$ARCH" = "arm64" ] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew install btop lazygit jesseduffield/lazydocker/lazydocker jq google-cloud-sdk
else
    sudo apt-get update && sudo apt-get install -y zsh btop jq curl git
    for tool in lazygit lazydocker; do
        REPO_PATH="jesseduffield/$tool"
        VERSION=$(curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest" | jq -r .tag_name | sed 's/v//')
        curl -Lo "${tool}.tar.gz" "https://github.com/$REPO_PATH/releases/latest/download/${tool}_${VERSION}_Linux_x86_64.tar.gz"
        tar xf "${tool}.tar.gz" $tool && sudo install $tool /usr/local/bin && rm "${tool}.tar.gz" $tool
    done
fi

# --- uv & Oh My Zsh ---
! command -v uv >/dev/null && curl -LsSf https://astral.sh/uv/install.sh | sh
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# --- The Hook ---
ZSHRC="$HOME/.zshrc"
HOOK="source $DOTFILES_DIR/zsh/.zshrc"
touch "$ZSHRC"
# Remove old broken -e lines
sed -i '/^-e /d' "$ZSHRC" 2>/dev/null || sed -i '' '/^-e /d' "$ZSHRC" 2>/dev/null

if ! grep -qF "$HOOK" "$ZSHRC"; then
    printf "\n%s\n" "$HOOK" >> "$ZSHRC"
fi

# --- AUTO-SWITCH TO ZSH ---
# This ensures that even if 'chsh' fails, your shell switches to Zsh on login
BASHRC="$HOME/.bashrc"
SWITCH_CMD='if [ -t 1 ]; then exec zsh; fi'
if ! grep -q "exec zsh" "$BASHRC"; then
    printf "\n# Auto-switch to zsh\n%s\n" "$SWITCH_CMD" >> "$BASHRC"
fi

echo "✨ Installation complete! Switching to zsh..."
exec zsh
