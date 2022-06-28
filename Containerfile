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
# │ USER               │
# ╰――――――――――――――――――――╯
ARG UID=1001
ARG GID=1001
ARG USER=duplicity
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd
 
# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG DUPLICITY_VERSION=0.8.23
ARG DUPLICITY_PACKAGE="$DUPLICITY_VERSION"-r0

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY 10-ep-container.sh /etc/container/entrypoint.d/10-ep-container.sh
COPY backup-synchronize-s3 /usr/sbin/backup-synchronize-s3
RUN ln -s /usr/sbin/backup-synchronize-s3 /etc/periodic/15min/backup-synchronize-s3
COPY wheel-synchronize /etc/container/wheel.d/wheel-synchronize
RUN /bin/mkdir -p /opt/$USER /etc/duplicity /opt/backup
RUN ln -s /opt/duplicity/decryption.pri /etc/duplicity/decryption.pri \
 && ln -s /opt/duplicity/synchronize.json /etc/duplicity/synchronize.json
RUN /sbin/apk add --no-cache rsync python3 py3-pip py3-boto3 \
 && /sbin/apk add --no-cache duplicity=$DUPLICITY_PACKAGE
RUN /bin/chown $USER:$USER -R /opt/$USER /opt/backup
RUN pip install --upgrade pip

USER $USER
WORKDIR /home/$USER
VOLUME /opt/$USER


