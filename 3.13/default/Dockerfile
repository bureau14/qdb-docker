#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM  docker.io/debian:11

LABEL maintainer="support@quasar.ai"

ARG   QDB_UID=1000
ARG   QDB_GID=1000

ENV   QDB_VERSION="3.13"
ENV   QDB_USER="qdb"
ENV   QDB_GROUP="qdb"
ENV   QDB_HOME="/opt/qdb"

ENV   DEBIAN_FRONTEND="noninteractive"

RUN        apt-get update &&                       \
           apt-get upgrade -y  &&                  \
           apt-get install -y                      \
                           --no-install-recommends \
                           apt-utils               \
                           dnsutils                \
                           iproute2                \
                           jq                      \
                           locales                 \
                           net-tools               \
                           curl &&                 \
           apt-get clean &&                        \
    rm -rf /var/lib/apt/lists/*                    \
                                                   \
    && locale-gen en_US.UTF-8                      \
                                                   \
    && groupadd --system                           \
                --gid ${QDB_GID}                   \
                ${QDB_GROUP}                       \
    && useradd  --system                           \
                --uid ${QDB_UID}                   \
                --home-dir ${QDB_HOME}             \
                --gid ${QDB_GROUP}                 \
                ${QDB_USER}                        \
                                                   \
    && mkdir --parents ${QDB_HOME}                 \
    && chown --recursive                           \
             ${QDB_USER}:${QDB_GROUP}              \
             ${QDB_HOME}

USER  ${QDB_USER}:${QDB_GROUP}
