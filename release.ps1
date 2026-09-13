<#
.SYNOPSIS
    Publica o instalador do ArkZ Games como um GitHub Release.

.DESCRIPTION
    Cria/envia a tag da versão e anexa o instalador .exe (Output\*.exe) a um
    Release no GitHub.

    Pre-requisitos (ambiente do autor):
      1. GitHub CLI instalado  ->  winget install --id GitHub.cli
      2. Autenticado           ->  gh auth login
      3. Repositorio remoto    ->  git remote add origin https://github.com/em-rezende/ArkZGames-Autocad.git

.EXAMPLE
    .\release.ps1 -Version 260912 -Notes "Primeira versao publica."

.EXAMPLE
    .\release.ps1 -Version 260912 -NotesFile .\RELEASE_NOTES.md
#>
[CmdletBinding()]
param(
    [string] $Version   = "260912",
    [string] $Repo      = "em-rezende/ArkZGames-Autocad",
    [string] $NotesFile = "",
    [string] $Notes     = "",
    [switch] $Draft,
    [switch] $Prerelease
)

$ErrorActionPreference = "Stop"
$root     = $PSScriptRoot
$installer = Join-Path $root "Output\ArkZGames_v_${Version}_Setup.exe"
$tag       = "v$Version"

Write-Host "==> ArkZ Games - publicacao de release ($tag)" -ForegroundColor Cyan

# ------------------------------------------------------------------
# 1. Verificacoes
# ------------------------------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) nao encontrado. Instale com: winget install --id GitHub.cli"
}
gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Nao autenticado no GitHub. Execute: gh auth login"
}

if (-not (Test-Path $installer)) {
    throw "Instalador nao encontrado: $installer`nCompile o .iss antes (ISCC.exe 'Install ArkZGames.iss')."
}
Write-Host "  Instalador: $installer" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Tag + push
# ------------------------------------------------------------------
Push-Location $root
try {
    if (-not (Test-Path (Join-Path $root ".git"))) {
        throw "Este diretorio nao e um repositorio git. Execute 'git init' e configure o remote 'origin'."
    }

    if (-not (git tag --list $tag)) {
        git tag -a $tag -m "ArkZ Games $tag"
        git push origin $tag
    } else {
        Write-Host "  Tag $tag ja existe localmente." -ForegroundColor Yellow
    }

    # ------------------------------------------------------------------
    # 3. Notas da release
    # ------------------------------------------------------------------
    if (-not $Notes -and $NotesFile -and (Test-Path $NotesFile)) {
        $Notes = Get-Content $NotesFile -Raw
    }
    if (-not $Notes) {
        $Notes = "Instalador do ArkZ Games versao $Version.`n`nVeja o README.MD para detalhes de instalacao e uso."
    }

    # ------------------------------------------------------------------
    # 4. Criar o Release e anexar o .exe
    # ------------------------------------------------------------------
    $ghArgs = @(
        "release", "create", $tag, $installer,
        "--repo", $Repo,
        "--title", "ArkZ Games $tag",
        "--notes", $Notes
    )
    if ($Draft)      { $ghArgs += "--draft" }
    if ($Prerelease) { $ghArgs += "--prerelease" }

    gh @ghArgs
    if ($LASTEXITCODE -ne 0) { throw "Falha ao criar o Release no GitHub." }

    Write-Host "==> Release $tag publicada com sucesso!" -ForegroundColor Green
    gh release view $tag --repo $Repo --web
}
finally {
    Pop-Location
}
