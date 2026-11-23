# ArenaOS

Uma imagem Linux para jogos, baseada no Bazzite Desktop KDE e preparada para o PC com RTX 4060.

## O que a imagem inclui

- Steam, utilitários de jogos, KDE Plasma e driver NVIDIA herdados do Bazzite `nvidia-open`.
- Google Chrome instalado na imagem a partir do RPM estável oficial para x86_64.
- KDE Plasma com painel inferior e menu de aplicativos, mantendo um fluxo familiar para quem vem do Windows.
- Interface KDE com painel inferior e menu de aplicativos, em um fluxo familiar para quem vem do Windows.

## Compilar a ISO no Windows

O script `build-iso.ps1` compila a imagem ArenaOS, monta um instalador interativo com seleção de disco e gera a ISO localmente. Ele usa Podman Desktop com Hyper-V; não precisa de GitHub Actions nem WSL.

1. Instale o [Podman Desktop para Windows](https://podman-desktop.io/downloads/windows). Se preferir, use `winget install -e --id RedHat.Podman-Desktop`.
2. Como o WSL está bloqueado neste PC, configure o provider **Hyper-V**. No PowerShell como administrador, habilite o recurso e reinicie:

   ```bash
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   ```

3. No Podman Desktop, instale Podman e crie uma máquina Hyper-V rootful. Para este PC, reserve aproximadamente 10 GB de RAM e 100 GB de disco para a máquina de build. Ative a conexão **rootful**.
4. Extraia `ArenaOS-source.zip`, abra PowerShell na pasta `ArenaOS` e rode:

   ```powershell
   .\build-iso.ps1
   ```

5. A ISO aparecerá em uma subpasta de `ArenaOS\output`. Grave-a em um pendrive de pelo menos 16 GB e, ao instalar, confira com cuidado que o destino é o SSD de teste.

O build baixa a base Bazzite, o Chrome e os componentes do instalador, então precisa de internet e bastante espaço em disco. O instalador gerado é interativo para você selecionar o disco; ele não seleciona o primeiro disco automaticamente.

O Google Chrome é proprietário; na primeira abertura, o usuário precisa aceitar os termos do Google. A receita usa o RPM x86_64 fornecido no canal oficial do Chrome.

## Fontes

- [Bazzite: imagens, Steam, NVIDIA e KDE](https://bazzite.gg/)
- [Template oficial Universal Blue para imagem personalizada e ISO](https://github.com/ublue-os/image-template)
- [Instalar Google Chrome no Linux](https://support.google.com/chrome/answer/95346)
- [Criar imagem personalizada do Bazzite](https://docs.bazzite.gg/Advanced/creating_custom_image/)
- [Podman Desktop no Windows e provider Hyper-V](https://podman-desktop.io/docs/installation/windows-install)
- [ISO interativa com payload bootc](https://osbuild.org/docs/developer-guide/projects/image-builder/advanced/bootc/isos/)
