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


WORKDIR		/usr/share/jenkins/ref

USER        root

# adjust time to our time zone
RUN         rm /etc/timezone                                            &&\
            rm /etc/localtime                                           &&\
            ln -s /usr/share/zoneinfo/America/Montreal /etc/localtime   &&\
            /bin/bash -c 'echo -e "LANG=\"C\"\nLC_CTYPE=\"C\"\nLC_TIME=\"C\"" >> /etc/environment'

# install default plugins
COPY        app/jenkins-jcasc-plugins.txt plugins.txt
RUN         jenkins-plugin-cli -f plugins.txt

# copy JCasC configuration file(s)
COPY       app/jcasc-config  ./jcasc-config

# copy sample pipeline job(s) and groovy startup scripts
COPY        app/jobs                        ./jobs
COPY        app/bash-config/.bashrc         ./.bashrc
COPY        app/bash-config/.bash_aliases   ./.bash_aliases
COPY        app/groovy/*.groovy             ./init.groovy.d/
COPY        app/downloads                   ./downloads

# install useful apps and infrastructure for smee-client and smee-client
#RUN         apt-get update                                          &&\
#            apt-get install -y apt-utils                            &&\
#            apt-get install -y vim less                             &&\
#            curl -sL https://deb.nodesource.com/setup_10.x | bash - &&\
#            apt-get install -y nodejs                               &&\
#            nodejs -v                                               &&\
#            npm -v                                                  &&\
#            npm install --global smee-client                        &&\
#            smee -v


# Jenkins jetty server listens on this port. Allow outside connections
EXPOSE      8080


ENV         JAVA_OPTS                                          \
            -Djenkins.install.runSetupWizard=false             \
#            -Djava.util.logging.SimpleFormatter.format="[%1$Tf] %4$s: %2$s - %5$s %6$s%n" \
            -Dcasc.jenkins.config=/var/jenkins_home/jcasc-config/jenkins-azure-2.0.yaml

WORKDIR     /var/jenkins_home
USER        jenkins
ENTRYPOINT  ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

