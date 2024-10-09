# Используем официальный 64-битный образ Ubuntu 24.04 LTS (или 22.04 LTS, если проблемы сохраняются)
FROM ubuntu:24.04

# Устанавливаем переменную окружения для предотвращения интерактивных запросов
ENV DEBIAN_FRONTEND=noninteractive

# Обновляем списки пакетов, устанавливаем основные инструменты и включаем необходимые репозитории
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386 && \
    apt-get update

# Устанавливаем все необходимые пакеты в одной команде
# Установка sudo
RUN apt-get install -y sudo || { echo "Не удалось установить sudo"; exit 1; }

RUN apt-get install -y net-tools || { echo "Не удалось установить sudo"; exit 1; }

# Установка openssh-server
RUN apt-get install -y openssh-server || { echo "Не удалось установить openssh-server"; exit 1; }

# Установка wget
RUN apt-get install -y wget || { echo "Не удалось установить wget"; exit 1; }

# Установка curl
RUN apt-get install -y curl || { echo "Не удалось установить curl"; exit 1; }

# Установка lib32gcc-s1 (без указания архитектуры)
RUN apt-get install -y lib32gcc-s1 || { echo "Не удалось установить lib32gcc-s1"; exit 1; }

# Установка libstdc++6:i386
RUN apt-get install -y libstdc++6:i386 || { echo "Не удалось установить libstdc++6:i386"; exit 1; }

# Установка libc6:i386
RUN apt-get install -y libc6:i386 || { echo "Не удалось установить libc6:i386"; exit 1; }

# Установка zlib1g:i386
RUN apt-get install -y zlib1g:i386 || { echo "Не удалось установить zlib1g:i386"; exit 1; }

# Установка libncurses6:i386
RUN apt-get install -y libncurses6:i386 || { echo "Не удалось установить libncurses6:i386"; exit 1; }

# Установка libsdl1.2debian:i386
RUN apt-get install -y libsdl1.2debian:i386 || { echo "Не удалось установить libsdl1.2debian:i386"; exit 1; }

# Установка except
RUN apt-get install -y expect || { echo "Не удалось установить except"; exit 1; }

# Установка binwalk
# RUN apt-get install -y binwalk || { echo "Не удалось установить binwalk"; exit 1; }

# Очистка кэша apt после всех установок
RUN rm -rf /var/lib/apt/lists/*

# Настраиваем SSH-сервер
RUN mkdir /var/run/sshd && \
    echo 'root:Back2ThaR00t$' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Создаём пользователя для сервера Quake 3
RUN useradd -m -s /bin/bash quake3user && \
    echo 'quake3user:Q1w2e3r4!' | chpasswd && \
    usermod -aG sudo quake3user

# Копируем патч в нужную директорию
COPY ./setup/Docs/LinuxFAQ/udp_wide_broadcast.patch /home/quake3user/setup/Docs/LinuxFAQ/

# Копируем папку setup и (при необходимости) скрипт expect
COPY setup /home/quake3user/setup

# Если вы больше не используете expect, можно убрать следующую строку
COPY install_quake3.exp /home/quake3user/install_quake3.exp

# Устанавливаем права на скрипт установки

WORKDIR /home/quake3user/setup
RUN chmod +x ./setup.data/bin/Linux/x86/setup

RUN chmod +x /home/quake3user/install_quake3.exp && /home/quake3user/install_quake3.exp
#RUN yes "" | ./setup.data/bin/Linux/x86/setup -n -v 1 -i /usr/local/games/quake3 -o \"Dedicated server\"

# Даем необходимые права на директорию установки
RUN chmod -R 777 /usr/local/games/quake3

# Копируем директорию baseq3 из хоста в контейнер
COPY baseq3 /usr/local/games/quake3/baseq3

# Создаём файл конфигурации сервера Quake 3
RUN echo "// Basic Quake III Server Configuration\n\
seta sv_hostname \"Docker Quake 3 Server\"\n\
seta net_port \"27960\"\n\
seta sv_maxclients \"16\"\n\
seta sv_mapRotation \"q3dm17 q3dm6 q3dm8\"\n\
seta g_gametype \"0\"\n\
seta g_needpass \"0\"\n\
seta log \"1\"\n\
seta logfile \"server.log\"\n\
seta sv_maxRate \"25000\"\n\
seta sv_minRate \"8000\"\n\
seta sv_fps \"66\"\n\
seta sv_timeout \"200\"" > /usr/local/games/quake3/server.cfg

# Переключаемся на пользователя quake3user для работы с сервером
USER quake3user

WORKDIR /usr/local/games/quake3

# Экспонируем порты SSH и Quake 3
EXPOSE 22 27960/udp

# Указываем Volume для сохранения данных сервера
VOLUME ["/usr/local/games/quake3"]

# Запуск SSH и сервера Quake 3
CMD ["bash", "-c", "service ssh start && ./q3ded +exec server.cfg"]
