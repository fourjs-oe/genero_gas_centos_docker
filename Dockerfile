FROM centos:7

ARG USER=genero
ARG GROUP=fourjs
ARG UID=500
ARG GID=2000

USER root
RUN yum -y update \
 && yum -y install httpd bzip2 binutils file sqlite 

# Debugging helpers - Add sudo, vim, network tools
# Uncomment to enabled
#RUN yum -y install \
#      sudo \
#      vim \
#      iproute \
# && echo "%sudo ALL=(ALL) ALL" > /etc/sudoers.d/sudo-for-all \
# && chmod 0440 /etc/sudoers.d/sudo-for-all \
# && groupadd sudo 

# Clean the installation files from RedHat/Centos package installer yum -> you will get a diet image  :)
RUN yum -y clean all \
 && rm -rf /var/cache/yum/*

# We will install the FGLGWS and GAS packages as this user genero and we give it a password "fourjs" (need to be changed)
ENV HOME="/home/${USER}"
RUN set -eufx \
 && groupadd -g "${GID}" "${GROUP}" \
 && useradd -d "${HOME}" -u "${UID}" -g "${GID}" -M -N -r -s /bin/bash "${USER}" \
 #&& usermod -a -G sudo ${USER} \
 && mkdir -p "${HOME}" \
 && chown "${USER}:${GROUP}" "${HOME}"

# password is fourjs for test
RUN usermod -p 'Q9QOvWdNkbOC.' ${USER}

# we chaged the working directory in the image - everything that we import in the image will be in this directory if the full path is not specified.
WORKDIR ${HOME}

##### FGLGWS Installation #####################################################
# Dependencies: .run package to install
ARG FGLGWS_PACKAGE

# 1- Copy the fglgws package to /tmp/fglgws-install.run
COPY ${FGLGWS_PACKAGE} /tmp/fglgws-install.run

# 2- Create /opt/fourjs - Root installation directory for all FourJs products
#    And change owner/group
RUN mkdir -p /opt/fourjs \
 && chown ${USER}:${GROUP} /opt/fourjs /tmp/fglgws-install.run


# 3- Install fglgws package as ${USER}
USER ${USER}
ENV FGLDIR /opt/fourjs/fglgws
ENV PATH ${FGLDIR}/bin:${PATH}
RUN /tmp/fglgws-install.run --accept --install --quiet --target ${FGLDIR} \
 && rm -f /tmp/fglgws-install.run


##### Patch FGLGWS license software ###########################################
# Dependencies: .tgz archive to install
#
# Uncomment following lines
# and add --build-arg FGLWRT_PACKAGE=Path_to_fglWrt_archive.tgz

# USER root
# ARG FGLWRT_PACKAGE
#
# # 1- Copy the fglWrt package to /tmp/fglWrt-package.tgz
# COPY ${FGLWRT_PACKAGE} /tmp/fglWrt-package.tgz
# RUN chown ${USER}:${GROUP} /tmp/fglWrt-package.tgz
#
# #2- Install license software patch
# USER ${USER}
# RUN cd ${FGLDIR} \
#  && tar xvfz /tmp/fglWrt-package.tgz \
#  && cd ${FGLDIR}/msg/en_US \
#  && fglmkmsg flm.msg flm.iem \
#  && rm -f /tmp/fglWrt-package.tgz

##### Add license configuration in fglprofile if any ##########################
# or add any fglprofile entry that you need
# Comment following lines to disable fglprofile licensing.
USER root
ADD fglprofile /tmp/fglprofile
RUN chown ${USER}:${GROUP} /tmp/fglprofile

USER ${USER}
RUN cat /tmp/fglprofile >> /opt/fourjs/fglgws/etc/fglprofile \
 && rm -f /tmp/fglprofile

##### Install GAS package #####################################################
# Dependencies: .run archive to install
USER root
ARG GAS_PACKAGE
ARG ROOT_URL_PREFIX

# 1- Copy the fglgws package to /tmp/fglgws-install.run
COPY ${GAS_PACKAGE} /tmp/gas-install.run
RUN chown ${USER}:${GROUP} /tmp/gas-install.run

# 2- Install GAS package as ${USER}
USER ${USER}
ENV FGLASDIR /opt/fourjs/gas
ENV PATH ${FGLASDIR}/bin:${FGLDIR}/bin:${PATH}
RUN /tmp/gas-install.run --accept --install --quiet --target ${FGLASDIR} --dvm ${FGLDIR} \
 && rm -f /tmp/gas-install.run

# 3- Update ROOT_URL_PREFIX
RUN sed -i -e "s#\(.*<INTERFACE_TO_CONNECTOR>.*\)#\1<ROOT_URL_PREFIX>${ROOT_URL_PREFIX}</ROOT_URL_PREFIX>#" -e "s#NOBODY#ALL#g" ${FGLASDIR}/etc/as.xcf

##### Configure apache ########################################################
EXPOSE 80

USER root
ARG APACHE_AUTH_FILE

ADD ${APACHE_AUTH_FILE} /opt/fourjs/gas/apache-auth
RUN chown apache:apache /opt/fourjs/gas/apache-auth

# Enable required modules and GAS configuration like mod_proxy_fcgi and auth settings
ADD 000-default.conf /etc/httpd/conf.d/000-default.conf

##### Entry point and Command #################################################
USER root

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

######## setup prompt
#ENV PS1='\u@\H:\w\$ '

