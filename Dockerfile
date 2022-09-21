FROM jruby:9.3-jdk11
LABEL application="ArchivesSpace EAD Checker"

# Change these
ENV APP_ID_NUMBER=193
ENV APP_ID_NAME=mpsadm

ENV GROUP_ID_NUMBER=199
ENV GROUP_ID_NAME=appadmin
ENV JRUBY_OPTS=-J-Djavax.net.ssl.trustStore=NONE

RUN apt-get update && apt-get install -y gcc openssl && \
  mkdir -p /etc/nginx/ssl/ && \
  openssl req \
            -x509 \
            -subj "/C=US/ST=Massachusetts/L=Cambridge/O=Dis" \
            -nodes \
            -days 365 \
            -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/nginx.pem \
            -out /etc/nginx/ssl/nginx.pem && \
  chmod -R 755 /etc/nginx/ssl/ && \
  groupadd --gid ${GROUP_ID_NUMBER} ${GROUP_ID_NAME} && \
  useradd -u ${APP_ID_NUMBER} --gid ${GROUP_ID_NUMBER} -m -d /home/${APP_ID_NAME} ${APP_ID_NAME} && \
  chown ${APP_ID_NAME}:${GROUP_ID_NAME} /etc/nginx/ssl/nginx.pem && \
  openssl pkcs12 -export -password 'pass:changeit' -in /etc/nginx/ssl/nginx.pem -out /etc/nginx/ssl/combined-PKCS-12.p12 && \
  keytool -v -importkeystore -srckeystore  /etc/nginx/ssl/combined-PKCS-12.p12 -srcstoretype PKCS12 -destkeystore /opt/java/openjdk/lib/security/cacerts -deststoretype JKS -deststorepass changeit -srcstorepass 'changeit'


WORKDIR /home/${APP_ID_NAME}

# Copy code into the image
COPY --chown=${APP_ID_NAME}:${GROUP_ID_NAME} . /home/${APP_ID_NAME}
RUN chown -R ${APP_ID_NAME}:${GROUP_ID_NAME} /home/${APP_ID_NAME}

USER ${APP_ID_NAME}
ENV PATH=/usr/local/bundle/bin:/opt/jruby/bin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /opt/jruby/bin/bundle
CMD ["bundle", "exec", "puma", "-b", "ssl://0.0.0.0:9292?keystore=/opt/java/openjdk/lib/security/cacerts&keystore-pass=changeit&no_tlsv1=true"]
