FROM alpine:latest as rsbuild

RUN apk update && \
    apk add cargo rust && \
    mkdir /doh-client && \
    cargo install --root /doh-client doh-client

FROM alpine:latest

ENV LISTEN_ADDR 0.0.0.0:53
ENV REMOTE_ADDR 1.1.1.1:443
ENV DOMAIN cloudflare-dns.com
ENV LOCATION_PATH dns-query

EXPOSE 53/tcp 53/udp

RUN apk update && apk add ca-certificates libgcc

COPY --from=rsbuild /doh-client/bin/doh-client /usr/local/bin/doh-client

CMD ["/bin/sh", "-c", "/usr/local/bin/doh-client -d $DOMAIN -l $LISTEN_ADDR -p $LOCATION_PATH -r $REMOTE_ADDR /etc/ssl/cert.pem"]
