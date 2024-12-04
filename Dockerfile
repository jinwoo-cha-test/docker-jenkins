FROM registry.redhat.io/jboss-eap-7/eap74-openjdk8-openshift-rhel8
LABEL description="This is a custom jboss container image"
USER root

RUN mkdir -p /opt/eap/standalone/logs/gclog


ENV LogLevel="info" \
    LOG_HOME=/opt/eap/standalone/logs \
    GC_CONTAINER_OPTIONS="-XX:+UseG1GC" \
    JAVA_MAX_MEM_RATIO=70 \
    JAVA_INITIAL_MEM_RATIO=50 \
    JAVA_OPTS="             -Dfile.encoding=UTF-8 \
                            -XX:MetaspaceSize=512m \
                            -verbose:gc \
                            -Xloggc:/opt/eap/standalone/log/gc.log \
                            -XX:+PrintGCDetails \
                            -XX:+PrintGCDateStamps \
                            -XX:+UseGCLogFileRotation \
                            -XX:NumberOfGCLogFiles=5 \
                            -XX:GCLogFileSize=3M \
                            -XX:-TraceClassUnloading \
                            -XX:+PrintHeapAtGC \
                            -Xloggc:/opt/eap/standalone/logs/gclog/gc.log \
                            -XX:+DisableExplicitGC"


COPY simple.war /opt/eap/standalone/deployments/.
RUN mkdir -p files
COPY  files/* ./
RUN sed -i "2a\set PASSWORD=`echo "UnBsaW51eDEyMyQK" | base64 --decode`" ./db.cli
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=base.cli
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=db.cli
RUN rm -rf *.jar db.cli base.cli


#USER apache
#ENTRYPOINT ["/usr/sbin/httpd"]
#CMD ["-D", "FOREGROUND"]

