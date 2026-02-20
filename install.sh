#!/bin/bash
set -e

# --- 1. Bootstrapping the Repo ---
# This is critical for the curl method to work
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning Sruinard/dotfiles to $DOTFILES_DIR..."
    git clone https://github.com/Sruinard/dotfiles.git "$DOTFILES_DIR"
fi

OS="$(uname -s)"
ARCH="$(uname -m)"

# --- 2. Tool Installation ---
if [ "$OS" == "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ "$ARCH" == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew install btop lazygit jesseduffield/lazydocker/lazydocker jq google-cloud-sdk
else
    sudo apt-get update && sudo apt-get install -y zsh btop jq curl git
    # Binary fetch for lazygit
    LAZY_V=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r .tag_name | sed 's/v//')
    curl -Lo lg.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZY_V}_Linux_x86_64.tar.gz"
    tar xf lg.tar.gz lazygit && sudo install lazygit /usr/local/bin && rm lg.tar.gz
    
    # Binary fetch for lazydocker
    LD_V=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | jq -r .tag_name | sed 's/v//')
    curl -Lo ld.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LD_V}_Linux_x86_64.tar.gz"
    tar xf ld.tar.gz lazydocker && sudo install lazydocker /usr/local/bin && rm ld.tar.gz
fi

# --- 3. uv & Oh My Zsh ---
! command -v uv &> /dev/null && curl -LsSf https://astral.sh/uv/install.sh | sh

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
[[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# --- 4. The Hook (Idempotent & Clean) ---
ZSHRC="$HOME/.zshrc"
HOOK="source $DOTFILES_DIR/zsh/.zshrc"

touch "$ZSHRC"

# Remove any previous broken lines containing "-e"
if [[ "$OS" == "Darwin" ]]; then
    sed -i '' '/^-e /d' "$ZSHRC"
else
    sed -i '/^-e /d' "$ZSHRC"
fi

# Add the hook if missing
if ! grep -qF "$HOOK" "$ZSHRC"; then
    printf "\n%s\n" "$HOOK" >> "$ZSHRC"
fi

echo "✨ Installation complete!"
exec zsh
