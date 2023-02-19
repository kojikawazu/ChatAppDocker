FROM centos:7

# Deploy ShellScript
ADD files/*.sh /opt/
# Change owner and group
RUN /bin/chmod +x /opt/*.sh

# Deploy Parts
RUN /bin/mkdir -p -m 777 /opt/package
RUN /bin/mkdir -p -m 777 /opt/service
RUN /bin/mkdir -p -m 777 /opt/war
RUN /bin/mkdir -p -m 777 /opt/common
COPY files/package  /opt/package
COPY files/service  /opt/service
COPY files/war      /opt/war
COPY files/common/*.sh /opt/common/

# Run ShellScript
RUN /bin/bash /opt/build.sh

VOLUME [ "/sys/fs/cgroup" ]

CMD [ "/opt/start.sh" ]
