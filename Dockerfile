FROM nextcloud:apache
ENV DEBIAN_FRONTEND=noninteractive
ENV NEXTCLOUD_UPDATE=1
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y supervisor libmagickcore-6.q16-6-extra ffmpeg ghostscript imagemagick libbz2-dev liblapack-dev libopenblas-dev libx11-dev git cmake
RUN mkdir /var/log/supervisord /var/run/supervisord
COPY supervisord.conf /
# RUN sed -i "s/www-data:x:[0-9]*:/www-data:x:$PGID:/" /etc/group
# RUN sed -i "s/www-data:x:[0-9]*:[0-9]*:www-data:\/var\/www:\/usr\/sbin\/nologin/www-data:x:$PUID:$PUID:www-data:\/var\/www:\/usr\/sbin\/nologin/" passwd
COPY etc/* /etc/
WORKDIR /
RUN git clone https://github.com/davisking/dlib.git
RUN mkdir -p dlib/dlib/build
WORKDIR /dlib/dlib/build
RUN cmake -DBUILD_SHARED_LIBS=ON ..
RUN make
RUN make install
RUN git clone https://github.com/goodspb/pdlib.git /usr/src/php/ext/pdlib
RUN docker-php-ext-install pdlib
RUN docker-php-ext-install bz2
ENV PHP_MEMORY_LIMIT 1024M
RUN echo '12 * * * * php /var/www/html/occ face:background_job' >> /var/spool/cron/crontabs/www-data
RUN echo '37 * * * * php /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data
RUN apt-get remove -y git cmake
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]