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
# │ APPLICATION        │
# ╰――――――――――――――――――――╯

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
ARG DUPLICITY_VERSION=0.8.23
ARG DUPLICITY_PACKAGE="$DUPLICITY_VERSION"-r0
RUN /sbin/apk add --no-cache duplicity=$DUPLICITY_PACKAGE

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=duplicity
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER
 
USER $USER
WORKDIR /home/$USER
VOLUME /opt/$USER


