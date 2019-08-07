FROM tiredofit/nginx-php-fpm:7.3
LABEL maintainer="Dave Conroy (dave at tiredofit dot ca)"

### Set Defaults
ENV FREESCOUT_VERSION=1.3.4 \
    PHP_ENABLE_FILEINFO=TRUE \
    PHP_ENABLE_ICONV=TRUE \
    PHP_ENABLE_IMAP=TRUE \
    PHP_ENABLE_OPENSSL=TRUE \
    PHP_ENABLE_SIMPLEXML=TRUE \
    ZABBIX_HOSTNAME=freescout-app

ARG ICONV_VERSION=1.15

### Perform Installation
RUN set -x && \
    apk update && \
    apk upgrade && \
    \
    apk add -t .freescout-build-deps \
              build-base \
    && \
    \
    apk add -t .freescout-run-deps \
              expect \
              git \
              gnu-libiconv \
	      && \
    \
    
### Iconv Installation
#    mkdir -p /usr/src/iconv && \
#    curl -sSL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz | tar xvfz - --strip=1 -C /usr/src/iconv && \
#    cd /usr/src/iconv && \
#	./configure \
#		--build=$CBUILD \
#		--host=$CHOST \
#		--prefix=/usr \
#		--mandir=/usr/share/man \
#		--disable-nls \
#		--disable-static \
 #      && \
#	# work around rpath issue
#	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool && \
#	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool && \
#	make && \
 #      make install && \
    \
### WWW  Installation
    mkdir -p /www/logs && \
    mkdir -p /www/html && \
    mkdir -p /assets/install && \
    curl -sSL https://github.com/freescout-helpdesk/freescout/archive/${FREESCOUT_VERSION}.tar.gz | tar xvfz - --strip 1 -C /assets/install && \
    #git clone -b ${FREESCOUT_VERSION} https://github.com/freescout-helpdesk/freescout.git /assets/install && \
    cd /assets/install && \
    rm -rf \
        .env.example \
        .env.travis \
        .gitattributes \
        .gitcommit \
        .gitignore \
        && \
    \
    chown -R nginx:www-data /assets/install && \
    \
### Update CA Certs
    update-ca-certificates && \
    \
### Cleanup
    apk del .freescout-build-deps && \
    rm -rf /usr/src/* /var/tmp/* /var/cache/apk/*

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php7

### Assets
ADD install /
