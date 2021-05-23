FROM nextcloud:apache
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y supervisor libmagickcore-6.q16-6-extra
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*
RUN mkdir /var/log/supervisord /var/run/supervisord
COPY supervisord.conf /
# RUN sed -i "s/www-data:x:[0-9]*:/www-data:x:$PGID:/" /etc/group
# RUN sed -i "s/www-data:x:[0-9]*:[0-9]*:www-data:\/var\/www:\/usr\/sbin\/nologin/www-data:x:$PUID:$PUID:www-data:\/var\/www:\/usr\/sbin\/nologin/" passwd
COPY etc/* /etc/
ENV NEXTCLOUD_UPDATE=1
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]