ARG         JENKINS_VER=2.249.3
FROM        jenkins/jenkins:${JENKINS_VER}-lts AS default

WORKDIR		/usr/share/jenkins/ref
USER        root

# adjust time to our time zone
RUN         rm /etc/timezone                                            &&\
            echo "America/Toronto" > /etc/timezone                     &&\
            rm /etc/localtime                                           &&\
            ln -s /usr/share/zoneinfo/America/Toronto /etc/localtime   &&\
            /bin/bash -c 'echo -e "LANG=\"C\"\nLC_CTYPE=\"C\"\nLC_TIME=\"C\"" >> /etc/environment'

# install default plugins
COPY        app/jenkins-jcasc-plugins.txt plugins.txt
RUN         jenkins-plugin-cli -f plugins.txt

# download tools
RUN         mkdir -p downloads                                                                      &&\
            cd downloads                                                                            &&\
            curl -s -L -O \
            https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz &&\
            curl -s -L -O \
            https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz       &&\
            cd ..       

ARG         DEBIAN_FRONTEND=noninteractive
            
# download and install missing apps and infrastructure for smee-client and smee-client
RUN         apt-get update                                              &&\
            apt-get install -q -y vim less                              &&\
            curl -s -L https://deb.nodesource.com/setup_10.x | bash -   &&\
            apt-get install -q -y nodejs                                &&\
            nodejs -v                                                   &&\
            npm -v                                                      &&\
            npm install --global smee-client                            &&\
            smee -v

#############################################################################
# configure + start Jenkins image
FROM        default AS jcasc-jenkins

# build info
LABEL       maintainer="tom p."
ARG         BUILD_VER=jcasc-0.1
ARG         BUILDPLATFORM
ENV         BUILD_VERSION=${BUILD_VER}
ENV         BUILD_PLATFORM=$BUILDPLATFORM

# java + jenkins options
ENV         JAVA_OPTS="-Duser.timezone=America/Toronto \
            -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Toronto \
            -Djenkins.install.runSetupWizard=false \
            -Dcasc.jenkins.config=/var/jenkins_home/jcasc-config/jenkins-azure-2.0.yaml"
#            -Djava.util.logging.config.file=/var/jenkins_home/logging.properties"
ENV         JENKINS_OPTS --sessionTimeout=360
ENV         JENKINS_JAVA_OPTIONS="-Duser.timezone=America/Toronto \
            -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Toronto"

# copy JCasC configuration file(s)
COPY       app/jcasc-config  ./jcasc-config

# copy sample pipeline job(s) and groovy startup scripts
COPY        app/jobs                        ./jobs
COPY        app/logging.properties          ./logging.properties
COPY        app/bash-config/.bashrc         ./.bashrc
COPY        app/bash-config/.bash_aliases   ./.bash_aliases
COPY        app/groovy/*.groovy             ./init.groovy.d/

# Jenkins jetty server listens on this port. Allow outside connections
EXPOSE      8080

WORKDIR     /var/jenkins_home
USER        jenkins
ENTRYPOINT  ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

