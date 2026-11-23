$ErrorActionPreference = 'Stop'

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw 'Podman não encontrado. Instale e inicie o Podman Desktop primeiro.'
}

$podmanInfo = & podman info --format '{{.Host.Security.Rootless}}'
if ($LASTEXITCODE -ne 0) {
    throw 'Podman não está conectado a uma máquina em execução. Abra o Podman Desktop e inicie a máquina Hyper-V.'
}
if ($podmanInfo.Trim() -ne 'false') {
    throw 'Este build do instalador exige a conexão rootful do Podman. Configure a máquina como rootful no Podman Desktop.'
}

$buildId = Get-Date -Format 'yyyyMMddHHmmss'
$outputDirectory = Join-Path $PSScriptRoot (Join-Path 'output' "build-$buildId")
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$outputVolume = "arenaos-output-$buildId"
$copyContainer = "arenaos-output-copy-$buildId"

Write-Host '1/3 Compilando a imagem ArenaOS (Bazzite KDE NVIDIA + Chrome)...'
& podman build --file (Join-Path $PSScriptRoot 'Containerfile') --tag localhost/arenaos:latest $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar a imagem ArenaOS.' }

Write-Host '2/3 Compilando o instalador interativo...'
& podman build --file (Join-Path $PSScriptRoot 'Containerfile.installer') `
    --build-arg 'ARENAOS_IMAGE=localhost/arenaos:latest' `
    --tag localhost/arenaos-installer:latest $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar a imagem do instalador.' }

Write-Host '3/3 Gerando a ISO personalizada...'
& podman run --rm --privileged --pull=newer `
    --security-opt label=type:unconfined_t `
    --volume "${outputVolume}:/output" `
    --volume '/var/lib/containers/storage:/var/lib/containers/storage' `
    quay.io/centos-bootc/bootc-image-builder:latest `
    --type bootc-installer `
    --local `
    --bootc-installer-payload-ref localhost/arenaos:latest `
    --rootfs btrfs `
    --output /output `
    localhost/arenaos-installer:latest
if ($LASTEXITCODE -ne 0) { throw 'Falha ao gerar a ISO. Veja a mensagem de erro acima.' }

Write-Host 'Copiando os arquivos gerados para a pasta output do Windows...'
& podman create --name $copyContainer --volume "${outputVolume}:/iso-output:ro" localhost/arenaos-installer:latest
if ($LASTEXITCODE -ne 0) { throw 'Não consegui preparar a cópia dos arquivos para o Windows.' }
& podman cp "${copyContainer}:/iso-output/." $outputDirectory
if ($LASTEXITCODE -ne 0) { throw 'Não consegui copiar a ISO para a pasta output do Windows.' }
& podman rm $copyContainer | Out-Null
& podman volume rm $outputVolume | Out-Null

$isos = Get-ChildItem -Path $outputDirectory -Filter '*.iso' -Recurse
if (-not $isos) { throw "O build terminou sem encontrar uma ISO em $outputDirectory" }

Write-Host "ISO(s) gerada(s) em: $outputDirectory"
$isos | ForEach-Object {
    Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName | Format-Table Path, Hash -AutoSize
}
