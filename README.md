# iRedmail Dockerfile на базе последней версии CentOS 7

##Генерация:

```
docker build -t vlavd/iredmail:latest .

##Создание:

```

docker create --privileged -it --restart=always -p 80:80 -p 443:443 -p 25:25 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -h your_domain.com --name ИМЯ_КОНТЕЙНЕРА vlavad/iredmail

##Запуск:

```
docker start ИМЯ_КОНТЕЙНЕРА

##Вход в контейнер:

````
docker exec -it ИМЯ_КОНТЕЙНЕРА bash
