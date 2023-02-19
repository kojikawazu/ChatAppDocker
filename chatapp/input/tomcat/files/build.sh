#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Tomcatコンテナビルド実行
#
# since: 2023/02/07
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------------------------
# Current path
# ------------------------------------------------------------------
readonly CURRENT_DIR=$(cd $(/usr/bin/dirname $0) && pwd)

# ------------------------------------------------
#- Libs
# ------------------------------------------------
if [ -z "${COMMON_FUNCTIONS_SHELL}" ]; then
  readonly COMMON_FUNCTIONS_SHELL=CommonFunctions.sh
fi
if [ -z "${CONSTANTS_DOCKER_SHELL}" ]; then
  readonly CONSTANTS_DOCKER_SHELL=ConstantsDocker.sh
fi

if [ ! -e "${CURRENT_DIR}/common/${COMMON_FUNCTIONS_SHELL}" ] ||
   [ ! -e "${CURRENT_DIR}/${CONSTANTS_DOCKER_SHELL}" ]; then
  exit 1
fi
source "${CURRENT_DIR}/common/${COMMON_FUNCTIONS_SHELL}"
source "${CURRENT_DIR}/${CONSTANTS_DOCKER_SHELL}"


# ------------------------------------------------------------------
# Constants setting
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# コマンド
# ------------------------------------------------------------------
readonly BUILD_CMD_JAR=/usr/bin/jar

# ------------------------------------------------------------------
# ディレクトリ
# ------------------------------------------------------------------
readonly WORK_DIR=/opt
readonly WORK_PACKAGE_DIR=${WORK_DIR}/${PACKAGE_NAME}
readonly WORK_SERVICE_DIR=${WORK_DIR}/${SERVICE_NAME}
readonly WORK_WAR_DIR=${WORK_DIR}/${WAR_NAME}
readonly WORK_DIR=/opt
readonly WORK_LOG_DIR=${WORK_DIR}/log/

# ------------------------------------------------------------------
# ユーザー、グループ
# ------------------------------------------------------------------
readonly USER_ID_TOMCAT=1000
readonly GROUP_ID_TOMCAT=1000

# ------------------------------------------------------------------
#- ログファイル
# ------------------------------------------------------------------
readonly BUILD_LOG_FILE=build.log
readonly WORK_LOG_FULL_PATH=${WORK_LOG_DIR}/${BUILD_LOG_FILE}

# ------------------------------------------------------------------
# Logic
# ------------------------------------------------------------------

# ------------------------------------------------------------------------------
# 終了処理
# [Arguments]
# - 終了コード
# [Return]
# - 終了コード: exitで終了
# ------------------------------------------------------------------------------
exit_action(){
  local _result_code=$1
  if [ -z "${_result}" ]; then
    _result_code=0
  fi

  echo "exit code: [${_result_code}]"
  exit ${_result_code}
}

# ------------------------------------------------------------------
# 全体アップデート
# [Return]
# - 0: 正常終了
# ------------------------------------------------------------------
yum_update(){
  start_log "yum update"

  command_log "${CMD_YUM} -y update"
  ${CMD_YUM} -y update
  command_end_log

  end_log " yum update."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# パッケージインストール
# [Return]
# - 0: 正常終了
# - 1: 異常終了(exitで終了)
# ------------------------------------------------------------------
install_package(){
  local _result=0
  start_log "install java"

  ${CMD_CAT} << JDK_INSTALL_LIST
${JDK_PACKAGE}
${JDK_DEVEL}
JDK_INSTALL_LIST
  echo ""

  # ---------------------------------------------
  # jdkのインストール
  # ---------------------------------------------
  command_log "${CMD_YUM} -y (${JDK_PACKAGE}) (${JDK_DEVEL})"
  ${CMD_YUM} -y install ${JDK_PACKAGE}
  ${CMD_YUM} -y install ${JDK_DEVEL}
  command_end_log
  # ---------------------------------------------
  # インストール後確認
  # ---------------------------------------------
  command_log "${CMD_YUM} list installed | ${CMD_GREP} \"${JDK_PACKAGE}\""
  ${CMD_YUM} list installed | /bin/grep "${JDK_PACKAGE}"
  _result=$?
  command_end_log
  if [ ${_result} -ne 0 ]; then
    error_log "${JDK_PACKAGE} not installed."
    exit_action ${COM_RESULT_FAILED}
  fi
  
  end_log "install java."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# systemdの準備
# [Return]
# - 0: 正常終了
# ------------------------------------------------------------------
pre_systemd(){
  local _target_dir=${LIB_SYSTEMD_SYSTEM_DIR}/sysinit.target.wants/

  start_log "prepare systemd"
  {
    cd ${_target_dir}

    for i in *; do \
      [ $i == systemd-tmpfiles-setup.service ] || /bin/rm -f $i;
    done

    ${CMD_RM} -f ${LIB_SYSTEMD_SYSTEM_DIR}/multi-user.target.wants/*
    ${CMD_RM} -f ${ETC_SYSTEMD_SYSTEM_DIR}/*.wants/*
    ${CMD_RM} -f ${LIB_SYSTEMD_SYSTEM_DIR}/local-fs.target.wants/*
    ${CMD_RM} -f ${LIB_SYSTEMD_SYSTEM_DIR}/sockets.target.wants/*udev*
    ${CMD_RM} -f ${LIB_SYSTEMD_SYSTEM_DIR}/sockets.target.wants/*initctl*
    ${CMD_RM} -f ${LIB_SYSTEMD_SYSTEM_DIR}/basic.target.wants/*
    ${CMD_RM} -f ${LIB_SYSTEMD_SYSTEM_DIR}/anaconda.target.wants/*

    cd ${CURRENT_DIR}
  }
  end_log "prepare systemd."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# Tomcat設置
# [Return]
# - 0: 正常終了
# - 1: 異常終了(exitで終了)
# ------------------------------------------------------------------
install_tomcat(){
  local _package_path=${WORK_PACKAGE_DIR}/${TOMCAT_PACKAGE}
  local _from=${WORK_PACKAGE_DIR}/${TOMCAT_FILE_NAME}
  local _to=${CATALINA_HOME}

  start_log "install tomcat"

  # ---------------------------------------------
  # Tomcatディレクトリチェック
  # ---------------------------------------------
  exists "${_package_path}" || exit_action ${COM_RESULT_FAILED}
  # ---------------------------------------------
  # Tomcatファイル設置
  # ---------------------------------------------
  (
    command_log "Goto directory... (${WORK_PACKAGE_DIR})"
    cd "${WORK_PACKAGE_DIR}"
    command_end_log

    command_log "Unpack package... (${TOMCAT_PACKAGE})"
    ${CMD_TAR} -zxvf ${TOMCAT_PACKAGE}
    command_end_log

    command_log "Move (${_from}) -> (${_to})"
    ${CMD_MV} -f ${_from} ${_to}
    command_end_log
    exists "${_to}" || exit_action ${COM_RESULT_FAILED}

    command_log "Goto directory... (Home Directory)"
    cd ~
    command_end_log
  )
  # ---------------------------------------------
  # Tomcatファイルログ出力
  # ---------------------------------------------
  command_log "/bin/ls -l (${_to})"
  ${CMD_LS} -l ${_to}
  command_end_log

  end_log "install tomcat."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# Tomcatユーザ追加
# [Return]
# - 0: 正常終了
# ------------------------------------------------------------------
add_tomcat_user(){
  local _group_id=${GROUP_ID_TOMCAT}
  local _user_id=${USER_ID_TOMCAT}
  local _owner="${TOMCAT_NAME}:${TOMCAT_NAME}"

  start_log "add tomcat user"

  # ---------------------------------------------
  # Tomcatユーザー追加
  # ---------------------------------------------
  command_log "groupadd and useradd (${TOMCAT_NAME})"
  ${CMD_GROUPADD} -g ${_group_id} ${TOMCAT_NAME}
  ${CMD_USERADD} -u ${_user_id} -g ${TOMCAT_NAME} -M ${TOMCAT_NAME}
  command_end_log
  # ---------------------------------------------
  # CATALINA_HOMEディレクトリの所有者、所有グループ変更
  # ---------------------------------------------
  command_log "change directory. (owner and group)"
  ${CMD_CHOWN} -R "${_owner}" ${CATALINA_HOME}
  command_end_log
  # ---------------------------------------------
  # 確認
  # ---------------------------------------------
  command_log "${TOMCAT_NAME} user."
  ${CMD_ID} ${TOMCAT_NAME}
  command_log "${CATALINA_HOME}"
  ${CMD_LS} -l ${ROOT_VAR_DIR} | ${CMD_GREP} ${TOMCAT_NAME}
  command_end_log

  end_log "add tomcat user."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# APIインストール
# [Return]
# - 0: 正常終了
# - 1: 異常終了(exitで終了)
# ------------------------------------------------------------------
install_api(){
  local _from=${WORK_WAR_DIR}/${MY_API_WAR}
  local _to=${WEBAPPS_DIR}/${MY_API_WAR}
  local _owner="${TOMCAT_NAME}:${TOMCAT_NAME}"

  start_log "install api"

  # ---------------------------------------------
  # ファイルチェック
  # ---------------------------------------------
  exists "${_from}" || exit_action ${COM_RESULT_FAILED}
  # ---------------------------------------------
  # application.ymlの編集
  # ---------------------------------------------
  (
    local _edit_dir=${WEB_INF_CLASSES_DIR}
    local _edit_file=${_edit_dir}/${APP_YML}
    local _current_data=""
    local _before_data=""
    local _after_data="\/\/${DB_HOST_NAME}:${DB_PORT}\/${DB_DB_NAME}"

    command_log "Goto directory... (${WORK_WAR_DIR})"
    cd ${WORK_WAR_DIR}
    command_end_log

    # ---------------------------------------------
    # application.yml取り出し
    # ---------------------------------------------
    command_log "${BUILD_CMD_JAR} xvf (${_from}) (${_edit_file})"
    ${BUILD_CMD_JAR} xvf ${_from} ${_edit_file}
    command_end_log
    # ---------------------------------------------
    # application.yml取り出しチェック
    # ---------------------------------------------
    command_log "Goto directory... (${WORK_WAR_DIR}/${_edit_dir})"
    cd ${WORK_WAR_DIR}/${_edit_dir}
    command_log "${CMD_LS} -l" && ${CMD_LS} -l
    command_end_log
    exists "${APP_YML}" || return 1
    # ---------------------------------------------
    # 現在のurlプロパティの値取り出し
    # ---------------------------------------------
    _current_data=$(${CMD_GREP} -E "^[ |\t]+url" ${APP_YML} | \
                    ${CMD_TR} -d "\r"  | \
                    ${CMD_SED} -e "s/\n//" | \
                    ${CMD_SED} -e "s/.*jdbc:mysql://")
    echo "[1] _current_data= ${_current_data}"
    isData "${_current_data}" || return 1
    # ---------------------------------------------
    # 現在のurlプロパティの値加工
    # ---------------------------------------------
    _before_data=$(echo "${_current_data}" | \
                    ${CMD_SED} -e "s/\//\\\.\//g" | \
                    ${CMD_SED} -e "s/\.//g")
    echo " [2] _before_data= ${_before_data}"
    isData "${_before_data}" || return 1
    # ---------------------------------------------
    # url編集処理
    # ---------------------------------------------
    command_log "${CMD_SED} -i \"s/${_before_data}/${_after_data}/\" ${APP_YML}"
    ${CMD_SED} -i "s/${_before_data}/${_after_data}/" ${APP_YML}
    command_end_log
    # ---------------------------------------------
    # application.ymlログ出力
    # ---------------------------------------------
    command_log "${CMD_CAT} (${APP_YML})"
    ${CMD_CAT} ${APP_YML}
    command_log "Goto directory... (${WORK_WAR_DIR})"
    cd ${WORK_WAR_DIR}
    command_log "${CMD_LS} -l" && ${CMD_LS} -l
    command_end_log
    # ---------------------------------------------
    # application.yml更新
    # ---------------------------------------------
    command_log "${BUILD_CMD_JAR} uf (${_from}) (${_edit_file})"
    ${BUILD_CMD_JAR} uf ${_from} ${_edit_file}
    command_log " Goto current directory..."
    cd ~
    command_end_log
  ) || return 1

  # ---------------------------------------------
  # /var/tomcat/webappsへ配置
  # ---------------------------------------------
  command_log "Copy (${_from}) -> (${_to})"
  ${CMD_CP} -afp ${_from} ${_to}
  ${CMD_CHMOD} ${PERMISSIONS_RWX_RX_RX} ${_to}
  ${CMD_CHOWN} "${_owner}" ${_to}
  command_end_log

  # ---------------------------------------------
  # warデプロイ確認
  # ---------------------------------------------
  exists "${_to}" || exit_action ${COM_RESULT_FAILED}
  command_log "${CMD_LS} -l ${_to}"
  ${CMD_LS} -l "${_to}"
  command_end_log

  end_log "successed apply my war."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# Tomcatユニットファイル追加
# [Return]
# - 0: 正常終了
# - 1: 異常終了(exitで終了)
# ------------------------------------------------------------------
add_tomcat_unitfile(){
  local _from=${WORK_SERVICE_DIR}/${TOMCAT_SERVICE_FILE}
  local _to=${ETC_SYSTEMD_SYSTEM_DIR}/${TOMCAT_SERVICE_FILE}
  local _owner_and_group="${SUPER_USER_NAME}:${SUPER_GROUP_NAME}"

  start_log "Create unit file."

  # ---------------------------------------------
  # Tomcatユニットファイルデプロイ
  # ---------------------------------------------
  exists "${_from}" || exit_action ${COM_RESULT_FAILED}
  command_log "Copy (${_from}) -> (${_to})"
  ${CMD_CP} -afp ${_from} ${_to}
  ${CMD_CHMOD} ${PERMISSIONS_RWX_RX_RX} ${_to}
  ${CMD_CHOWN} "${_owner_and_group}" ${_to}
  command_end_log

  # ---------------------------------------------
  # Tomcatユニットファイル確認
  # ---------------------------------------------
  exists "${_to}" || exit_action ${COM_RESULT_FAILED}
  command_log "${CMD_LS} -l ${_to}"
  ${CMD_LS} -l "${_to}"
  command_end_log

  end_log "Create unit file."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------
# Main関数
# ------------------------------------------------------------------
main(){
  # ----------------------------------
  #- ログディレクトリ作成
  # ----------------------------------
  if [ ! -e "${WORK_LOG_DIR}" ]; then
    ${CMD_MKDIR} -p -m 777 ${WORK_LOG_DIR}
  fi

  {
    # ----------------------------------
    # 全体アップデート
    # ----------------------------------
    yum_update
    # ----------------------------------
    # パッケージインストール
    # ----------------------------------
    install_package
    # ----------------------------------
    # systemdの準備
    # ----------------------------------
    pre_systemd
    # ----------------------------------
    # Tomcatインストール
    # ----------------------------------
    install_tomcat
    # ----------------------------------
    # Tomcatユーザ追加
    # ----------------------------------
    add_tomcat_user
    # ----------------------------------
    # App配置
    # ----------------------------------
    install_api
    # ----------------------------------
    # Tomcatユニットファイル生成
    # ----------------------------------
    add_tomcat_unitfile
  } 2>&1 | /usr/bin/tee ${WORK_LOG_FULL_PATH}

  return 0
}

main "$@"
exit "$?"
