# alpine conversion of the tika_fax image

FROM alpine:latest
MAINTAINER vandyck.pieter@gmail.com

ENV TIKA_VERSION 1.18
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

# a minimal jre8
RUN apk --no-cache add openjdk8-jre-base

# tesseract, languages and fonts
RUN apk --no-cache add \
        msttcorefonts-installer \
        ttf-freefont \
        ttf-liberation \
        tesseract-ocr \
        tesseract-ocr-data-deu \
        tesseract-ocr-data-fra \
        tesseract-ocr-data-nld \
    && update-ms-fonts \
    && fc-cache -f

# tika server
RUN apk --no-cache add curl gnupg \
    && curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
    && gpg --import /tmp/tika.asc \
    && curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-${TIKA_VERSION}.jar.asc \
    && NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
      | awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
      | sed -r -e 's/^"//; s/",$//; s/" "//') \
    && echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
    && curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tika-server-${TIKA_VERSION}.jar \
    && apk del curl gnupg apk-tools \
    && rm -rf /var/cache/apk/* \
    && rm -r /usr/share/man

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-${TIKA_VERSION}.jar -h 0.0.0.0
