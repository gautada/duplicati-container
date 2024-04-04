ARG ALPINE_VERSION=latest

# │ STAGE: CONTAINER
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/tandoor-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for offsite backup client service"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=duplicity
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd


# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# No backup needed and even disable the automated hourly backup
# COPY backup /etc/container/backup
RUN rm -f /etc/periodic/hourly/container-backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
ARG DUPLICITY_VERSION=2.1.4
ARG DUPLICITY_PACKAGE="$DUPLICITY_VERSION"-r0

RUN /sbin/apk add --no-cache rsync \
 && /sbin/apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/ duplicity=$DUPLICITY_PACKAGE

COPY duplicity-backup /usr/bin/duplicity-backup
COPY duplicity-syncjob /usr/bin/duplicity-syncjob
RUN ln -fsv /usr/bin/duplicity-syncjob /etc/periodic/daily

RUN /sbin/apk add --no-cache rsync python3 py3-pip py3-boto3 \
 && /sbin/apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/latest-stable/community/ duplicity=$DUPLICITY_PACKAGE

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
COPY aws_test.py /home/$USER/aws_test.py
COPY aws_backup.sh /home/$USER/aws_backup.sh
RUN chmod +x /home/$USER/aws_backup.sh
RUN /bin/chown -R $USER:$USER /home/$USER
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
VOLUME /mnt/volumes/source
WORKDIR /home/$USER
