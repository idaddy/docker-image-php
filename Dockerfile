#
# iDaddy php Image
# Author: zoukunmin
#

FROM centos:7
MAINTAINER Dennis Zou <denniszou@gmail.com>

RUN yum -y install epel-release  \
    && yum -y update \
    && yum -y install supervisor php-fpm php-mcrypt libxml2-devel libcurl-devel git \
        php-pecl-solr2 php-pecl-redis php-mysql php-pdo php-bcmath php-gd php-mbstring \
        php-tidy php-pecl-memcache php-pecl-imagick php-pecl-gearman gcc php-devel re2c pcre-devel yasm \
    && yum -y clean all

# Phalcon patch zend_API.h
# COPY ./zend_API.h /usr/include/php/Zend/

RUN cd /root \
    && git clone --depth=1 https://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build \
    && ./install \
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

RUN cd /root \
    && git clone --depth=1 https://github.com/tony2001/ffmpeg-php.git \
    && cd ffmpeg-php \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && cd /root \
    && rm -rf ffmpeg_php

RUN ln -sf /w/dev-conf/dev-php/php-fpm.conf /etc/php-fpm.conf \
    && rm -rf /etc/php-fpm.d \
    && ln -sf /w/dev-conf/dev-php/php-fpm.d /etc/php-fpm.d \
    && ln -sf /w/dev-conf/dev-php/php.ini /etc/php.ini \
    && rm -rf /etc/php.d \
    && ln -sf /w/dev-conf/dev-php/php.d /etc/php.d

EXPOSE 9000

CMD ["supervisord", "-c", "/w/dev-conf/dev-php/supervisord.conf"]
