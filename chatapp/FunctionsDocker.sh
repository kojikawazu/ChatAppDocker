#!/bin/bash
# -------------------------------------------------------------------------------------
#
# 関数定義[Docker]
#
# since: 2023/01/26
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------
# 二重呼び出し対策
# ------------------------------------------------
if [ -n "${FUNCTIONS_DOCKER_KEY}" ]; then
  return 0
fi
readonly FUNCTIONS_DOCKER_KEY=FunctionsDocker

# ------------------------------------------------
#- Libs
# ------------------------------------------------
readonly FUNCTIONS_DOCKER_MYSHELL=${FUNCTIONS_DOCKER_KEY}.sh
readonly FUNCTIONS_DOCKER_MYDIR=$(/usr/bin/find $(cd $(/usr/bin/dirname $0) && pwd) -maxdepth 1 -type f -name "${FUNCTIONS_DOCKER_MYSHELL}" -print)
readonly FUNCTIONS_DOCKER_DIR=$(cd $(/usr/bin/dirname ${FUNCTIONS_DOCKER_MYDIR}) && pwd)

if [ -z "${COMMON_FUNCTIONS_SHELL}" ]; then
  readonly COMMON_FUNCTIONS_SHELL=CommonFunctions.sh
fi
if [ -z "${CONSTANTS_DOCKER_SHELL}" ]; then
  readonly CONSTANTS_DOCKER_SHELL=ConstantsDocker.sh
fi
if [ ! -e "${FUNCTIONS_DOCKER_DIR}/common/${COMMON_FUNCTIONS_SHELL}" ] || 
   [ ! -e "${FUNCTIONS_DOCKER_DIR}/${CONSTANTS_DOCKER_SHELL}" ]; then
  exit 1
fi
source "${FUNCTIONS_DOCKER_DIR}/common/${COMMON_FUNCTIONS_SHELL}"
source "${FUNCTIONS_DOCKER_DIR}/${CONSTANTS_DOCKER_SHELL}"

# ------------------------------------------------
# Constants
# ------------------------------------------------

# ------------------------------------------------
# Logic
# ------------------------------------------------

# ----------------------------------------------------------------
# NAT用NICへ変更
# [Return]
# - 正常終了
# ----------------------------------------------------------------
change_nic(){
  ifdown ens33
  ifup ens34
  echo ""
}

# ----------------------------------------------------------------
# NIC戻す
# [Return]
# - 正常終了
# ----------------------------------------------------------------
back_nic(){
  ifdown ens34
  ifup ens33
  echo ""
}

# ----------------------------------------------------------------
# コンテナの停止 & 削除
# [input]
#  - コンテナ名
# [return]
#  - 0(成功)
#  - 1(異常)
# ----------------------------------------------------------------
stop_and_delete_container(){
  local _target=$1
  local _search=""

  if [ -z "${_target}" ]; then
    error_log "Argument error."
    return ${COM_RESULT_FAILED}
  fi

  _search=$(${CMD_DOCKER} ps -a | \
    ${CMD_GREP} -E "\s${_target}$" | \
    ${CMD_AWK} '{print $1}')
  if [ -z "${_search}" ]; then
    echo "None docker container."
    return ${COM_RESULT_SUCCESSED}
  fi

  echo "  Docker stop and delete ID: [${_search}]..."
  ${CMD_DOCKER} stop ${_search}
  ${CMD_DOCKER} rm ${_search}
  echo "  done."
  echo ""

  return ${COM_RESULT_SUCCESSED}
}
