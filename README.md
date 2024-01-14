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

# Docker-3
Разбил монолит на микромерсвисы.
Оптимизировал размер образов микросервисов с помощью базовых образов на alpine
Для запуска прилодения выполнить команды:
```shell
docker network create reddit
docker run -d --network reddit --network-alias mongodb --name mongodb -v reddit_db:/data/db mongo:latest
docker run -d --network reddit --network-alias app_post --name app_post --env POST_DATABASE_HOST=mongodb rshalgochev/post:1.0
docker run -d --network reddit --network-alias app_comment --name app_comment --env COMMENT_DATABASE_HOST=mongodb rshalgochev/comment:2.0
docker run -d --network reddit --name app_ui -p 9292:9292 --env POST_SERVICE_HOST=app_post --env COMMENT_SERVICE_HOST=app_comment rshalgochev/ui:2.0
```
Проверить рабоу прилодения можно перейдя в браузере по адресу http://127.0.0.1:9292

Чтобы остановить запущенное прилоджение выоплнить команду:
```shell
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
```
# Docker-4
Написал docker-compose.yml
Чтобы чтобы развернуть прилоение выполнить команду
```shell
docker-compose up -d
```
Если Необходимо переопределить стандартный префикс проекта, то запустить необходимо командой
```shell
docker-compose -p "PROJECT_NAME" up -d
```
# Gitlab
Автоматизировал запуск сервера gitlab.
Чтобы запустить сервер необходимо в директории gitlab-ci/terraform создать файл terrafotm.tfvars из файла
terrafotm.tfvars.exmple. Затем выполнить команду:
```shell
terraform apply
```
Дождаться создания ВМ в облаке и запуска сервера gitlab-ci. Затем подключиться по ssh и провести первоначальную настройку
самого gitlab, а имено - настроить пароль для пользователя root.
Далее можно выполнить нужные настройки в web-части сервиса.
После создания проекта необходимо перейти в настройки CI/CD, узнать там токен для регитсрации gitlab-runner и запустить
в директории gitlab-ci/ansible плейбук, который зарегистрирует раннер командой:
```shell
ansible-playbook register_runner.yml -e gitlab_token=your_token -e gitlab_url=your_gitlab_url
```
# Monitoring
Добавил конфигурацию для запуска мониторинга.
Для запуска выполнить следующий порядок действий:
1. Выполнить сборку образов сервисов и компонентов мониторинга, для этого можно использовать готовый Makefile. Команда для сборки:
```shell
    export USER_NAME=your_docker_user
    make build
    make push
```
2. Перейти в директорию docker и заполнить .env файл, образец заполнения в .env.example
3. Запустить порилождение и систему мониторинга командой
```shell
    docker-compose up -d
```
4. Для проверки работы мониторинга перейти в браузере по адресу http://ip_сервера:9090
