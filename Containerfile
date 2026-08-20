FROM ubuntu:26.04 AS source

ADD --checksum=sha256:349704871522e0085f3b505d629009490eefb3f06ee67a87ea106dcb1395ccfe https://github.com/zen-browser/desktop/releases/download/1.21.15b/zen-x86_64.AppImage /tmp/source

RUN chmod 0755 /tmp/source && \
    cd /tmp && \
    ./source --appimage-extract >/dev/null && \
    mkdir -p /stage && \
    cp -a /tmp/squashfs-root/. /stage/

FROM ghcr.io/containerpak/gtk3:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/zen"

COPY --from=source /stage/ /opt/zen/
COPY zen /usr/bin/zen
COPY app.zen_browser.zen.desktop /usr/share/applications/app.zen_browser.zen.desktop

RUN chmod 0755 /usr/bin/zen && \
    if [ -e /opt/zen/.DirIcon ]; then install -Dm644 /opt/zen/.DirIcon /usr/share/icons/hicolor/256x256/apps/app.zen_browser.zen.png; fi && \
    cpak-clean-junk
