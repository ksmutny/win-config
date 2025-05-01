param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Export", "Import")]
    [string]$Operation
)

$sqlitePath = "sqlite3.exe"
$edgeWebData = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Web Data"
$tempCopy = "WebData_Temp.sqlite"
$sqlFile = "keywords.sql"

if (-not (Get-Command $sqlitePath -ErrorAction SilentlyContinue)) {
    Write-Error "sqlite3.exe not found in PATH. Please download it from https://sqlite.org/download.html"
    exit 1
}

if (-not (Test-Path $edgeWebData)) {
    Write-Error "Edge Web Data file not found at $edgeWebData"
    exit 1
}

switch ($Operation) {
    "Export" {
        Copy-Item $edgeWebData $tempCopy -Force
        & $sqlitePath $tempCopy ".mode insert keywords" ".output $sqlFile" "SELECT * FROM keywords;" ".exit"
        Remove-Item $tempCopy -Force
        Write-Host "✅ Exported search engines to $sqlFile"
    }

    "Import" {
        if (-not (Test-Path $sqlFile)) {
            Write-Error "SQL file $sqlFile not found. Run export first or make sure it's in this directory."
            exit 1
        }

        # Backup
        Copy-Item $edgeWebData "$edgeWebData.bak" -Force

        # Import
        & $sqlitePath $edgeWebData "DELETE FROM keywords;" ".read $sqlFile"

        Write-Host "✅ Imported search engines from $sqlFile"
    }
}
