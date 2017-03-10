FROM core/centos:7.3
MAINTAINER qujinping

LABEL \
      # Location of the STI scripts inside the image.
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      # DEPRECATED: This label will be kept here for backward compatibility.
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      # default mapping items of runtime-artifact`
      io.openshift.s2i.assemble-input-files=/opt/app-root/etc;/opt/app-root/data;/opt/app-root/bin;/opt/app-root/libs

ENV \
    # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    TERM=xterm-256color\
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root \
    APPROOT=/opt/app-root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/app-root/bin

COPY ./assemble-runtime /usr/libexec/s2i/ 

# install utils
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  INSTALL_PKGS="autoconf \
  deltarpm \
  unzip \
  net-tools \
  telnet \
  lsof \
  tcpdump \
  traceroute \
  bind-utils \
  openssh-server \
  openssh-clients \
  wget \
  which" && \
  mkdir -p ${HOME}/.pki/nssdb && \
  chown -R 1001:0 ${HOME}/.pki && \
  yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
  rpm -V $INSTALL_PKGS && \
  yum clean all -y && \
  useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
  mkdir -p /opt/app-root && \
  chown -R 1001:0 /opt/app-root


WORKDIR ${HOME}

USER 1001

# For systemd usage this changes to /usr/sbin/init
# Keeping it as /bin/bash for compatability with previous
CMD ["/bin/bash"]
