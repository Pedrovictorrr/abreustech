#FROM php:7.4.0-apache - este funciona perfeitamente, sem fpm.
FROM php:8.1.0-apache
RUN apt-get update && apt-get install -y \
    git \
    wget \
    vim \
    wget \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    cron \
    ghostscript \
    zlib1g-dev \
    libzip-dev

#esta biblioteca é específica do CDC digital dependencia ext pdf.
RUN docker-php-ext-install gd zip pdo pdo_mysql

# forçar o time zone no container para São Paulo, dados que são salvos no banco de dados.
ENV TZ="America/Sao_Paulo"

# muito importante, aumentar a memória do php que roda dentro do container. add em 31/10/2022.
ENV PHP_MEMORY_LIMIT=2000M

# limpa arquivos cache apt-get

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#este arquivo é da primeira configuração que fizemos se você quiser rodar a aplicação sem SSL.

COPY .arq/vhost.conf /etc/apache2/sites-available/000-default.conf

COPY .arq/apache2.conf /etc/apache2/apache2.conf
#o ambiente beta roda na porta 81 do cluster, por isso também é preciso alterar a porta do apache, por isso copiar esse arquivo


#COPY .docker/certs/alpha-api.novakio.tech.conf /etc/apache2/sites-available/000-default.conf
#COPY .docker/certs/alpha-api.novakio.tech-le-ssl.conf /etc/apache2/sites-available/alpha-api.novakio.tech-le-ssl.conf

#COPY .docker/certs/options-ssl-apache.conf /etc/letsencrypt/options-ssl-apache.conf


#RUN a2ensite alpha-api.novakio.tech.conf



#COPY .docker/certs/fullchain.pem /etc/letsencrypt/live/alpha-api.novakio.tech/fullchain.pem
#COPY .docker/certs/privkey.pem /etc/letsencrypt/live/alpha-api.novakio.tech/privkey.pem
#COPY .docker/certs/options-ssl-apache.conf /etc/letsencrypt/options-ssl-apache.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install pdo_mysql mbstring
WORKDIR /app
COPY . /app
COPY .arq/storage/framework /app/storage/framework
#RUN mkdir /app/storage/framework/views
RUN chmod -R 775 /app/storage
COPY .env.example .env
RUN cd /app/storage/framework && ls
COPY .arq/health.html /app/health.html
COPY .arq/health.html /app/public/health.html
COPY composer.json .

RUN composer update
RUN composer dump-autoload
RUN composer install
RUN php artisan config:cache

RUN a2enmod headers
RUN mkdir /var/www/app
RUN mkdir /var/www/app/public
COPY .arq/ports.conf /etc/apache2/ports.conf
COPY .arq/local.ini /usr/local/etc/php/conf.d/local.ini
RUN chown -R www-data:www-data /app && a2enmod rewrite

COPY .arq/laravel-cron /etc/cron.d/laravel-cron

RUN chmod 0644 /etc/cron.d/laravel-cron
RUN touch /var/log/cron.log
RUN crontab /etc/cron.d/laravel-cron

# VALIDAR SE AS CRONS ESTAO RODANDO #

#CMD printenv > /etc/environment && echo “cron starting…” && (cron) && : > /var/log/cron.log && tail -f /var/log/cron.log


#RUN rm -rf /public/storage
RUN mkdir -p storage/app/public/files
RUN mkdir -p storage/app/public/signed-file
RUN mkdir -p storage/app/public/video
RUN chown -R www-data:www-data storage && chmod -R 755 storage
RUN php artisan vendor:publish --tag="cors"
RUN php artisan key:generate
RUN php artisan migrate
#RUN php artisan passport:install
RUN php artisan storage:link
RUN php artisan up
RUN php artisan route:clear
RUN php artisan cache:clear
RUN chmod -R 775 /app
RUN chown -R www-data:www-data /app && a2enmod rewrite

 RUN chmod 0644 /etc/cron.d/laravel-cron
RUN touch /var/log/cron.log
 RUN crontab /etc/cron.d/laravel-cron
RUN php artisan schedule:run


#ENTRYPOINT PARA RODAR AS CRONS
COPY entrypoint.sh /opt/bin/entrypoint.sh
COPY entrypoint-apache.sh /opt/bin/entrypoint-apache.sh
COPY entrypoint-cron.sh /opt/bin/entrypoint-cron.sh
RUN chmod +x /opt/bin/entrypoint.sh
RUN chmod +x /opt/bin/entrypoint-apache.sh
RUN chmod +x /opt/bin/entrypoint-cron.sh
#CMD php artisan serve --host=0.0.0.0 --port=80


EXPOSE 8005

CMD ["/opt/bin/entrypoint.sh"]


