FROM alpine:3.8 as builder
RUN apk --no-cache add alpine-sdk coreutils cmake \
  && adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && mkdir /packages \
  && chown builder:abuild /packages
RUN apk add --no-cache xz autoconf libjpeg-turbo-dev cairo-dev libxml2-dev \
                       fontconfig-dev lcms2-dev gobject-introspection-dev \
                       openjpeg openjpeg-dev openjpeg-tools \
                       "gtk+3.0" "gtk+3.0-dev" \
                       curl
RUN mkdir -p /home/builder/package/src &&\
    cd /home/builder/package/src &&\
    curl https://poppler.freedesktop.org/poppler-0.71.0.tar.xz | xz --uncompress | tar x

# poppler looks for openjpeg.h in /usr/lib/include/openjpeg-2.3
# use CXXFLAGS to point to the right location

RUN mkdir -p /home/builder/package/src/poppler-0.71.0/build &&\
    cd /home/builder/package/src/poppler-0.71.0/build && \
    CXXFLAGS=-isystem\ /usr/include/openjpeg-2.3 cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
RUN cd /home/builder/package/src/poppler-0.71.0/build && \
    make install

FROM alpine:latest
COPY --from=builder /usr/local /usr/local
RUN apk --no-cache add ca-certificates libjpeg-turbo cairo libxml2 \
                       fontconfig lcms2 openjpeg tiff \
                       libstdc++ && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup -h /work && \
    echo "/usr/local/lib64:/lib:/usr/local/lib:/usr/lib" > /etc/ld-musl-x86_64.path

USER appuser

WORKDIR /work
ENTRYPOINT ["ash"]
