#
# iDaddy php Image with php 5.3.29
# Author: zoukunmin
#

FROM centos:7
MAINTAINER Dennis Zou <denniszou@gmail.com>

RUN yum -y install epel-release  \
    && yum -y update \
# Install build tools
    && yum -y install supervisor crontabs make git gcc autoconf re3c yasm \
# install php depend libs
    && yum -y install bzip2 libcurl-devel pcre-devel readline-devel recode-devel sqlite-devel openssl-devel libxml2-devel  \
    && yum -y install gd-devel libgearman-devel ImageMagick-devel libmcrypt-devel mariadb-devel libtidy-devel libxslt-devel java-1.8.0-openjdk unzip \
    && yum -y clean all

#    && yum -y install php-fpm php-mcrypt php-pecl-solr2 php-pecl-redis php-mysql php-pdo php-bcmath php-mbstring composer \
#        php-tidy php-pecl-memcache php-pecl-imagick php-pecl-xdebug php-pecl-gearman php-devel re2c yasm \

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

RUN ln -s   /usr/lib64/mysql/libmysqlclient.so /usr/lib/libmysqlclient.so

ENV PHP_VERSION 5.3.29

# --enable-mysqlnd is included below because it's harder to compile after the fact the extensions are (since it's a plugin for several extensions, not an extension in itself)
RUN set -x \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
	&& mkdir -p /usr/src/php \
	&& tar -xof php.tar.bz2 -C /usr/src/php --strip-components=1 \
	&& rm php.tar.bz2* 

RUN cd /usr/src/php \
	&& ./configure \
        --enable-fpm --with-fpm-user=nobody --with-fpm-group=nobody \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--disable-cgi \
		--enable-mysqlnd \
		--with-bcmath=shared \
		--with-curl \
		--with-openssl \
		--with-pcre \
        --with-pdo_sqlite=shared \
		--with-readline \
		--with-recode \
        --with-sqlite3=shared \
		--with-zlib \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& make clean

COPY docker-php-ext-* /usr/local/bin/

RUN docker-php-ext-install bcmath dom gd fileinfo json mbstring mcrypt mysql mysqli pdo pdo_mysql pdo_sqlite phar posix \
    sysvmsg sysvsem sysvshm tidy wddx xmlreader xmlwriter xsl zip 
RUN pecl install gearman igbinary imagick memcache redis solr ZendOpcache channel://pecl.php.net/xhprof-0.9.4

RUN cd /root \
    && git clone --depth=1 https://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build/64bits \
    && phpize \
    && ./configure CFLAGS="-O2 -march=corei7 -mtune=corei7" \
    && make \
    && make install \
    && cd /root \
    && rm -rf cphalcon

RUN cd /root \
    && git clone --depth=1 https://github.com/FFmpeg/FFmpeg.git \
    && cd FFmpeg \
    && ./configure --enable-shared \
    && make \
    && make install \
    && cd /root \
    && rm -rf FFmpeg

# 5.3版php的xdebug需要收工编译
RUN cd /root \
    && curl -L -o xdebug-2.2.7.tar.gz https://github.com/xdebug/xdebug/archive/2.2.7.tar.gz \
    && tar xvzf xdebug-2.2.7.tar.gz \
    && cd xdebug-2.2.7 \
    && phpize \
    && ./configure --enable-xdebug \
    && make \
    && make install \
    && cd /root \
    && rm -rf xdebug*

RUN cd /root \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

COPY ./conf /etc/
COPY php-fpm.conf /usr/local/etc/

# 为适应apswww中的apscli程序建立的连接
RUN ln -sf /usr/local/etc/php/php.ini /etc/php_dev.ini \
    && ln -sf /usr/local/bin/php /usr/bin/php

VOLUME /var/spool/cron

EXPOSE 9000

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
