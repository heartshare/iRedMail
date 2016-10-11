Docker-контейнер с почтовым сервером iRedmail на базе CentOS 7
==============================================================

Создание
--------

::

  docker create --privileged -it --restart=always \
                -p 80:80 \
                -p 443:443 \
                -p 25:25 \
                -p 587:587 \
                -p 110:110 \
                -p 143:143 \
                -p 993:993 \
                -p 995:995 \
                -h your_domain.com \
                --name ИМЯ_КОНТЕЙНЕРА \
                vlavad/iredmail

По умолчанию:

- почтовый домен: home.net;
- учетная запись администратора и первый почтовй ящик: postmaster@home.net
- пароль: iRedMail

Для смены параметров по умолчанию при создании контейнера задать опцию::

  -v КАТАЛОГ_ДЛЯ_var_vmail:/var/vmail

Создать файл::

  КАТАЛОГ_ДЛЯ_var_vmail/iredmail.cfg

содержащий::

  DOMAIN="home.net"
  PASSWD="iRedMail"

После инсталяции файл ``КАТАЛОГ_ДЛЯ_var_vmail/iredmail.cfg`` удаляется!

Дополнительные параметры
------------------------
::

    -v КАТАЛОГ_ДЛЯ_sys_fs_cgroup:/sys/fs/cgroup
    -v КАТАЛОГ_ДЛЯ_var_www:/var/www
    -v КАТАЛОГ_ДЛЯ_etc:/etc
    -v КАТАЛОГ_ДЛЯ_var_lib:/var/lib
    -v КАТАЛОГ_ДЛЯ_var_vmail:/var/vmail

Запуск
------
::

  docker start ИМЯ_КОНТЕЙНЕРА

Вход в контейнер
----------------
::

  docker exec -it ИМЯ_КОНТЕЙНЕРА bash

