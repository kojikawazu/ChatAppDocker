#!/bin/bash
# -------------------------------------------------------------------------------------
#
# DB準備シェル
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

# ----------------------------------------------------------------
# dbコンテナのデプロイ
# [return]
#  - 0(成功)
#  - 1(異常)
# ----------------------------------------------------------------
deploy_db_container(){
  local -r _input_dir=${FUNCTIONS_DOCKER_DIR}/${INPUT_NAME}
  local -r _input_db_dir=${_input_dir}/${DB_NAME}
  local -r _db_dir=${FUNCTIONS_DOCKER_DIR}/${DB_NAME}
  local -r _db_host_dir=${_db_dir}/${DOCKER_FROM_DIR}

   start_log "Deploy ${DB_NAME} container..."

  # --------------------------------------------------
  # dbディレクトリデプロイ
  # --------------------------------------------------
  exists "${_input_db_dir}" || return ${COM_RESULT_FAILED}
  command_log "Deploy ${DB_NAME} directory"
  ${CMD_CP} -arfp ${_input_db_dir} ${FUNCTIONS_DOCKER_DIR}
  ${CMD_CHMOD} ${PERMISSIONS_RWX_RWX_RWX} ${_input_db_dir}
  command_end_log

  end_log "Deploy ${DB_NAME} container."
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
  start_log "Pre ${DB_NAME} container..."

  # --------------------------------------------------
  # dbコンテナのデプロイ
  # --------------------------------------------------
  deploy_db_container
  _result=$?
  check_result "${_result}"

  end_log "Pre ${DB_NAME} container."
  return ${COM_RESULT_SUCCESSED}
}

main
exit "$?"
