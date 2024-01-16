FROM debian:latest
LABEL maintainer="Mykhailo Didur <mikhaildidur2003@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN apt-get install -q -y supervisor cron openssh-server pwgen reprepro screen vim-tiny nginx nano

RUN sed -i 's/\(session *required *pam_loginuid.so\)/#\1/' /etc/pam.d/cron

RUN mkdir /var/run/sshd
RUN service ssh stop

RUN mkdir -p /var/lib/reprepro/conf
ADD configs/reprepro-distributions /var/lib/reprepro/conf/distributions

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/sites-enabled/default
ADD configs/nginx-default.conf /etc/nginx/sites-enabled/default

RUN echo "root:docker" | chpasswd
RUN echo "root ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

RUN mkdir /home/user
RUN mkdir -p /docker/incoming
RUN useradd -d /home/user -s /bin/bash user
RUN chown -R user /home/user
RUN chown -R user /docker/incoming
RUN echo "user:12345" | chpasswd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN service supervisor stop
ADD configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD configs/supervisor-cron.conf /etc/supervisor/conf.d/cron.conf
ADD configs/supervisor-ssh.conf /etc/supervisor/conf.d/ssh.conf
ADD configs/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf

ENV DEBIAN_FRONTEND newt

ADD scripts/start.sh /usr/local/sbin/start
RUN chmod 755 /usr/local/sbin/start

ADD scripts/deb-import /usr/local/sbin/deb-import
RUN chmod 755 /usr/local/sbin/deb-import

VOLUME ["/docker/keys", "/docker/incoming", "/repository"]

EXPOSE 80
EXPOSE 22

USER root

CMD ["/usr/local/sbin/start"]
