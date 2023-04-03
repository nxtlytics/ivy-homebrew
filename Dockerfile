FROM ubuntu:jammy-20230308

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TERM=linux
COPY 01_nodoc /etc/dpkg/dpkg.conf.d/01_nodoc
COPY 01_norecommend /etc/apt/apt.conf.d/01_norecommend

RUN echo 'deb http://archive.ubuntu.com/ubuntu/ jammy-proposed restricted main multiverse universe' > /etc/apt/sources.list.d/jammy-proposed.list \
    && apt update \
    && apt full-upgrade -y \
    && apt install -y \
         build-essential \
         procps \
         curl \
         file \
         git \
         adduser \
         byacc \
         ca-certificates \
    && mkdir -p ${HOME}/bash \
    && cd ${HOME}/bash \
    && curl -sLO 'http://ftp.gnu.org/gnu/bash/bash-3.2.57.tar.gz' \
    && tar xvzf bash-3.2.57.tar.gz \
    && cd bash-3.2.57 \
    && ./configure --prefix=/opt/bash32 \
    && make install \
    && adduser --disabled-password --shell /opt/bash32/bin/bash linuxbrew \
    && echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers \
    && apt autoremove -yqq --purge \
    && apt clean all \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/log/apt/* \
      /var/log/alternatives.log \
      /var/log/bootstrap.log \
      /var/log/dpkg.log \
      /var/tmp/* \
      /tmp/*

USER linuxbrew
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    SHELL=/opt/bash32/bin/bash \
    USER=linuxbrew

RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && hash -r \
    && brew update \
    && brew upgrade \
    && brew cleanup

ENTRYPOINT ["/opt/bash32/bin/bash"]

ADD .VERSION /opt/ivy/meta/HOMEBREW_VERSION
