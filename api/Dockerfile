FROM alpine:latest
RUN apk add --no-cache bash dialog postgresql-client
COPY generate_code.sh /usr/local/bin/generate_code.sh
RUN chmod +x /usr/local/bin/generate_code.sh
ENTRYPOINT ["bash", "/usr/local/bin/generate_code.sh"]