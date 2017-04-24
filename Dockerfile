FROM ubuntu:xenial
MAINTAINER Megam systems  <info@megam.io>

ENV VERSION 5.2.1
ENV DEB_VERSION 5.2.1-1

ENV ONE_URL http://downloads.opennebula.org/packages/opennebula-$VERSION/ubuntu1604/opennebula-$DEB_VERSION.tar.gz

RUN buildDeps=' \
        ca-certificates \
        curl \
        netcat-openbsd \
        bridge-utils \
        apt-utils \
        sudo \
        apt-transport-https \
    ' \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && curl -fSL "$ONE_URL" -o one.tar.gz \
    && mkdir -p debs \
    && tar -xvf one.tar.gz -C debs --strip-components=1 \
    && rm one.tar.gz \
    && cd debs \
    && dpkg -i opennebula-common*.deb \
    && dpkg -i opennebula-flow*.deb \
    && dpkg -i opennebula-gate*.deb \
    && dpkg -i opennebula-sunstone*.deb \
    && dpkg -i opennebula-tools*.deb \
    && dpkg -i opennebula_$DEB_VERSION_amd64.deb \
    && dpkg -i ruby*.deb \
    ; apt-get install -fy --no-install-recommends \
    && gem install treetop parse-cron \
    && apt-get install -y --no-install-recommends openssh-server \
    && rm -fv /etc/ssh/ssh_host* \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* \
    && cd ../../ \
    && rm -r debs \
    
COPY start.sh /

CMD ["/start.sh"]
