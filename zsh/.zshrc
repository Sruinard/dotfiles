# --- 1. Oh My Zsh Setup ---
export ZSH="$HOME/.oh-my-zsh"
# Includes standard autocomplete and the two requested plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Silently source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- 2. Tool-Specific Paths & Initializations ---

# Homebrew (Auto-detects Apple Silicon vs Intel vs Linuxbrew)
if [[ "$(uname)" == "Darwin" ]]; then
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
fi

# uv (Python Package Manager)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# gcloud (Google Cloud SDK)
# Detects both Brew (Mac) and Manual (Linux/DevContainer) paths
if [[ -d "$HOME/google-cloud-sdk" ]]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
elif command -v brew &>/dev/null && [[ -d "$(brew --prefix)/share/google-cloud-sdk" ]]; then
    source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi
