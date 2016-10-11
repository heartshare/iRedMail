#!/bin/bash

## files
CONFIG_FILE_TMP=/opt/iredmail/config.iredmail
CONFIG_FILE_IRE=/opt/iredmail/iRedMail.Last/config
PASSWD_GENERATOR=$(openssl rand -base64 16)
LOGFILE=/opt/iredmail/iredmail-install.log

replace_iredmail() {

    # Replace first domain in hosts file
    echo -e "127.0.0.1   mail.$DOMAIN   mail     localhost \n" >> /etc/hosts
    echo -e "::1         mail.$DOMAIN   mail     localhost \n" >> /etc/hosts
    # Replace nameserver
    echo -e "nameserver 8.8.8.8 \nnameserver 8.8.4.4 \n" > /etc/resolv.conf
    # copy config iredmail file
    mv $CONFIG_FILE_TMP $CONFIG_FILE_IRE    
    # replace password
    sed -i "s/MYSQL_ROOT_PASSWD=.*/MYSQL_ROOT_PASSWD='$PASSWD'/g" $CONFIG_FILE_IRE
    sed -i "s/DOMAIN_ADMIN_PASSWD_PLAIN=.*/DOMAIN_ADMIN_PASSWD_PLAIN='$PASSWD'/g" $CONFIG_FILE_IRE
    sed -i "s/DOMAIN_ADMIN_PASSWD=.*/DOMAIN_ADMIN_PASSWD='$PASSWD'/g" $CONFIG_FILE_IRE
    sed -i "s/SITE_ADMIN_PASSWD=.*/SITE_ADMIN_PASSWD='$PASSWD'/g" $CONFIG_FILE_IRE
    sed -i "s/FIRST_USER_PASSWD=.*/FIRST_USER_PASSWD='$PASSWD'/g" $CONFIG_FILE_IRE
    sed -i "s/FIRST_USER_PASSWD_PLAIN=.*/FIRST_USER_PASSWD_PLAIN='$PASSWD'/g" $CONFIG_FILE_IRE
    # replace domain
    sed -i "s/FIRST_DOMAIN=.*/FIRST_DOMAIN='$DOMAIN'/g" $CONFIG_FILE_IRE
    sed -i "s/SITE_ADMIN_NAME='postmaster@.*/SITE_ADMIN_NAME='postmaster@$DOMAIN'/g" $CONFIG_FILE_IRE
    # password generator
    sed -i "s/VMAIL_DB_BIND_PASSWD=.*/VMAIL_DB_BIND_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/VMAIL_DB_ADMIN_PASSWD=.*/VMAIL_DB_ADMIN_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/LDAP_BINDPW=.*/LDAP_BINDPW='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/LDAP_ADMIN_PW=.*/LDAP_ADMIN_PW='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/AMAVISD_DB_PASSWD=.*/AMAVISD_DB_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/CLUEBRINGER_DB_PASSWD=.*/CLUEBRINGER_DB_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/IREDADMIN_DB_PASSWD=.*/IREDADMIN_DB_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/RCM_DB_PASSWD=.*/RCM_DB_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/SOGO_DB_PASSWD=.*/SOGO_DB_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE
    sed -i "s/SOGO_SIEVE_MASTER_PASSWD=.*/SOGO_SIEVE_MASTER_PASSWD='$PASSWD_GENERATOR'/g" $CONFIG_FILE_IRE

}

# install iredmail
install_iredmail() {

    IREDMAIL_DEBUG='NO' \
    AUTO_USE_EXISTING_CONFIG_FILE=y \
    AUTO_INSTALL_WITHOUT_CONFIRM=y \
    AUTO_CLEANUP_REMOVE_SENDMAIL=y \
    AUTO_CLEANUP_REMOVE_MOD_PYTHON=y \
    AUTO_CLEANUP_REPLACE_FIREWALL_RULES=n \
    AUTO_CLEANUP_RESTART_IPTABLES=y \
    AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y \
    AUTO_CLEANUP_RESTART_POSTFIX=n \
    bash /opt/iredmail/iRedMail.Last/iRedMail.sh >> $LOGFILE

}

# Check if config file exists
iredmail() {

    #check config file
    if [ ! -f /opt/iredmail/iRedMail.Last/config ]; then

        if [ ! -f /var/vmail/iredmail.cfg ]; then
          . /opt/iredmail/iredmail.cfg
        else
          . /var/vmail/iredmail.cfg
          rm -f /var/vmail/iredmail.cfg
        fi

        replace_iredmail
        install_iredmail
        # enable services
        /usr/bin/systemctl enable mariadb.service
        /usr/bin/systemctl enable postfix.service
        /usr/bin/systemctl enable dovecot.service
        /usr/bin/systemctl enable nginx.service
        /usr/bin/systemctl enable php-fpm.service
        /usr/bin/systemctl enable iredapd.service
        /usr/bin/systemctl enable clamd@amavisd.service
        /usr/bin/systemctl enable cbpolicyd.service
        /usr/bin/systemctl enable amavisd.service
        /usr/bin/systemctl enable uwsgi.service
        /usr/bin/systemctl enable rsyslog.service
        /usr/bin/systemctl enable crond.service
        # run services
        /usr/bin/systemctl start mariadb.service
        /usr/bin/systemctl start postfix.service
        /usr/bin/systemctl start dovecot.service
        /usr/bin/systemctl start nginx.service
        /usr/bin/systemctl start php-fpm.service
        /usr/bin/systemctl start iredapd.service
        /usr/bin/systemctl start clamd@amavisd.service
        /usr/bin/systemctl start cbpolicyd.service
        /usr/bin/systemctl start amavisd.service
        /usr/bin/systemctl start uwsgi.service
        /usr/bin/systemctl start rsyslog.service
        /usr/bin/systemctl start crond.service
        # remove iredmail install script
        /usr/bin/systemctl disable iredmail-install.service
        /usr/bin/systemctl stop iredmail-install.service

        rm -f /opt/iredmail/iRedMail.Last/config
        touch /opt/iredmail/iRedMail.Last/config
    fi

}
# Install iRedmail
iredmail
