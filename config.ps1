param(
    [switch]$Backup,
    [switch]$Restore,
    [string]$Config
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
    "TotalCommander" = @{
        "Local" = "$env:APPDATA\GHISLER\wincmd.ini"
        "Backup" = ".\config\TotalCommander\wincmd.ini"
    }
}

function Backup-Configs {
    param (
        [string]$ConfigName
    )
    Copy-Configs -From "Local" -To "Backup" -ConfigName $ConfigName
}

function Restore-Configs {
    param (
        [string]$ConfigName
    )
    Copy-Configs -From "Backup" -To "Local" -ConfigName $ConfigName
}

function Copy-Configs {
    param (
        [string]$From,
        [string]$To,
        [string]$ConfigName
    )

    $configsToProcess = @()

    if ([string]::IsNullOrEmpty($ConfigName)) {
        $configsToProcess = $configFiles.GetEnumerator()
    } else {
        if ($configFiles.ContainsKey($ConfigName)) {
            $configsToProcess = @([PSCustomObject]@{
                Key = $ConfigName
                Value = $configFiles[$ConfigName]
            })
        } else {
            Write-Host "Error: Config '$ConfigName' not found. Available configs: $($configFiles.Keys -join ', ')" -ForegroundColor Red
            return
        }
    }

    foreach ($config in $configsToProcess) {
        $sourcePath = $config.Value[$From]
        $destinationPath = $config.Value[$To]

        if (Test-Path $sourcePath) {
            Write-Host "Copying $($config.Key) configuration:"
            Write-Host "  from $sourcePath" -ForegroundColor DarkCyan
            Write-Host "  to $destinationPath" -ForegroundColor Cyan
            Copy-Item -Path $sourcePath -Destination $destinationPath -Force
        } else {
            Write-Host "Warning: $($config.Key) configuration not found at $sourcePath" -ForegroundColor Yellow
        }
    }
    Write-Host "Operation completed." -ForegroundColor Green
}

function Show-Help {
    Write-Host "Usage: config.ps1 [-Backup] [-Restore] [ConfigName]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Backup              Backup configuration files from local locations to the git repository"
    Write-Host "  -Restore             Restore configuration files from the git repository to their local locations"
    Write-Host "  ConfigName           Optional. Specific configuration to backup/restore"
    Write-Host ""
    Write-Host "Available configs: $($configFiles.Keys -join ', ')"
}

if ($Backup) {
    Backup-Configs -ConfigName $Config
} elseif ($Restore) {
    Restore-Configs -ConfigName $Config
} else {
    Show-Help
}
