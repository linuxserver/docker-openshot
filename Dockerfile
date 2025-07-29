# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSHOT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# title
ENV TITLE=OpenShot

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/openshot-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 && \
  echo "**** install openshot from appimage ****" && \
  if [ -z ${OPENSHOT_VERSION+x} ]; then \
    OPENSHOT_VERSION=$(curl -sX GET "https://api.github.com/repos/openshot/openshot-qt/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  curl -fo \
    /tmp/openshot.app -L \
    "https://github.com/openshot/openshot-qt/releases/download/${OPENSHOT_VERSION}/OpenShot-${OPENSHOT_VERSION}-x86_64.AppImage" && \
  chmod +x /tmp/openshot.app && \
  ./openshot.app --appimage-extract && \
  mv squashfs-root /opt/openshot && \
  find /opt/openshot -type d -exec chmod go+rx {} + && \
  chmod +x /opt/openshot/usr/bin/openshot-qt-launch && \
  cp \
    /opt/openshot/usr/share/icons/hicolor/scalable/apps/openshot-qt.svg \
    /usr/share/icons/hicolor/scalable/apps/openshot-qt.svg && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
