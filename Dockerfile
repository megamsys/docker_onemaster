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
    && dpkg -i libopennebula*.deb  opennebula-common*.deb  opennebula-flow*.deb opennebula-gate*.deb opennebula-sunstone*.deb opennebula-tools*.deb  opennebula_$VERSION*.deb ruby*.deb \
    ; apt-get install -fy --no-install-recommends \
    && gem install treetop parse-cron \
    && apt-get install -y --no-install-recommends openssh-server \
    && rm -fv /etc/ssh/ssh_host* \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* \
    && cd ../../ \
    && rm -r debs \
    && su - oneadmin -c "one start" \
    &&	su - oneadmin -c "sunstone-server start" \
    &&	su - oneadmin -c "oneflow-server start" \
    &&	cat /var/lib/one/.one/one_auth \
    &&	mkdir -p /var/run/sshd \
    &&	sed -i "s/^Port 22$/Port 2222/" /etc/ssh/sshd_config \
    &&	sed -i "s/UsePAM yes/UsePAM no/" /etc/ssh/sshd_config \
    &&	dpkg-reconfigure openssh-server \
    &&	/usr/sbin/sshd -E /var/log/sshd.log \
    &&	if [ ! -e /READY ]; then \
    		su - oneadmin -c "mkdir -p .ssh" ;\
    		su - oneadmin -c "ssh-keygen -q -f .ssh/id_ed25519 -N \"\" -t ed25519 -C \"\$USER@\$HOSTNAME\""; \
    		su - oneadmin -c "touch /var/lib/one/.ssh/config" ;\
    		cat >> /var/lib/one/.ssh/config<<EOF \
    Host * \
    port 2222 \
    user oneadmin \
    StrictHostKeyChecking no \
    EOF ;\
    		cat /var/lib/one/.ssh/id_ed25519.pub ;\
    		cat /var/lib/one/.ssh/id_ed25519.pub > /var/lib/one/.ssh/authorized_keys2; \
    		chown oneadmin. /var/lib/one/.ssh/authorized_keys2; \
    		touch /READY ;\
      fi
