FROM jruby:9.3-jdk11
LABEL application="ArchivesSpace EAD Checker"

# Change these
ENV APP_ID_NUMBER=55027
ENV APP_ID_NAME=archeck

ENV GROUP_ID_NUMBER=1636
ENV GROUP_ID_NAME=appcommon

RUN apt-get update && apt-get install -y gcc netbase && \
  groupadd --gid ${GROUP_ID_NUMBER} ${GROUP_ID_NAME} && \
  useradd -u ${APP_ID_NUMBER} --gid ${GROUP_ID_NUMBER} -m -d /home/${APP_ID_NAME} ${APP_ID_NAME}

WORKDIR /home/${APP_ID_NAME}

# Copy code into the image
COPY --chown=${APP_ID_NAME}:${GROUP_ID_NAME} . /home/${APP_ID_NAME}
RUN chown -R ${APP_ID_NAME}:${GROUP_ID_NAME} /home/${APP_ID_NAME}

USER ${APP_ID_NAME}
ENV PATH=/usr/local/bundle/bin:/opt/jruby/bin:/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV RACK_ENV=development
RUN ["bundle"]
ENV JRUBY_OPTS='-J-Djavax.net.ssl.trustStore=NONE -J-Xmx1g'
RUN ["bundle", "exec", "rake", "assets:precompile"]
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:9292"]
