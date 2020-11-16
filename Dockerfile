ARG         JENKINS_VER=2.249.3
FROM        jenkins/jenkins:${JENKINS_VER}-lts AS default

# build info
LABEL       maintainer="tom p."
ARG         BUILD_VER=jcasc-0.1
ARG         BUILDPLATFORM
ENV         BUILD_VERSION=${BUILD_VER}
ENV         BUILD_PLATFORM=$BUILDPLATFORM

# jenkins options
ENV         JAVA_OPTS="-Duser.timezone=America/Montreal"
ENV         JENKINS_OPTS --sessionTimeout=360

WORKDIR		/var/jenkins_home

USER        root
	
# install useful apps and infrastructure for smee-client and smee-client
RUN         apt-get update                                          &&\
            apt-get install -y apt-utils                            &&\
            apt-get install -y vim less                             &&\
            curl -sL https://deb.nodesource.com/setup_10.x | bash - &&\
            apt-get install -y nodejs                               &&\
            nodejs -v                                               &&\
            npm -v                                                  &&\
            npm install --global smee-client                        &&\
            smee -v

# allow this port number to connect to Jenkins in this container
EXPOSE      8081

USER        jenkins
ENTRYPOINT  ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

