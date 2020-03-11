FROM ubuntu:bionic

ARG METAMOD=true
ARG SOURCEMOD=true
ARG PLUGINS=true
ARG STEAM_ID
ARG RCON_PASSWORD

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
    lib32stdc++6 \
    lib32gcc1 \
    ca-certificates \
    wget \
    unzip \
    vim \
    ranger \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash steam
USER steam

ENV HOME /home/$USER
ENV SERVER $HOME/hlserver

ADD ./scripts/update.txt $SERVER/update.txt
ADD ./scripts/update.sh $SERVER/update.sh
ADD ./scripts/entry.sh $SERVER/entry.sh
ADD ./cfg/autoexec.cfg $SERVER/csgo/csgo/cfg/autoexec.cfg
ADD ./cfg/server.cfg $SERVER/csgo/csgo/cfg/server.cfg
ADD ./scripts/install-metamod.sh $SERVER/install-metamod.sh
ADD ./scripts/install-sourcemod.sh $SERVER/install-sourcemod.sh
ADD ./scripts/install-plugins.sh $SERVER/install-plugins.sh
ADD ./scripts/sourcemod-admin.sh $SERVER/sourcemod-admin.sh

RUN wget -qO- http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C $SERVER -xvz && $SERVER/update.sh

RUN if [ "$METAMOD" = true ] ; then ./$SERVER/install-metamod.sh ; fi
RUN if [ "$METAMOD" = true ] && [ "$SOURCEMOD" = true ] ; then ./$SERVER/install-sourcemod.sh ; fi
RUN if [ "$METAMOD" = true ] && [ "$SOURCEMOD" = true ] && [ "$PLUGINS" = true ] ; then ./$SERVER/install-plugins.sh ; fi
RUN if [ "$METAMOD" = true ] && [ "$SOURCEMOD" = true ] && [ -n "$STEAM_ID" ] ; then ./$SERVER/sourcemod-admin.sh ; fi

ADD ./plugins/EnableDisable.smx $SERVER/csgo/csgo/addons/sourcemod/plugins/EnableDisable.smx

EXPOSE 27015/udp 27015/tcp

WORKDIR /home/$USER/hlserver
ENTRYPOINT ["./entry.sh"]
CMD ["-console" "-usercon" "+game_type" "0" "+game_mode" "1" "+mapgroup" "mg_active" "+map" "de_dust2" "-tickrate" "128"]