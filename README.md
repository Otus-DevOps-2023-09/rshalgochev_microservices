# rshalgochev_microservices
rshalgochev microservices repository
# Docker-2
Добавил Dockerfile
Чтобы собрать свой образ необходимо:
1. Перейти в директорию docker-monolith
2. Выполнить комманду
```shell
docker build -t reddit:local-test .
```
3. Для запуска прилодения выполнить команду:
```shell
docker run -d -p 9292:9292 --name reddit reddit:local-test
```
4. Для проверки работы приложения в адресной строке браузера ввести
http://127.0.0.1:9292
Также ддобавил все необходимое для автоматизации развертывания прилодения в облачной инфраструктуре.
