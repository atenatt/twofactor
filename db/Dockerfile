FROM postgres:latest

ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=admin_password
ENV POSTGRES_DB=auth_db

# Copia o script e o arquivo YAML para o contêiner
COPY users.yaml /docker-entrypoint-initdb.d/users.yaml
COPY init_users.sh /docker-entrypoint-initdb.d/init_users.sh
COPY custom-entrypoint.sh /bin/custom-entrypoint.sh
RUN chmod +x /bin/custom-entrypoint.sh

CMD ["/bin/custom-entrypoint.sh"]