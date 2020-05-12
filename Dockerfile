FROM amazonlinux as builder
RUN yum install -y make sqlite-devel zlib-devel gcc-c++ tar gzip
ADD https://github.com/mapbox/tippecanoe/archive/1.35.0.tar.gz /tmp/src.tar.gz
WORKDIR /tmp
RUN tar xzvf src.tar.gz
WORKDIR tippecanoe-1.35.0
RUN make && make install
# RUN make test

FROM goreleaser/nfpm as packager
WORKDIR /packages
ADD nfpm.yaml .

COPY --from=builder /usr/local/bin/tippecanoe bin/
COPY --from=builder /usr/local/bin/tippecanoe-enumerate bin/
COPY --from=builder /usr/local/bin/tippecanoe-decode bin/
COPY --from=builder /usr/local/bin/tippecanoe-json-tool bin/
COPY --from=builder /usr/local/bin/tile-join bin/
COPY --from=builder /usr/local/share/man/man1/tippecanoe.1 man/

RUN /nfpm pkg -t tippecanoe-1.35.0.rpm
RUN /nfpm pkg -t tippecanoe-1.35.0.deb

FROM amazonlinux
COPY --from=packager /packages/tippecanoe-1.35.0.rpm /packages/
COPY --from=packager /packages/tippecanoe-1.35.0.deb /packages/
