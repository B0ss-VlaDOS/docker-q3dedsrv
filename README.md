# QUAKE 3 Docker Dedicated Server

Для запуска необходимо скопировать в корень папку baseq3 из установленной игры, собрать образ в докере и запустить контейнер

 Сборка:
 - docker build -t quake3-server .
 
 Запуск:
 - docker run -d -p 27960:27960/udp -p 22:22 quake3-server

 Вход в контейнер:
 - docker exec -it <номер контейнера> /usr/local/games/quake3/q3ded <параметры>

 - (!) Не забыть открыть порт 27960 на хост машине.

