# --- 1. Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting
)

# Load Oh My Zsh
# Must happen before we modify the PROMPT
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# --- 2. Custom Prompt (Sruinard Hostname Fix) ---
# Adds cyan user@host to the start of the robbyrussell prompt
PROMPT="%{$fg[cyan]%}%n@%m %{$reset_color%}${PROMPT}"

# --- 3. Environment & Tool Paths ---

# Homebrew Detection
if [[ "$(uname)" == "Darwin" ]]; then
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
fi

# uv (Python Package Manager)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Google Cloud SDK
if [[ -d "$HOME/google-cloud-sdk" ]]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
elif command -v brew &>/dev/null; then
    GCLOUD_PATH="$(brew --prefix)/share/google-cloud-sdk"
    if [[ -d "$GCLOUD_PATH" ]]; then
        source "$GCLOUD_PATH/path.zsh.inc"
        source "$GCLOUD_PATH/completion.zsh.inc"
    fi
fi
