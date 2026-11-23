# ArenaOS: Bazzite KDE desktop custom image for the RTX 4060.
FROM ghcr.io/ublue-os/bazzite-nvidia-open:stable

# Google Chrome installs files under /opt. Make it a real directory so RPM
# upgrades remain reliable on this image-based operating system.
RUN if [ -L /opt ]; then rm /opt; fi && mkdir -p /opt

# Steam, KDE Plasma, gaming tools, and the NVIDIA driver come from Bazzite.
# Chrome is installed from Google's official stable x86_64 RPM.
COPY google-chrome.repo /etc/yum.repos.d/google-chrome.repo
RUN dnf5 install -y google-chrome-stable \
    && dnf5 clean all \
    && bootc container lint
