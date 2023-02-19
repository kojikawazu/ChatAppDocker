#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Tomcat準備シェル
#
# since: 2023/01/26
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------
#- Lib
# ------------------------------------------------
readonly SHELL_NAME=$(cd $(/usr/bin/dirname $0) && pwd)
readonly FUNC_DOCKER_SHELL=FunctionsDocker.sh
if [ ! -e "${SHELL_NAME}/${FUNC_DOCKER_SHELL}" ]; then
  exit 1
fi
source "${SHELL_NAME}/${FUNC_DOCKER_SHELL}"

# ------------------------------------------------
#- Logic
# ------------------------------------------------

# ------------------------------------------------------------------------------
# 処理結果判定
# [Return]
# - 0: (正常終了)
# - 1: (異常終了 - exitで終了)
# ------------------------------------------------------------------------------
check_result(){
  local _result=$1
  if [ -z "${_result}" ] || [ ${_result} -eq 1 ]; then
    back_nic
    exit ${COM_RESULT_FAILED}
  fi

  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------------------
# Tomcatコンテナデプロイ
# [return]
#  - 0(成功)
#  - 1(異常)
# ------------------------------------------------------------------------------
deploy_tomcat_container(){
  local -r _input_dir=${FUNCTIONS_DOCKER_DIR}/${INPUT_NAME}
  local -r _input_tomcat_dir=${_input_dir}/${TOMCAT_NAME}
  local -r _tomcat_dir=${FUNCTIONS_DOCKER_DIR}/${TOMCAT_NAME}
  local -r _tomcat_host_dir=${_tomcat_dir}/${DOCKER_FROM_DIR}
  local -r _tomcat_host_common_dir=${_tomcat_host_dir}/common

  start_log "Deploy ${TOMCAT_NAME} container..."

  # --------------------------------------------------
  # Tomcatディレクトリデプロイ
  # --------------------------------------------------
  exists "${_input_tomcat_dir}" || return ${COM_RESULT_FAILED}
  command_log "Deploy ${TOMCAT_NAME} directory"
  ${CMD_CP} -arfp ${_input_tomcat_dir} ${FUNCTIONS_DOCKER_DIR}
  ${CMD_CHMOD} ${PERMISSIONS_RWX_RWX_RWX} ${_tomcat_dir}
  command_end_log

  # --------------------------------------------------
  # 共通シェルスクリプトをTomcatコンテナに組み込み
  # --------------------------------------------------
  command_log "Deploy common ShellScript"
  ${CMD_CP} -arfp ${SHELL_NAME}/${COMMON_NAME} ${_tomcat_host_dir}
  ${CMD_CP} -afp ${SHELL_NAME}/ConstantsDocker.sh ${_tomcat_host_dir}
  command_end_log

  end_log "Deploy ${TOMCAT_NAME} container."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------------------
# Tomcatパッケージのダウンロード
# [return]
#  - 0(成功)
#  - 1(異常)
# ------------------------------------------------------------------------------
download_tomcat_package(){
  local -r _input_dir=${FUNCTIONS_DOCKER_DIR}/${INPUT_NAME}
  local -r _input_tomcat_dir=${_input_dir}/${TOMCAT_NAME}
  local -r _tomcat_dir=${FUNCTIONS_DOCKER_DIR}/${TOMCAT_NAME}
  local -r _tomcat_host_dir=${_tomcat_dir}/${DOCKER_FROM_DIR}
  local -r _tomcat_host_package_dir=${_tomcat_host_dir}/${PACKAGE_NAME}

  start_log "Download ${TOMCAT_NAME} package..."

  # ------------------------------------------------------------
  # tomcatダウンロード
  # ------------------------------------------------------------
  command_log "Download ${TOMCAT_NAME} package"
  if [ ! -e "${_tomcat_host_package_dir}/${TOMCAT_PACKAGE}" ]; then
    ${CMD_MKDIR} -p -m ${PERMISSIONS_RWX_RWX_RWX} ${_tomcat_host_package_dir}
    ${CMD_WGET} ${TOMCAT_DOWNLOAD_URL}
    ${CMD_MV} -f ${TOMCAT_PACKAGE} ${_tomcat_host_package_dir}/.
  fi
  command_end_log

  end_log "Download ${TOMCAT_NAME} package."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------------------
# Tomcatサービスの調整
# [return]
#  - 0(成功)
#  - 1(異常)
# ------------------------------------------------------------------------------
adjustment_tomcat_service(){
  local -r _input_dir=${FUNCTIONS_DOCKER_DIR}/${INPUT_NAME}
  local -r _input_tomcat_dir=${_input_dir}/${TOMCAT_NAME}
  local -r _tomcat_dir=${FUNCTIONS_DOCKER_DIR}/${TOMCAT_NAME}
  local -r _tomcat_host_dir=${_tomcat_dir}/${DOCKER_FROM_DIR}
  local -r _tomcat_host_service_dir=${_tomcat_host_dir}/${SERVICE_NAME}
  local -r _tomcat_service_full=${_tomcat_host_service_dir}/${TOMCAT_SERVICE_FILE}
  local _current_word=""

  start_log "Adjustment ${TOMCAT_NAME} service..."

  # ------------------------------------------------------------
  # Tomcatサービス編集
  # ------------------------------------------------------------
  exists "${_tomcat_service_full}" || return ${COM_RESULT_FAILED}
  command_log "Edit ${TOMCAT_SERVICE_FILE}"
  _current_word=$(${CMD_GREP} -E "^${OPTION_DESC}\=" ${_tomcat_service_full})
  ${CMD_SED} -i "s/^${_current_word}$/${OPTION_DESC}=${TOMCAT_FILE_NAME}/" ${_tomcat_service_full}
  command_end_log

  end_log "Adjustment ${TOMCAT_NAME} service."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------------------
# Main関数
# [return]
#  - 0(成功)
#  - 1(異常)
# ------------------------------------------------------------------------------
main(){
  local _result=0
  start_log "Pre ${TOMCAT_NAME} container..."

  # ----------------------------------------------
  # Tomcatコンテナデプロイ
  # ----------------------------------------------
  deploy_tomcat_container
  _result=$?
  check_result "${_result}"
  # ----------------------------------------------
  # Tomcatパッケージのダウンロード
  # ----------------------------------------------
  download_tomcat_package
  _result=$?
  check_result "${_result}"
  # ----------------------------------------------
  # Tomcatサービスの調整
  # ----------------------------------------------
  adjustment_tomcat_service
  _result=$?
  check_result "${_result}"

  end_log "Pre ${TOMCAT_NAME} container."
  return ${COM_RESULT_SUCCESSED}
}

main
exit "$?"
