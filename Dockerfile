#
# iRedmail Dockerfile на базе последней версии CentOS 7
#

# Генерация:
# docker build -t vlavd/iredmail:latest .
#
# Создание:
# docker create --privileged -it --restart=always -p 80:80 -p 443:443 -p 25:25 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -h your_domain.com --name ИМЯ_КОНТЕЙНЕРА vlavad/iredmail
#
# Запуск:
# docker start ИМЯ_КОНТЕЙНЕРА
#
# Вход в контейнер:
# docker exec -it ИМЯ_КОНТЕЙНЕРА bash


# Базовый образ
FROM centos

# Автор и его почта
MAINTAINER VlaVad <vlavad@gmail.com>

# Переменные окружения:
# - версия iRedMail
ENV IREDMAIL_VERSION 0.9.5-1
# - тип контейнера
ENV container docker

# Install packages necessary:
RUN yum update -y; yum install -y tar bzip2 hostname rsyslog wget

# Install packages neccesary to install iredmail server
RUN yum install -y postfix openldap openldap-clients openldap-servers maria mariadb-server mod_ldap php-common php-gd php-xml php-mysql php-ldap php-pgsql php-imap php-mbstring php-pecl-apc php-intl php-mcrypt nginx php-fpm cluebringer dovecot dovecot-pigeonhole dovecot-mysql clamav clamav-update clamav-server clamav-server-systemd amavisd-new spamassassin altermime perl-LDAP perl-Mail-SPF unrar mc lynx net-tools


# Get iredmail, extract and remove tar
RUN mkdir -p /opt/iredmail; \
    cd /opt/iredmail; \
    wget -c https://bitbucket.org/zhb/iredmail/downloads/iRedMail-$IREDMAIL_VERSION.tar.bz2; \
    tar xjf iRedMail-$IREDMAIL_VERSION.tar.bz2; \
    rm iRedMail-$IREDMAIL_VERSION.tar.bz2

# Install systemd
RUN yum -y reinstall systemd; yum clean all; \
     (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
     rm -f /lib/systemd/system/multi-user.target.wants/*;\
     rm -f /etc/systemd/system/*.wants/*;\
     rm -f /lib/systemd/system/local-fs.target.wants/*; \
     rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
     rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
     rm -f /lib/systemd/system/basic.target.wants/*;\
     rm -f /lib/systemd/system/anaconda.target.wants/*;

# Copy script and config files
ADD iredmail/config.iredmail /opt/iredmail/
ADD iredmail/iredmail.sh /opt/iredmail/iredmail.sh
ADD iredmail.cfg /opt/iredmail/iredmail.cfg
ADD iredmail/iredmail-install.service /etc/systemd/system/iredmail-install.service

RUN chmod +x /opt/iredmail/iredmail.sh
RUN ln -s /etc/systemd/system/iredmail-install.service /etc/systemd/system/multi-user.target.wants/iredmail-service.service

# Set volume for systemd
VOLUME [ "/sys/fs/cgroup" ]

# Open Ports:
# Apache: 80/tcp, 443/tcp Postfix: 25/tcp, 587/tcp
# Dovecot: 110/tcp, 143/tcp, 993/tcp, 995/tcp
EXPOSE 80 443 25 587 110 143 993 995

# iredmail directory
WORKDIR /opt/iredmail

# Run systemd
CMD ["/usr/sbin/init"]
