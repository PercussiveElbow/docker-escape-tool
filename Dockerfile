FROM crystallang/crystal
COPY ./ /breakout
WORKDIR /breakout
ENTRYPOINT crystal run src/docker-escape.cr -- escape
