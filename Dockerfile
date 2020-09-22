FROM crystallang/crystal
RUN useradd -ms /bin/bash notroot
COPY ./ /breakout
WORKDIR /breakout
RUN shards install
RUN chown -R notroot:notroot /breakout
USER notroot
RUN crystal build -Dpreview_mt --error-trace src/docker-escape.cr
ENTRYPOINT ./docker-escape auto 
