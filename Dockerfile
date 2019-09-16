FROM centos:latest
MAINTAINER xboarder56

RUN yum install -y epel-release && yum update -y && \
    yum install -y openssh-server openssh-clients net-tools \
    cyrus-sasl cyrus-sasl-plain cyrus-sasl-md5 mailx \
    perl supervisor postfix rsyslog \
    && rm -rf /var/cache/yum/* \
    && yum clean all

# Setup SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile
RUN /usr/bin/ssh-keygen -A

RUN sed -i -e "s/^nodaemon=false/nodaemon=true/" /etc/supervisord.conf
RUN sed -i -e 's/inet_interfaces = localhost/inet_interfaces = all/g' /etc/postfix/main.cf

COPY etc/*.conf /etc/
COPY etc/rsyslog.d/* /etc/rsyslog.d
COPY run.sh /
RUN chmod +x /run.sh
COPY etc/supervisord.d/*.ini /etc/supervisord.d/
RUN newaliases

EXPOSE 22 25

CMD ["/run.sh"]
