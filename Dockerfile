FROM debian:stable-slim
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    G_SLICE=always-malloc \
    NO_VNC_HOME=/usr/share/usr/local/share/noVNCdim
RUN apt update \
    && apt install --no-install-recommends -y \
    ca-certificates x11-xkb-utils xkbset jq wget curl unzip locales fonts-noto-cjk \
# desktop
    pcmanfm tint2 openbox xauth xinit \
    && locale-gen en_US.UTF-8 \
    && echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
# tigervnc
    && export TIGERVNC_LATEST_VERSION=$(curl -sL "https://sourceforge.net/projects/tigervnc/files/stable/" | grep -oP "/projects/tigervnc/files/stable/[0-9.]+" | cut -d'/' -f6 | sort -V | tail -n 1) \
    && wget --no-check-certificate -qO- "https://sourceforge.net/projects/tigervnc/files/stable/${TIGERVNC_LATEST_VERSION}/tigervnc-${TIGERVNC_LATEST_VERSION}.x86_64.tar.gz" | tar xz --strip 1 -C / \
# novnc
    && apt install --no-install-recommends -y python3-numpy libxshmfence1 libasound2 libxcvt0 libgbm1 \
    && mkdir -p "${NO_VNC_HOME}/utils/websockify" \
    && wget --no-check-certificate -qO- "$(curl -s https://api.github.com/repos/novnc/noVNC/releases/latest | jq -r '.tarball_url')" | tar xz --strip 1 -C "${NO_VNC_HOME}" \
    && wget --no-check-certificate -qO- "$(curl -s https://api.github.com/repos/novnc/websockify/releases/latest | jq -r '.tarball_url')" | tar xz --strip 1 -C "${NO_VNC_HOME}/utils/websockify" \
    && chmod +x "${NO_VNC_HOME}/utils/novnc_proxy" \
    && sed -i '1s/^/if(localStorage.getItem("resize") == null){localStorage.setItem("resize","remote");}\n/' "${NO_VNC_HOME}/app/ui.js" \
    && rm -rf /usr/share/doc /usr/share/man \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
