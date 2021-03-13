FROM debian:stable-slim

RUN apt-get update \
	&& apt-get install -y tar php-cli php-curl \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

# Install latest version of Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& sudo mv composer.phar /usr/bin/composer \
	&& php -r "unlink('composer-setup.php');"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
