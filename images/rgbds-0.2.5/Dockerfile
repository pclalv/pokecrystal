FROM ubuntu

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	gcc \
	bison \
	libpng-dev \
	make \
	pkg-config \
	python \
	wget

RUN mkdir ./rgbds \
	&& wget -q -O - https://github.com/rednex/rgbds/releases/download/v0.2.5/rgbds-0.2.5.tar.gz \
	| tar -C ./rgbds -zxvf - \
	&& cd ./rgbds \
	&& make install \
	&& rm -rf ./rgbds
