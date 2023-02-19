#!/bin/bash
# -------------------------------------------------------------------------------------
#
# 定数定義[共通部]
#
# since: 2023/01/26
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------
# 二重呼び出し対策
# ------------------------------------------------
if [ -n "${COMMON_CONSTANTS_KEY}" ]; then
  return 0
fi
readonly COMMON_CONSTANTS_KEY=CommonConstants

# ------------------------------------------------
# Constants
# ------------------------------------------------

# ------------------------------------------------
# Command
# ------------------------------------------------
readonly CMD_AWK=/bin/awk
readonly CMD_CAT=/bin/cat
readonly CMD_CP=/bin/cp
readonly CMD_CHMOD=/bin/chmod
readonly CMD_CHOWN=/bin/chown
readonly CMD_GREP=/bin/grep
readonly CMD_GROUPADD=/usr/sbin/groupadd
readonly CMD_ID=/bin/id
readonly CMD_MKDIR=/bin/mkdir
readonly CMD_LS=/bin/ls
readonly CMD_MV=/bin/mv
readonly CMD_RM=/bin/rm
readonly CMD_SED=/bin/sed
readonly CMD_TAR=/usr/bin/tar
readonly CMD_TR=/usr/bin/tr
readonly CMD_USERADD=/usr/sbin/useradd
readonly CMD_WGET=/bin/wget
readonly CMD_YUM=/bin/yum
readonly CMD_PUSHD=pushd
readonly CMD_POPD=popd
readonly CMD_DOCKER=/usr/bin/docker
readonly CND_DOCKER_COMPOSE=/usr/local/bin/docker-compose

# ------------------------------------------------
# Return status
# ------------------------------------------------
readonly COM_RESULT_SUCCESSED=0
readonly COM_RESULT_FAILED=1
readonly COM_RESULT_ALREADY=2

# ------------------------------------------------
# Name
# ------------------------------------------------
readonly TOMCAT_NAME=tomcat
readonly NGINX_NAME=nginx
readonly DB_NAME=db
readonly INPUT_NAME=input
readonly COMPOSE_NAME=compose
readonly COMMON_NAME=common
readonly PACKAGE_NAME=package
readonly JDK_NAME=jdk
readonly WAR_NAME=war

# ------------------------------------------------
# Dir
# ------------------------------------------------
readonly DOCKER_FROM_DIR=files
readonly DOCKER_TO_DIR=/opt
readonly ROOT_ETC_DIR=/etc
readonly ROOT_RUN_DIR=/run
readonly ROOT_TMP_DIR=/tmp
readonly ROOT_VAR_DIR=/var
readonly LIB_SYSTEMD_SYSTEM_DIR=/lib/systemd/system
readonly ETC_SYSTEMD_SYSTEM_DIR=/etc/systemd/system
readonly NGING_DIR=${ROOT_ETC_DIR}/nginx
readonly NGING_CONF_DIR=${NGING_DIR}/conf.d/
readonly CATALINA_HOME=${ROOT_VAR_DIR}/${TOMCAT_NAME}
readonly WEBAPPS_DIR=${CATALINA_HOME}/webapps

# ------------------------------------------------
# File Permission
# ------------------------------------------------
readonly PERMISSIONS_RWX_RX_RX=755
readonly PERMISSIONS_RWX_RWX_RWX=777

# ------------------------------------------------
# User and group
# ------------------------------------------------
readonly SUPER_USER_NAME=root
readonly SUPER_GROUP_NAME=root

# ------------------------------------------------
# Docker
# ------------------------------------------------
readonly DOCERFILE_NAME=Dockerfile
readonly DOCKER_COMPOSE_YML=docker-compose.yml

# ------------------------------------------------
# Dockerfile
# ------------------------------------------------
readonly DOCKER_OPTION_EXPOSE=EXPOSE
readonly DOCKER_OPTION_COPY=COPY
readonly DOCKER_OPTION_FROM=FROM

# ------------------------------------------------
# Network
# ------------------------------------------------
readonly LOCALHOST_NAME=localhost

# ------------------------------------------------
# Service
# ------------------------------------------------
readonly SERVICE_NAME=service
readonly OPTION_DESC=Description

# ------------------------------------------------
# Volume
# ------------------------------------------------
readonly CGROUP_DIR=/sys/fs/cgroup

# ------------------------------------------------
# NGINX
# ------------------------------------------------
readonly TOMCAT_CONF=tomcat.conf
readonly NGINX_CONF=nginx.conf
