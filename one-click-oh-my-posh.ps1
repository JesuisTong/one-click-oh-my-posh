# install oh-my-posh
$ohMyPoshPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe"
$terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $ohMyPoshPath)) {
    winget install JanDeDobbeleer.OhMyPosh -s winget;
} else {
    # if oh-my-posh installed skip
    Write-Host "oh-my-posh already installed"
    exit
}

# install meslo font
& "$ohMyPoshPath" font install meslo

# config font in windows terminal
if (Test-Path $terminalSettingsPath) {
    Write-Host "Windows Terminal settings file found at: $terminalSettingsPath"
    
    try {
        # Read the current settings
        $settingsContent = Get-Content -Path $terminalSettingsPath -Raw | ConvertFrom-Json
        
        # Update the default font face for profiles
        $defaultsExists = $settingsContent.PSObject.Properties.Name -contains "profiles" -and
                         $settingsContent.profiles.PSObject.Properties.Name -contains "defaults"
                         
        if (-not $defaultsExists) {
            # Create defaults if it doesn't exist
            if ($null -eq $settingsContent.profiles) {
                $settingsContent | Add-Member -Type NoteProperty -Name "profiles" -Value @{}
            }
            if ($null -eq $settingsContent.profiles.defaults) {
                $settingsContent.profiles | Add-Member -Type NoteProperty -Name "defaults" -Value @{}
            }
        }
        
        # Set the font face to MesloLGM NF
        $settingsContent.profiles.defaults | Add-Member -Type NoteProperty -Name "font" -Value @{
            "face" = "MesloLGM Nerd Font"
        } -Force
        
        # Save the updated settings
        $settingsContent | ConvertTo-Json -Depth 10 | Set-Content -Path $terminalSettingsPath
        Write-Host "Windows Terminal settings updated with MesloLGM NF font."
    }
    catch {
        Write-Error "Failed to update Windows Terminal settings: $_"
    }
}
else {
    Write-Host "Windows Terminal settings file not found at the default location."
    Write-Host "You may need to manually configure the font in your terminal settings."
}

# Set the Oh My Posh theme
Write-Host "Configuring Oh My Posh Theme in your PowerShell profile..."

# Download custom theme file
$themeUrl = "https://gist.githubusercontent.com/JesuisTong/6f1d4a313cc88720b6740d72ebf58b04/raw/7dfa5c7858295ec7930515f9a80ccf07b88f7b19/tongz.omp.json"
$themePath = "$env:USERPROFILE\tongz.omp.json"
$profilePath = "$PROFILE"
        
try {
    Invoke-WebRequest -Uri $themeUrl -OutFile $themePath
    Write-Host "Custom Oh My Posh theme downloaded to: $themePath"
} catch {
    Write-Error "Failed to download theme file: $_"
    # Fallback to default theme if download fails
    $themePath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\jandedobbeleer.omp.json"
    Write-Host "Using default theme as fallback: $themePath"
}
        
$profileContent = @"
# Oh My Posh configuration
$ohMyPoshPath init pwsh --config '$themePath' | Invoke-Expression
"@

if (Test-Path $profilePath) {
    $currentProfile = Get-Content -Path $profilePath -Raw
    if ($currentProfile -notmatch 'oh-my-posh init') {
        Add-Content -Path $profilePath -Value "`n$profileContent"
        Write-Host "Oh My Posh configuration added to your PowerShell profile."
    } else {
        Write-Host "Oh My Posh is already configured in your PowerShell profile."
    }
} else {
    New-Item -Path $profilePath -ItemType File -Force
    Set-Content -Path $profilePath -Value $profileContent
    Write-Host "PowerShell profile created with Oh My Posh configuration."
}

Write-Host "Please restart your terminal to see the changes.`nIf you want to sync same theme in wsl, check out one-click-oh-my-posh.sh"