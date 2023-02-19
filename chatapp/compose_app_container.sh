#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Appコンテナビルド ＆ 起動
#
# since: 2023/01/26
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------
# Current path
# ------------------------------------------------
readonly CURRENT_DIR=$(cd $(/usr/bin/dirname $0) && pwd)

# ------------------------------------------------
#- Lib
# ------------------------------------------------
if [ ! -e "${CURRENT_DIR}/FunctionsDocker.sh" ]; then
  exit 1
fi
source "${CURRENT_DIR}/FunctionsDocker.sh"

# ------------------------------------------------
#- Constants
# ------------------------------------------------
readonly HOST_LOG_DIR=${CURRENT_DIR}/logs
readonly HOST_LOG_FILE=$(/usr/bin/basename $0)_$(/bin/date +%Y%m%d_%H%M%S).log
readonly HOST_LOG_FULL_PATH=${HOST_LOG_DIR}/${HOST_LOG_FILE}

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
# Main前準備
# [Return]
# - 0: (正常終了)
# ------------------------------------------------------------------------------
pre_main(){
 echo "None. pre_main()"
}

# ------------------------------------------------------------------------------
# docker-compose.ymlの準備
# [Return]
# - 0: (正常終了)
# - 1: (異常終了)
# ------------------------------------------------------------------------------
pre_docker_compose_yml(){
  local -r _input_dir=${CURRENT_DIR}/${INPUT_NAME}
  local -r _compose_dir=${_input_dir}/${COMPOSE_NAME}
  local -r _from=${_compose_dir}/${CHAT_APP_COMPOSE_YML}
  local -r _to=${CURRENT_DIR}/${DOCKER_COMPOSE_YML}

  start_log "Create docker compose yml file..."

  # --------------------------------------------------
  # Composeディレクトリデプロイ
  # --------------------------------------------------
  exists "${_from}" || return ${COM_RESULT_FAILED}

  command_log "Deploy docker compose"
  ${CMD_CP} -afp ${_from} ${_to}
  command_log "${_to}" && ${CMD_LS} -l
  command_end_log

  end_log "Create docker compose yml file."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------------------
# compose起動
# [Return]
# - 0: (正常終了)
# - 1: (異常終了 - exitで終了)
# ------------------------------------------------------------------------------
compose_up(){
  start_log "Docker run container..."

  # ------------------------------------------------------------
  # compose起動
  # ------------------------------------------------------------
  ${CND_DOCKER_COMPOSE} up -d --build

  # ------------------------------------------------------------
  # コンテナ確認
  # ------------------------------------------------------------
  command_log "${CMD_DOCKER} ps -a"
  ${CND_DOCKER_COMPOSE} ps -a
  echo ""
  command_log "${CMD_DOCKER} logs"
  ${CMD_DOCKER} logs ${CHATAPP_TOMCAT_CONTAINER_NAME}
  echo ""
  ${CMD_DOCKER} logs ${CHATAPP_NGINX_CONTAINER_NAME}
  echo ""
  ${CMD_DOCKER} logs ${CHATAPP_DB_CONTAINER_NAME}
  echo ""

  end_log "Successed run container."
  return ${COM_RESULT_SUCCESSED}
}

# ------------------------------------------------------------------------------
# Main関数
# [Return]
# - 0: (正常終了)
# ------------------------------------------------------------------------------
main(){
  local _result=0

  # ----------------------------------
  #- ログディレクトリ作成
  # ----------------------------------
  if [ ! -e "${HOST_LOG_DIR}" ]; then
    /bin/mkdir -p -m 777 ${HOST_LOG_DIR}
  fi

  {
    # ----------------------------------
    # NAT用NICへ変更
    # ----------------------------------
    change_nic
    # ----------------------------------
    # Main前準備
    # ----------------------------------
    pre_main
    # ----------------------------------
    # Tomcatコンテナ準備
    # ----------------------------------
    ${CURRENT_DIR}/PrepareTomcat.sh
    _result=$?
    check_result "${_result}"
    # ----------------------------------
    # NGINXコンテナ準備
    # ----------------------------------
    ${CURRENT_DIR}/PrepareNginx.sh
    _result=$?
    check_result "${_result}"
    # ----------------------------------
    # DBコンテナ準備
    # ----------------------------------
    ${CURRENT_DIR}/PrepareDB.sh
    _result=$?
    check_result "${_result}"
    # ----------------------------------
    # docker-compose.ymlの準備
    # ----------------------------------
    pre_docker_compose_yml
    _result=$?
    check_result "${_result}"
    # ----------------------------------
    # compose起動
    # ----------------------------------
    compose_up
    _result=$?
    check_result "${_result}"
    # ----------------------------------
    # NIC戻す
    # ----------------------------------
    back_nic
  } 2>&1 | /usr/bin/tee ${HOST_LOG_FULL_PATH}

  return ${COM_RESULT_SUCCESSED}
}

main "$@"
exit "$?"