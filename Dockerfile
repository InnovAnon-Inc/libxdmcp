FROM innovanon/xorg-base:latest as builder-01
USER root
COPY --from=innovanon/util-macros /tmp/util-macros.txz /tmp/
COPY --from=innovanon/xorgproto   /tmp/xorgproto.txz   /tmp/
COPY --from=innovanon/libxau      /tmp/libXau.txz      /tmp/
RUN extract.sh

ARG LFS=/mnt/lfs
WORKDIR $LFS/sources
USER lfs
RUN sleep 31                                                                             \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXdmcp.git \
 && cd                                                                      libXdmcp     \
 && ./autogen.sh                                                                         \
 && ./configure $XORG_CONFIG                                                             \
 && make                                                                                 \
 && make DESTDIR=/tmp/libXdmcp install                                                   \
 && rm -rf                                                                  libXdmcp     \
 && cd           /tmp/libXdmcp                                                           \
 && strip.sh .                                                                           \
 && tar  pacf        ../libXdmcp.txz .                                                     \
 && cd ..                                                                                \
 && rm -rf       /tmp/libXdmcp

FROM scratch as final
COPY --from=builder-01 /tmp/libXdmcp.txz /tmp/

