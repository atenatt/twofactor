FROM alpine:latest
RUN apk add --no-cache bash dialog
COPY login.sh /usr/local/bin/login.sh
RUN chmod +x /usr/local/bin/login.sh
ENTRYPOINT ["bash", "/usr/local/bin/login.sh"]