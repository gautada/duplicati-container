ARG ALPINE_VERSION=3.14.1

# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE 1: duplicity-container                                             │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/duplicity-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A backup service and system"

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG DUPLICITY_VERSION=0.8.23
ARG DUPLICITY_PACKAGE="$DUPLICITY_VERSION"-r0

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN ln -s /opt/backup/decryption.key /etc/backup/decryption.key 
RUN /sbin/apk add --no-cache rsync \
 && /sbin/apk add --no-cache duplicity=$DUPLICITY_PACKAGE

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=duplicity
RUN /bin/mkdir -p /opt/$USER /var/backup /tmp/backup /opt/backup \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER /etc/backup /var/backup /tmp/backup /opt/backup
 
USER $USER
WORKDIR /home/$USER
VOLUME /opt/$USER


