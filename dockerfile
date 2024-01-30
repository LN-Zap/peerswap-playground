FROM golang:1.21.4-bullseye as builder

ARG PEERSWAP_VERSION=master

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Copy in the local repository to build from.
RUN git clone --quiet --depth 1 --single-branch \
    --branch $PEERSWAP_VERSION \
    https://github.com/YusukeShimizu/peerswap /go/src/github.com/YusukeShimizu/peerswap

RUN cd /go/src/github.com/YusukeShimizu/peerswap \
    &&  make bins

FROM elementsproject/lightningd:v23.11.2-arm64v8

COPY --from=builder /go/src/github.com/YusukeShimizu/peerswap/out/peerswap /usr/local/libexec/c-lightning/plugins/
RUN chmod +x /usr/local/libexec/c-lightning/plugins/peerswap
RUN ls -la /

ENTRYPOINT  [ "./entrypoint.sh" ]