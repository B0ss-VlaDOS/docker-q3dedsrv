# Используем официальный 64-битный образ Ubuntu 24.04 LTS (или 22.04 LTS, если проблемы сохраняются)
FROM ubuntu:24.04

# Устанавливаем переменную окружения для предотвращения интерактивных запросов
ENV DEBIAN_FRONTEND=noninteractive

# Обновляем списки пакетов, устанавливаем основные инструменты и включаем необходимые репозитории
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    add-apt-repository multiverse && \
    dpkg --add-architecture i386

RUN apt-get update

RUN apt-get install -y sudo && \
    apt-get install -y net-tools && \
    apt-get install -y wget && \
    apt-get install -y curl && \
    apt-get install -y lib32gcc-s1 && \
    apt-get install -y libstdc++6:i386 && \
    apt-get install -y libc6:i386 && \
    apt-get install -y zlib1g:i386 && \
    apt-get install -y libncurses6:i386 && \
    apt-get install -y libsdl1.2debian:i386 && \
    apt-get install -y expect

# Очистка кэша apt после всех установок
RUN rm -rf /var/lib/apt/lists/*

# Создаём пользователя для сервера Quake 3
RUN useradd -m -s /bin/bash quake3user && \
    echo 'quake3user:Q1w2e3r4!' | chpasswd && \
    usermod -aG sudo quake3user

COPY setup /home/quake3user/setup
COPY install_quake3.exp /home/quake3user/install_quake3.exp

WORKDIR /home/quake3user/setup

RUN chmod +x ./setup.data/bin/Linux/x86/setup && chmod +x /home/quake3user/install_quake3.exp && /home/quake3user/install_quake3.exp && chmod -R 777 /usr/local/games/quake3

COPY baseq3 /usr/local/games/quake3/baseq3
COPY entrypoint.sh /usr/local/games/quake3/entrypoint.sh

RUN chmod -R 777 /usr/local/games/quake3 && chmod +x /usr/local/games/quake3/entrypoint.sh

# Переключаемся на пользователя quake3user для работы с сервером
USER quake3user

WORKDIR /usr/local/games/quake3

# Указываем Volume для сохранения данных сервера
VOLUME ["/usr/local/games/quake3"]

ENTRYPOINT ["/usr/local/games/quake3/entrypoint.sh"]
