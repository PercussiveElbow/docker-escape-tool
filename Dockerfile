FROM crystallang/crystal:nightly-alpine-build AS builder
RUN apk update && apk upgrade && apk --no-cache add ca-certificates
COPY ./ /app
WORKDIR /app
RUN shards install --ignore-crystal-version
#RUN crystal build --static --release -Dpreview_mt --error-trace /app/src/docker-escape.cr alpine static+mt broken
RUN crystal build --static --error-trace /app/src/docker-escape.cr
FROM ubuntu:latest
WORKDIR  /escape
COPY --from=builder  /app/docker-escape /escape/docker-escape
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
RUN useradd -ms /bin/bash notroot
RUN ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem
RUN chown -R notroot:notroot /escape
USER notroot
ENTRYPOINT ./docker-escape auto 
