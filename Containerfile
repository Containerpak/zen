FROM ubuntu:26.04 AS source

ARG APP_SHA256=a70f0e92de77c43c9f86ae5210849bf2c8c86dee571eb43957d87e3b4ffbdb9d

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    curl --fail --location --output /tmp/zen-x86_64.AppImage "https://github.com/zen-browser/desktop/releases/download/1.21.13b/zen-x86_64.AppImage" && \
    echo "${APP_SHA256}  /tmp/zen-x86_64.AppImage" | sha256sum --check

FROM ghcr.io/containerpak/mesa:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/zen"

COPY --from=source /tmp/zen-x86_64.AppImage /tmp/zen-x86_64.AppImage
COPY zen /usr/bin/zen
COPY app.zen_browser.zen.desktop /usr/share/applications/app.zen_browser.zen.desktop

RUN apt-get update && \
    apt-get install -y --no-install-recommends squashfs-tools && \
    chmod +x /tmp/zen-x86_64.AppImage && \
    /tmp/zen-x86_64.AppImage --appimage-extract && \
    mv squashfs-root /opt/zen && \
    chmod 0755 /usr/bin/zen && \
    if [ -e /opt/zen/.DirIcon ]; then install -Dm644 /opt/zen/.DirIcon /usr/share/icons/hicolor/256x256/apps/app.zen_browser.zen.png; fi && \
    rm -rf /tmp/zen-x86_64.AppImage /tmp/archive && \
    cpak-clean-junk

