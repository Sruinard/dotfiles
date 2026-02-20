#!/bin/bash
set -e

# --- 1. Repository & Path Setup ---
DOTFILES_DIR="$HOME/dotfiles"
# If the directory doesn't exist, we are likely running via curl
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Repo not found. Cloning Sruinard/dotfiles..."
    git clone https://github.com/Sruinard/dotfiles.git "$DOTFILES_DIR"
fi

OS="$(uname -s)"
ARCH="$(uname -m)"
echo "🛠️ Bootstrapping Sruinard's Environment ($OS $ARCH)..."

# --- 2. System Package Managers & Core Tools ---
if [ "$OS" == "Darwin" ]; then
    # macOS Setup
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Activate brew for the current session
        [[ "$ARCH" == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "📦 Installing tools via Brew..."
    brew install btop lazygit jesseduffield/lazydocker/lazydocker jq google-cloud-sdk
else
    # Linux / DevContainer Setup
    echo "🐧 Installing tools via Apt..."
    sudo apt-get update && sudo apt-get install -y zsh btop jq curl git
    
    # Install lazygit & lazydocker binaries (latest versions)
    for tool in lazygit lazydocker; do
        REPO_PATH="jesseduffield/$tool"
        VERSION=$(curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest" | jq -r .tag_name | sed 's/v//')
        curl -Lo "${tool}.tar.gz" "https://github.com/$REPO_PATH/releases/latest/download/${tool}_${VERSION}_Linux_x86_64.tar.gz"
        tar xf "${tool}.tar.gz" $tool && sudo install $tool /usr/local/bin && rm "${tool}.tar.gz" $tool
    done

    # GCloud Manual Install for Linux
    if [ ! -d "$HOME/google-cloud-sdk" ]; then
        echo "☁️ Installing Google Cloud SDK..."
        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
        tar -xf google-cloud-cli-linux-x86_64.tar.gz -C "$HOME"
        "$HOME/google-cloud-sdk/install.sh" --quiet --path-update=false
        rm google-cloud-cli-linux-x86_64.tar.gz
    fi
fi

# --- 3. Install 'uv' (Python Package Manager) ---
if ! command -v uv &> /dev/null; then
    echo "🐍 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# --- 4. Zsh & Oh My Zsh Setup ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
echo "🔌 Installing Zsh Plugins..."
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# --- 5. The "Clean Hook" ---
# Ensures the system .zshrc points to your repo config without making a mess
HOOK_LINE="source $DOTFILES_DIR/zsh/.zshrc"
if [ ! -f "$HOME/.zshrc" ]; then touch "$HOME/.zshrc"; fi

if ! grep -q "$HOOK_LINE" "$HOME/.zshrc"; then
    echo -e "\n# Sruinard Dotfiles Hook\n$HOOK_LINE" >> "$HOME/.zshrc"
    echo "✅ Successfully linked $DOTFILES_DIR/zsh/.zshrc to ~/.zshrc"
fi

echo "✨ All done! Run 'exec zsh' to activate your new shell."
