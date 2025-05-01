$tmpFolder = "./tmp"
$extractFolder = "$tmpFolder/extract"

function InstallFonts {
    $fonts = Get-Content 'fonts.json' | ConvertFrom-Json

    foreach ($font in $fonts) {
        DownloadFont -fontName $font.font -fontUrl $font.url
        InstallFont
        Cleanup -path $extractFolder
    }
}

function DownloadFont {
    param (
        [string]$fontName,
        [string]$fontUrl
    )

    $zipFile = "$tmpFolder\$fontName.zip"

    Write-Host "Downloading $fontName..."
    Invoke-WebRequest -Uri $fontUrl -OutFile $zipFile
    Expand-Archive -LiteralPath $zipFile -DestinationPath $extractFolder -Force
}

function InstallFont {
    $shellApp = New-Object -ComObject shell.application
    $fontsFolder = $shellApp.NameSpace(0x14)

    Get-ChildItem -Path $extractFolder -Include ('*.ttf', '*.otf') -File -Recurse | ForEach-Object {
        if (IsInstalled -fontName $_.Name) {
            Write-Host "Font already installed: $($_.Name)"
        } else {
            Write-Host "Installing font: $($_.Name)"
            $fontsFolder.CopyHere($_.FullName, 0x10)
        }
    }
}

function IsInstalled {
    param (
        [string]$fontName
    )

    $systemFontPath = [System.IO.Path]::Combine($env:windir, 'Fonts', $fontName)
    $userFontPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft\Windows\Fonts', $fontName)

    return (Test-Path $systemFontPath -PathType Leaf) -or (Test-Path $userFontPath -PathType Leaf)
}

function InitFolder {
    param(
        [string]$path
    )

    if (Test-Path $path) {
        Cleanup -path $path
    }
    New-Item -ItemType Directory -Path $path
}

function Cleanup {
    param (
        [string]$path
    )

    Remove-Item -Path $path -Recurse -Force
}

InitFolder -path $tmpFolder
InstallFonts
Cleanup -path $tmpFolder
