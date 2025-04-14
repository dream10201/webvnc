FROM debian:stable-slim AS base
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive
RUN apt update \
    && apt install --no-install-recommends -y ca-certificates x11-xkb-utils xkbset wget curl unzip locales fonts-noto-cjk \
    && locale-gen en_US.UTF-8 \
    && echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

FROM base AS desktop
ENV G_SLICE=always-malloc
RUN apt install --no-install-recommends -y pcmanfm tint2 openbox xauth xinit

FROM desktop AS tigervnc
RUN wget --no-check-certificate -qO- https://sourceforge.net/projects/tigervnc/files/stable/1.15.0/tigervnc-1.15.0.x86_64.tar.gz | tar xz --strip 1 -C /


FROM tigervnc AS novnc
ENV NO_VNC_HOME=/usr/share/usr/local/share/noVNCdim
RUN apt install --no-install-recommends -y python3-numpy libxshmfence1 libasound2 libxcvt0 libgbm1 \
    && mkdir -p "${NO_VNC_HOME}/utils/websockify" \
    && wget --no-check-certificate -qO- "https://github.com/novnc/noVNC/archive/v1.6.0.tar.gz" | tar xz --strip 1 -C "${NO_VNC_HOME}" \
    && wget --no-check-certificate -qO- "https://github.com/novnc/websockify/archive/v0.13.0.tar.gz" | tar xz --strip 1 -C "${NO_VNC_HOME}/utils/websockify" \
    && chmod +x -v "${NO_VNC_HOME}/utils/novnc_proxy" \
    && sed -i '1s/^/if(localStorage.getItem("resize") == null){localStorage.setItem("resize","remote");}\n/' "${NO_VNC_HOME}/app/ui.js" \
    && rm -rf /usr/share/doc /usr/share/man