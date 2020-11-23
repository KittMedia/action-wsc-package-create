FROM debian:stable-slim

RUN apt-get update \
	&& apt-get install -y tar composer \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]