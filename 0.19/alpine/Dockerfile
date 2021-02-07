####################################
#  Feathercoin v0.19.1 - alpine
#  Dockerhub - https://hub.docker.com/r/feathercoin/feathercoin
#  HomePage  - https://www.feathercoin.com
####################################

# Build stage for BerkeleyDB
FROM alpine as berkeleydb

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add libressl

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j4
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for feathercoin Core
FROM alpine as feathercoin-core

COPY --from=berkeleydb /opt /opt

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add boost-dev
RUN apk --no-cache add build-base
RUN apk --no-cache add chrpath
RUN apk --no-cache add file
RUN apk --no-cache add gnupg
RUN apk --no-cache add libevent-dev
RUN apk --no-cache add libressl
RUN apk --no-cache add libressl-dev
RUN apk --no-cache add libtool
RUN apk --no-cache add linux-headers
RUN apk --no-cache add zeromq-dev

# 21E09A54A3615F99 Bushstar GPG
RUN set -ex \
  && for key in \
    21E09A54A3615F99 \
  ; do \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
    gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV feathercoin_VERSION=0.19.1
ENV feathercoin_PREFIX=/opt/feathercoin-${feathercoin_VERSION}


RUN wget https://github.com/FeatherCoin/Feathercoin/releases/download/v${feathercoin_VERSION}/SHA256SUMS.asc
RUN wget https://github.com/FeatherCoin/Feathercoin/archive/v${feathercoin_VERSION}.tar.gz -O feathercoin-${feathercoin_VERSION}.tar.gz
RUN gpg --verify SHA256SUMS.asc
#RUN grep " feathercoin-${feathercoin_VERSION}.tar.gz\$" SHA256SUMS.asc | sha256sum -c -
RUN tar -xzf feathercoin-${feathercoin_VERSION}.tar.gz

WORKDIR /Feathercoin-${feathercoin_VERSION}

RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
RUN ./autogen.sh
RUN ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
    --prefix=${feathercoin_PREFIX} \
    --mandir=/usr/share/man \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon
RUN make -j4
RUN make install
RUN strip ${feathercoin_PREFIX}/bin/feathercoin-cli
RUN strip ${feathercoin_PREFIX}/bin/feathercoin-tx
RUN strip ${feathercoin_PREFIX}/bin/feathercoind
RUN strip ${feathercoin_PREFIX}/lib/libbitcoinconsensus.a
RUN strip ${feathercoin_PREFIX}/lib/libbitcoinconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM alpine

LABEL maintainer="acidD github.com/aciddude"

RUN adduser -S feathercoin
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add \
  boost-chrono \
  boost-filesystem \
  boost-system \
  boost-thread \
  libevent \
  libressl \
  libzmq \
  su-exec

ENV feathercoin_DATA=/home/feathercoin/.feathercoin
ENV feathercoin_VERSION=0.19.1
ENV feathercoin_PREFIX=/opt/feathercoin-${feathercoin_VERSION}
ENV PATH=${feathercoin_PREFIX}/bin:$PATH

COPY --from=feathercoin-core /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/feathercoin/.feathercoin"]

EXPOSE 9336 9337 19336 19337 19444

ENTRYPOINT ["/entrypoint.sh"]

RUN feathercoind -version | grep "Feathercoin Core version v${feathercoin_VERSION}"

CMD ["feathercoind"]