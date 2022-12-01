# [Buildah](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/assembly_building-container-images-with-buildah_building-running-and-managing-containers#proc_building-an-image-from-a-containerfile-with-buildah_assembly_building-container-images-with-buildah)
# [Dockerfile](https://docs.docker.com/engine/reference/builder/)

ARG ALPINE_VERSION=latest

# ╭――――――――――――――――-------------------------------------------------------――╮
# │                                                                         │
# │ STAGE: container                                                        │
# │                                                                         │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/duplicity-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for backup service and system"

# ╭――――――――――――――――――――╮
# │ STANDARD CONFIG    │
# ╰――――――――――――――――――――╯
# USER:
ARG USER=duplicity

ARG UID=1001
ARG GID=1001
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd

# PRIVILEGE:
COPY wheel  /etc/container/wheel

# BACKUP:
COPY backup /etc/container/backup

# ENTRYPOINT:
RUN rm -v /etc/container/entrypoint
COPY entrypoint /etc/container/entrypoint

# FOLDERS
RUN /bin/chown -R $USER:$USER /mnt/volumes/container \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup \
 && /bin/chown -R $USER:$USER /var/backup \
 && /bin/chown -R $USER:$USER /tmp/backup


# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
ARG DUPLICITY_VERSION=1.0.1
ARG DUPLICITY_PACKAGE="$DUPLICITY_VERSION"-r0

COPY backup-synchronize-s3 /usr/bin/backup-synchronize-s3

RUN /bin/ln -fsv /usr/bin/backup-synchronize-s3 /etc/periodic/15min/backup-synchronize-s3
RUN /bin/ln -fsv /mnt/volumes/configmaps/duplicity.key /etc/container/duplicity.key
RUN /bin/ln -fsv /mnt/volumes/container/duplicity.key /mnt/volumes/configmaps/duplicity.key
RUN /bin/ln -fsv /mnt/volumes/configmaps/synchronize.json /etc/container/synchronize.json
RUN /bin/ln -fsv /mnt/volumes/container/synchronize.json /mnt/volumes/configmaps/synchronize.json

RUN /sbin/apk add --no-cache rsync python3 py3-pip py3-boto3 \
 && /sbin/apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/ duplicity=$DUPLICITY_PACKAGE

RUN pip install --upgrade pip

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
EXPOSE 8080/tcp
WORKDIR /home/$USER
