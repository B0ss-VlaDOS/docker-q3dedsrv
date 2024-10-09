# QUAKE 3 Docker Dedicated Server

Для запуска необходимо скопировать в корень папку baseq3 из развернутой игры, собрать образ в докере и запустить контейнер

 Сборка - docker build -t quake3-server .
 Запуск - docker run -d -p 27960:27960/udp -p 22:22 quake3-server
 Вход в контейнер - docker exec <номер контейнера>
 
 - (!) Не забыть открыть порт 27960 на хост машине.

