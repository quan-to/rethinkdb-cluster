FROM rethinkdb:2.3.6
MAINTAINER Lucas Teske <lucas@contaquanto.com.br>

RUN apt update && apt install -y curl

COPY main.sh /main/sh
COPY proxy.sh /proxy.sh

RUN /main.sh
