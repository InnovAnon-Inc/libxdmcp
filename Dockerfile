FROM innovanon/xorg-base:latest as builder-01
COPY --from=innovanon/util-macros /tmp/util-macros.txz /tmp/
COPY --from=innovanon/xorgproto   /tmp/xorgproto.txz   /tmp/
COPY --from=innovanon/libxau      /tmp/libXau.txz      /tmp/
RUN cat   /tmp/*.txz  \
  | tar Jxf - -i -C / \
 && rm -v /tmp/*.txz  \
 && ldconfig

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
 && tar acf        ../libXdmcp.txz .                                                     \
 && cd ..                                                                                \
 && rm -rf       /tmp/libXdmcp

