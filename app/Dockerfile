FROM homeassistant/home-assistant:stable
RUN apk update && apk upgrade
RUN apk add --no-cache gomplate bash
COPY ./render-config.sh /
COPY config /config.tmpl
