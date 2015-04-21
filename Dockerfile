FROM		debian:jessie
MAINTAINER	Julian Haupt <julian.haupt@hauptmedia.de>

ENV		DEBIAN_FRONTEND noninteractive
RUN		apt-get update -qq && \
		apt-get upgrade --yes && \
    		apt-get install -y --no-install-recommends curl ca-certificates && \ 
		apt-get clean autoclean && \
		apt-get autoremove --yes && \ 
		rm -rf /var/lib/{apt,dpkg,cache,log}/

ENV		GO_CRON_VERSION v0.0.7

RUN		curl -L https://github.com/odise/go-cron/releases/download/${GO_CRON_VERSION}/go-cron-linux.gz \
		| zcat > /usr/local/bin/go-cron \
		&& chmod u+x /usr/local/bin/go-cron

#18080 http status port
EXPOSE		18080

ADD		docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
ENTRYPOINT	["/usr/local/sbin/docker-entrypoint.sh"]

