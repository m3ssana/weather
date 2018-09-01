FROM golang:alpine as builder
MAINTAINER Jessica Frazelle <jess@linux.com>

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go

RUN	apk add --no-cache \
	ca-certificates

COPY . /go/src/github.com/m3ssana/weather

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		git \
		gcc \
		libc-dev \
		libgcc \
		make \
	&& cd /go/src/github.com/m3ssana/weather \
	&& make static \
	&& mv weather /usr/bin/weather \
	&& apk del .build-deps \
	&& rm -rf /go \
	&& echo "Build complete."

FROM scratch

COPY --from=builder /usr/bin/weather /usr/bin/weather
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs

ENTRYPOINT [ "weather" ]
CMD [ "--help" ]
