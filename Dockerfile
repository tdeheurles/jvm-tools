FROM        gliderlabs/alpine:latest
MAINTAINER  tdeheurles@gmail.com

RUN apk update
RUN apk upgrade
RUN apk-install sudo
RUN apk-install wget
RUN apk-install bash
RUN apk-install zsh


# JAVA
ENV JAVA_VERSION=8 \
    JAVA_UPDATE=60 \
    JAVA_BUILD=27 \
    JAVA_HOME=/usr/lib/jvm/default-jvm

# ACTIVATOR
ENV ACTIVATOR_VERSION=1.3.6

# MAVEN
ENV MAVEN3_VERSION=3.3.3

# Here we use several hacks collected from https://github.com/gliderlabs/docker-alpine/issues/11:
# 1. install GLibc (which is not the cleanest solution at all)
# 2. hotfix /etc/nsswitch.conf, which is apperently required by glibc and is not used in Alpine Linux

RUN apk add --update wget ca-certificates && \
    cd /tmp && \
    wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
         "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
    apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
    /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar xzf "jdk-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    mkdir -p /usr/lib/jvm && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ln -s "java-${JAVA_VERSION}-oracle" $JAVA_HOME && \
    ln -s $JAVA_HOME/bin/java /usr/bin/java && \
    ln -s $JAVA_HOME/bin/javac /usr/bin/javac && \
    rm -rf $JAVA_HOME/*src.zip && \
    apk del wget ca-certificates && \
    rm /tmp/* /var/cache/apk/*




# MAVEN
RUN wget "http://apache.mirrors.ovh.net/ftp.apache.org/dist/maven/maven-3/$MAVEN3_VERSION/binaries/apache-maven-$MAVEN3_VERSION-bin.tar.gz"
RUN tar -xvzC /tmp -f apache-maven-$MAVEN3_VERSION-bin.tar.gz
RUN mv /tmp/apache-maven-$MAVEN3_VERSION /maven
RUN rm apache-maven-$MAVEN3_VERSION-bin.tar.gz
RUN rm -rf /tmp/apache-maven-$MAVEN3_VERSION
ENV MAVEN_PATH /maven
ENV PATH /maven/bin:$PATH




# ACTIVATOR
RUN mkdir -p /tmp/activator
RUN wget "http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION-minimal.zip" \
    -O /tmp/activator/activator.zip
WORKDIR /tmp/activator
RUN unzip activator.zip
RUN cp -r $(unzip -l activator.zip | grep -o -E "[activator-]+[0-9.]*-minimal/$") /activator/
RUN rm -rf /tmp/activator
ENV PATH  /activator/:$PATH



WORKDIR /
