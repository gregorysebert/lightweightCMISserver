FROM java:openjdk-8-jre-alpine

# TOMCAT 
# Expose web port
EXPOSE 8080

# Tomcat Version
ENV TOMCAT_VERSION_MAJOR 7
ENV TOMCAT_VERSION_FULL  7.0.69

# Download and install
RUN set -x \
  && apk add --no-cache su-exec \
  && apk add --update curl \
  && addgroup tomcat && adduser -s /bin/bash -D -G tomcat tomcat \
  && mkdir /opt \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz \
  && curl -LO https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION_MAJOR}/v${TOMCAT_VERSION_FULL}/bin/apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.md5 \
  && md5sum -c apache-tomcat-${TOMCAT_VERSION_FULL}.tar.gz.md5 \
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

# OpenCMIS
ENV OPENCMIS_VERSION  1.1.0

RUN set -x \
	&& apk add --no-cache su-exec \
    && apk add --update curl \
    && cd /tmp \
    && curl -LO http://central.maven.org/maven2/org/apache/chemistry/opencmis/chemistry-opencmis-server-inmemory/1.1.0/chemistry-opencmis-server-inmemory-${OPENCMIS_VERSION}.war \
    && mkdir ${TOMCAT_BASE}/webapps/opencmis \
        && cd ${TOMCAT_BASE}/webapps/opencmis \
        && unzip -qq /tmp/chemistry-opencmis-server-inmemory-${OPENCMIS_VERSION}.war -d . \
        && chown -R tomcat:tomcat "$TOMCAT_BASE" \
        && rm -fr /tmp/chemistry-opencmis-server-inmemory-${OPENCMIS_VERSION}.war

# Launch Tomcat on startup

COPY docker-entrypoint.sh /

RUN chmod 755 /docker-entrypoint.sh

VOLUME /data

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["catalina","run"]
