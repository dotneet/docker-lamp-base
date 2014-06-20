FROM centos
MAINTAINER dotneet<dotneet@gmail.com>

RUN rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

# Install Packages
RUN yum update -y
RUN yum install -y sudo passwd wget
RUN yum install -y git httpd nginx docker-io vim-enhanced bash-completion unzip
RUN yum install -y openssh-server openssh-clients java-1.7.0-openjdk-devel
RUN yum install -y --enablerepo=remi mysql mysql-server
RUN yum install -y --enablerepo=remi php php-cli php-pdo php-mbstring php-mcrypt php-mysql php-xml

# SSH Setting
RUN /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
RUN /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash -g docker docker
RUN passwd -u -f docker
RUN mkdir -p /home/docker/.ssh && chmod 700 /home/docker/.ssh
ADD ./authorized_keys /home/docker/.ssh/authorized_keys
RUN chmod 600 /home/docker/.ssh/authorized_keys
RUN chown -R docker /home/docker

RUN echo "docker  ALL=(ALL)  ALL" >> /etc/sudoers.d/docker
RUN chmod 600 /etc/sudoers.d/docker

# Supervisor Setting
RUN yum install -y python-setuptools
RUN easy_install pip
RUN pip install supervisor
RUN mkdir /var/log/supervisor
ADD ./etc/supervisord.conf /etc/

# Other Setting
ADD vimrc /home/docker/.vimrc

EXPOSE 22 80 443 8080

CMD ["supervisord","-n"]

