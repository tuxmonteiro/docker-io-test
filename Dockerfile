FROM centos:centos6

MAINTAINER Marcelo Teixeira Monteiro <marcelotmonteiro@gmail.com>

# command line goodies
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /etc/profile
RUN echo "export LANG=en_GB.utf8" >> /etc/profile
RUN echo "alias ll='ls -l --color=auto'" >> /etc/profile
RUN echo "alias grep='grep --color=auto'" >> /etc/profile

# add epel
RUN rpm --import https://fedoraproject.org/static/0608B895.txt
RUN rpm --import https://fedoraproject.org/static/217521F6.txt
RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

# add docker.io
RUN yum -y install docker-io

#
ADD http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo /etc/yum.repos.d/maven.repo
# telnet is required by some fabric command. without it you have silent failures
RUN yum install -y java-1.7.0-openjdk-devel which unzip openssh-server sudo openssh-clients apache-maven
# enable no pass and speed up authentication
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/;s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

# enabling sudo group
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
# enabling sudo over ssh
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

ENV JAVA_HOME /usr/lib/jvm/jre

# add a user, with sudo permissions
RUN useradd -m noroot; echo noroot: | chpasswd ; usermod -a -G wheel noroot

# assigning higher default ulimits
# unluckily this is not very portable. these values work only if the user running docker daemon on the host has his own limits >= than values set here
# if they are not, the risk is that the "su fuse" operation will fail
RUN echo "noroot                -       nproc           4096" >> /etc/security/limits.conf
RUN echo "noroot                -       nofile          4096" >> /etc/security/limits.conf

CMD service sshd start ; bash

# declaring exposed ports. helpful for non Linux hosts. add "-P" flag to your "docker run" command to automatically expose them and "docker ps" to discover them.
# SSH
EXPOSE 22 
