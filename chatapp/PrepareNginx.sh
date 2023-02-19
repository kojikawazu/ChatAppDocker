#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Nginx準備シェル
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
# Nginxコンテナデプロイ
# [return]
#  - 0(成功)
#  - 1(異常)
# ------------------------------------------------------------------------------
deploy_nginx_container(){
  local -r _input_dir=${FUNCTIONS_DOCKER_DIR}/${INPUT_NAME}
  local -r _input_nginx_dir=${_input_dir}/${NGINX_NAME}
  local -r _nginx_dir=${FUNCTIONS_DOCKER_DIR}/${NGINX_NAME}

  start_log "Deploy ${NGINX_NAME} container..."

  # --------------------------------------------------
  # nginxディレクトリデプロイ
  # --------------------------------------------------
  exists "${_input_nginx_dir}" || return ${COM_RESULT_FAILED}
  command_log "Deploy ${NGINX_NAME} directory"
  ${CMD_CP} -arfp ${_input_nginx_dir} ${FUNCTIONS_DOCKER_DIR}
  ${CMD_CHMOD} ${PERMISSIONS_RWX_RWX_RWX} ${_nginx_dir}
  command_end_log

  end_log "Deploy ${NGINX_NAME} container."
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# NGINXのDockerfile調整
# [return]
#  - 0(成功)
#  - 1(異常)
# ----------------------------------------------------------------
adjustment_nginx_docker_file(){
  local -r _input_dir=${FUNCTIONS_DOCKER_DIR}/${INPUT_NAME}
  local -r _input_nginx_dir=${_input_dir}/${NGINX_NAME}
  local -r _nginx_dir=${FUNCTIONS_DOCKER_DIR}/${NGINX_NAME}
  local -r _nginx_host_dir=${_nginx_dir}/${DOCKER_FROM_DIR}
  local -r _nginx_dockerfile_full=${_nginx_dir}/${DOCERFILE_NAME}
  local _current_number=0
  local _add_number=0
  start_log "Adjestment ${NGINX_NAME} container..."

  # --------------------------------------------------
  # Dockerfile調整
  # --------------------------------------------------
  exists "${_nginx_dockerfile_full}" || return ${COM_RESULT_FAILED}
  command_log "Edit ${DOCERFILE_NAME}"
  # ① FROM調整
  # FROM削除
  ${CMD_SED} -i "/^${DOCKER_OPTION_FROM}/d" ${_nginx_dockerfile_full}
  # FROM追加
  ${CMD_SED} -i "1i ${DOCKER_OPTION_FROM} ${NGINX_IMAGE_CONTAINER}" ${_nginx_dockerfile_full}

  # ② EXPOSE調整
  # EXPOSE削除
  ${CMD_SED} -i "/^${DOCKER_OPTION_EXPOSE}/d" ${_nginx_dockerfile_full}
  # EXPOSE挿入番号を取得
  _current_number=$(${CMD_SED} -n "/^${DOCKER_OPTION_COPY} /=" ${_nginx_dockerfile_full})
  _add_number=$((_current_number+1))
  # EXPOSE追加-1
  ${CMD_SED} -i "${_add_number}a ${DOCKER_OPTION_EXPOSE} ${NGINX_TO_PORT}" ${_nginx_dockerfile_full}
  # EXPOSE追加-2
  ${CMD_SED} -i "${_add_number}a ${DOCKER_OPTION_EXPOSE} ${TOMCAT_TO_PORT}" ${_nginx_dockerfile_full}
  command_end_log

  end_log "Adjestment ${NGINX_NAME} container."
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

  start_log "Pre ${NGINX_NAME} container..."

  # ----------------------------------------------
  # Nginxコンテナデプロイ
  # ----------------------------------------------
  deploy_nginx_container
  _result=$?
  check_result "${_result}"
  # ----------------------------------------------
  # NGINXのDockerfile調整
  # ----------------------------------------------
  adjustment_nginx_docker_file
  _result=$?
  check_result "${_result}"
  # --------------------------------------------------
  # tomcat.conf調整
  # --------------------------------------------------
  # TODO: listen
  # TODO: server_name
  # TODO: proxy_pass

  end_log "Pre ${NGINX_NAME} container."
  return ${COM_RESULT_SUCCESSED}
}

main
exit "$?"
