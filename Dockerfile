# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSHOT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# title
ENV TITLE=OpenShot \
    NO_GAMEPAD=true \
    PIXELFLUX_WAYLAND=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/openshot-logo.png && \
  echo "**** install packages ****" && \
  add-apt-repository ppa:openshot.developers/ppa && \
  if [ -z ${OPENSHOT_VERSION+x} ]; then \
    OPENSHOT="openshot-qt"; \
  else \
    OPENSHOT="openshot-qt=${OPENSHOT_VERSION}"; \
  fi && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends \
    ${OPENSHOT} && \
  echo "**** symlink binary ****" && \
  mkdir -p /opt/openshot/usr/bin && \
  ln -s \
    /usr/bin/openshot-qt \
    /opt/openshot/usr/bin/openshot-qt-launch && \
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
