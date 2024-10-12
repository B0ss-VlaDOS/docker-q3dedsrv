#!/bin/sh

# Получаем IP-адрес контейнера
IP_ADDRESS=$(hostname -i)

# Создаём файл конфигурации сервера Quake 3
echo "// Basic Quake III Server Configuration
set fs_game \"baseq3\"
seta sv_hostname \"Simai Arena\"
set sv_master1 \"authorize.quake3arena.com\"
set net_ip  $IP_ADDRESS
set sv_pure 0
set net_port 27960
set dedicated 2
seta sv_maxclients 16
seta sv_mapRotation \"q3dm17 q3dm6 q3dm8 q3dm1\"
seta g_mapRotation 1
seta g_gametype 0
seta g_needpass 0
seta log 1
seta logfile \"server.log\"
seta sv_timeout 200
map q3dm6" > /usr/local/games/quake3/baseq3/server.cfg

RUN chmod -R 777 /usr/local/games/quake3/baseq3/server.cfg

/usr/local/games/quake3/q3ded +exec server.cfg
