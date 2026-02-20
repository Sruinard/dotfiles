#!/bin/bash
set -e

OS="$(uname -s)"
ARCH="$(uname -m)"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Bootstrapping Environment ($OS $ARCH)..."

# 1. Install System Dependencies
if [ "$OS" == "Darwin" ]; then
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew install btop lazygit jesseduffield/lazydocker/lazydocker jq google-cloud-sdk
else
    sudo apt-get update && sudo apt-get install -y zsh btop jq curl git
    # Install lazygit & lazydocker binaries (apt versions are too old)
    for tool in lazygit lazydocker; do
        REPO="jesseduffield/$tool"
        VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name | sed 's/v//')
        curl -Lo "${tool}.tar.gz" "https://github.com/$REPO/releases/latest/download/${tool}_${VERSION}_Linux_x86_64.tar.gz"
        tar xf "${tool}.tar.gz" $tool && sudo install $tool /usr/local/bin && rm "${tool}.tar.gz" $tool
    done
fi

# 2. Install 'uv'
curl -LsSf https://astral.sh/uv/install.sh | sh

# 3. Setup Oh My Zsh & Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# 4. GCloud (Linux Manual Install if not on Mac)
if [ "$OS" == "Linux" ] && [ ! -d "$HOME/google-cloud-sdk" ]; then
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-linux-x86_64.tar.gz -C "$HOME"
    "$HOME/google-cloud-sdk/install.sh" --quiet --path-update=false
    rm google-cloud-cli-linux-x86_64.tar.gz
fi

# 5. THE CLEAN HOOK: Point the system .zshrc to your repo config
HOOK_LINE="source $DOTFILES_DIR/zsh/.zshrc"
if ! grep -q "$HOOK_LINE" "$HOME/.zshrc"; then
    echo -e "\n# Dotfiles Hook\n$HOOK_LINE" >> "$HOME/.zshrc"
    echo "✅ Hook added to ~/.zshrc"
fi

echo "✨ Installation complete. Run 'exec zsh' to start."
