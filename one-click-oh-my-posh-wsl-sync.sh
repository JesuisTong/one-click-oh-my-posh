# Make sure you are in WSL

# Add logging functions
log_info() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

log_warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

log_info "Starting Oh My Posh WSL setup..."

log_info "Updating package lists..."
sudo apt-get update -y
log_info "Installing zsh and unzip..."
sudo apt-get install -y zsh unzip

log_info "Installing Oh My Posh..."
curl -s https://ohmyposh.dev/install.sh | bash -s || { log_error "Failed to install Oh My Posh"; exit 1; }

log_info "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || { log_error "Failed to install Oh My Zsh"; exit 1; }

log_info "Setting zsh as default shell..."
chsh -s $(which zsh)

# (Optional) add auto-suggestion plugin
log_info "Installing zsh-autosuggestions plugin..."
if git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions; then
    log_info "Successfully installed zsh-autosuggestions"
    
    log_info "Configuring zsh plugins..."
    # add plugins in ~/.zshrc
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/g' ~/.zshrc
else
    log_warn "Failed to install zsh-autosuggestions, skipping plugin configuration in .zshrc"
fi

log_info "Getting Windows username..."
windows_user=$(powershell.exe whoami)
if [ -z "$windows_user" ]; then
    log_error "Failed to get Windows username"
    exit 1
fi

# split user to get the username and trim
windows_user=$(echo $windows_user | cut -d '\' -f 2 | tr -d '\r\n')
log_info "Windows username: $windows_user"

# get the path of the oh-my-posh theme
log_info "Locating Oh My Posh theme..."
custom_theme_path="/mnt/c/users/$windows_user/tongz.omp.json"
default_theme_path="/mnt/c/users/$windows_user/AppData/Local/Programs/oh-my-posh/themes/jandedobbeleer.omp.json"

# check if file not exists, switch to default
if [ ! -f "$custom_theme_path" ]; then
    log_warn "Custom theme not found at $custom_theme_path"
    oh_my_posh_theme_path="$default_theme_path"
    
    if [ ! -f "$oh_my_posh_theme_path" ]; then
        log_error "Default theme not found at $oh_my_posh_theme_path"
        log_info "Searching for alternative themes..."
        theme_dir="/mnt/c/users/$windows_user/AppData/Local/Programs/oh-my-posh/themes"
        if [ -d "$theme_dir" ]; then
            default_theme=$(find "$theme_dir" -name "*.omp.json" | head -1)
            if [ -n "$default_theme" ]; then
                oh_my_posh_theme_path="$default_theme"
                log_info "Using alternative theme: $oh_my_posh_theme_path"
            else
                log_error "No themes found in $theme_dir"
                exit 1
            fi
        else
            log_error "Theme directory not found: $theme_dir"
            exit 1
        fi
    else
        log_info "Using default theme: $oh_my_posh_theme_path"
    fi
else
    log_info "Using custom theme: $custom_theme_path"
    oh_my_posh_theme_path="$custom_theme_path"
fi

log_info "Adding Oh My Posh initialization to ~/.zshrc"
# add to .zshrc to sync oh-my-posh theme
echo "oh-my-posh init zsh --config $oh_my_posh_theme_path" >> ~/.zshrc

log_info "Setup complete! Please restart your terminal"