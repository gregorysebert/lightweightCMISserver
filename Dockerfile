FROM exoplatform/ci:jdk8-maven33 AS build

COPY . .
#Skip test that are failing only in docker hub
RUN mvn clean package -Dmaven.test.skip=true


FROM java:openjdk-8-jre-alpine
MAINTAINER eXo Platform "<docker@exoplatform.com>"
Label original_author="JLL lelan-j@mgdis.fr"

# TOMCAT 
# Expose web port
EXPOSE 8080

# Tomcat Version
ENV TOMCAT_VERSION_MAJOR 7
ENV TOMCAT_VERSION_FULL  7.0.92

# Download and install
RUN set -x \
  && apk add --no-cache su-exec \
  && apk add --update curl \
  && addgroup tomcat && adduser -s /bin/bash -D -G tomcat tomcat \
  && mkdir /opt \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.sha512 \
  && sha512sum -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.sha512 \
  && gunzip -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz | tar -xf - -C /opt \
  && rm -f apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.md5 \
  && ln -s /opt/apache-tomcat-${TOMCAT_VERSION_FULL} /opt/tomcat \
  && rm -rf /opt/tomcat/webapps/examples /opt/tomcat/webapps/docs /opt/tomcat/webapps/manager /opt/tomcat/webapps/host-manager \
  && apk del curl \
  && rm -rf /var/cache/apk/*

# Configuration
ADD tomcat-users.xml /opt/tomcat/conf/

# Set environment
ENV TOMCAT_BASE /opt/tomcat
ENV CATALINA_HOME /opt/tomcat

# lightweightcmis 

ENV VERSION 0.13.0-SNAPSHOT
#ENV VERSION 0.12.12-SNAPSHOT

RUN set -x \
    && mkdir -p /data/cmis \
    && mkdir -p /data/log

#ADD target/*.war /tmp/lightweightcmis-${VERSION}.war
COPY --from=build /srv/ciagent/workspace/target/*.war /tmp/lightweightcmis-${VERSION}.war

RUN set -x \
	&& mkdir ${TOMCAT_BASE}/webapps/cmis \
        && cd ${TOMCAT_BASE}/webapps/cmis \
        && unzip -qq /tmp/lightweightcmis-${VERSION}.war -d . \
        && chown -R tomcat:tomcat "$TOMCAT_BASE" \
        && chown -R tomcat:tomcat /data \
        && rm -fr /tmp/lightweightcmis-${VERSION}.war

# Launch Tomcat on startup

COPY docker-entrypoint.sh /

RUN chmod 755 /docker-entrypoint.sh

VOLUME /data

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["catalina","run"]
