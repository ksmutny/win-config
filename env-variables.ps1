$packageDir = "E:\packages"

$vars = @{
    "CARGO_HOME" = "cargo"
    "DENO_DIR" = "deno"
    "GRADLE_USER_HOME" = "gradle"
    "MAVEN_OPTS" = "m2"
    "NPM_CONFIG_CACHE" = "npm"
    "NUGET_PACKAGES" = "nuget"
    "PIP_CACHE_DIR" = "pip\cache"
    "PNPM_HOME" = "pnpm"
}

foreach ($var in $vars.Keys) {
    $path = Join-Path -Path $packageDir -ChildPath $vars[$var]
    if (-not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
    [Environment]::SetEnvironmentVariable($var, $path, "User")
    Write-Host "Set $var to $path"
}
