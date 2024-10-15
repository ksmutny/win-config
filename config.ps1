param(
    [switch]$Backup,
    [switch]$Restore
)

$configFiles = @{
    "PowerShell" = @{
        "Local" = $PROFILE
        "Backup" = ".\config\PowerShell\Microsoft.PowerShell_profile.ps1"
    }
    "oh-my-posh" = @{
        "Local" = "$env:POSH_THEMES_PATH\nebula-surge.omp.json"
        "Backup" = ".\config\oh-my-posh\nebula-surge.omp.json"
    }
    "WindowsTerminal" = @{
        "Local" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        "Backup" = ".\config\WindowsTerminal\settings.json"
    }
}

function Backup-Configs {
    Copy-Configs -From "Local" -To "Backup"
}

function Restore-Configs {
    Copy-Configs -From "Backup" -To "Local"
}

function Copy-Configs {
    param (
        [string]$From,
        [string]$To
    )

    foreach ($config in $configFiles.GetEnumerator()) {
        $sourcePath = $config.Value[$From]
        $destinationPath = $config.Value[$To]

        if (Test-Path $sourcePath) {
            Write-Host "Copying $($config.Key) configuration..."
            Copy-Item -Path $sourcePath -Destination $destinationPath -Force
        } else {
            Write-Host "Warning: $($config.Key) configuration not found at $sourcePath"
        }
    }
    Write-Host "Operation completed."
}

function Show-Help {
    Write-Host "Usage: config.ps1 [-Backup] [-Restore]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Backup    Backup configuration files from local locations to the git repository"
    Write-Host "  -Restore   Restore configuration files from the git repository to their local locations"
}

if ($Backup) {
    Backup-Configs
} elseif ($Restore) {
    Restore-Configs
} else {
    Show-Help
}
