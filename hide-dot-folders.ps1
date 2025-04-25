$namedDirectories = 'Contacts', 'Favorites', 'Links', 'Saved Games', 'Searches'

$directoriesToHide = Get-ChildItem -Path $env:USERPROFILE -Directory |
    Where-Object { $_.Name.StartsWith('.') -or $namedDirectories -contains $_.Name }

foreach ($dir in $directoriesToHide) {
    $attributes = [System.IO.FileAttributes]::Hidden
    $dir.Attributes = $dir.Attributes -bor $attributes

    Write-Host "Set hidden attribute for directory: $($dir.FullName)"
}
