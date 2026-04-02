$root = Get-Location

function Clone-IfMissing($name, $repo) {
    $path = Join-Path $root "..\$name"
    if (!(Test-Path $path)) {
        Write-Host "Cloning $name..."
        git clone $repo $path
    } else {
        Write-Host "$name already exists"
    }
}

Clone-IfMissing "stellcodex" "https://github.com/stellcodex/stellcodex.git"
Clone-IfMissing "stell-ai" "https://github.com/stellcodex/stell-ai.git"
Clone-IfMissing "orchestra" "https://github.com/stellcodex/orchestra.git"

Write-Host "Bootstrap complete"
