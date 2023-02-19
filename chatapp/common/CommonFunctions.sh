#!/bin/bash
# -------------------------------------------------------------------------------------
#
# 関数定義[共通部]
#
# since: 2023/01/26
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------
# 二重呼び出し対策
# ------------------------------------------------
if [ -n "${COMMON_FUNCTIONS_KEY}" ]; then
  return 0
fi
readonly COMMON_FUNCTIONS_KEY=CommonFunctions

# ------------------------------------------------
#- Libs
# ------------------------------------------------
readonly COMMON_FUNCTIONS_MYSHELL=${COMMON_FUNCTIONS_KEY}.sh
readonly COMMON_FUNCTIONS_MYDIR=$(/usr/bin/find $(cd $(/usr/bin/dirname $0) && pwd) -maxdepth 2 -type f -name "${COMMON_FUNCTIONS_MYSHELL}" -print)
readonly COMMON_FUNCTIONS_DIR=$(cd $(/usr/bin/dirname ${COMMON_FUNCTIONS_MYDIR}) && pwd)

if [ -z "${COMMON_CONSTANTS_SHELL}" ]; then
  readonly COMMON_CONSTANTS_SHELL=CommonConstants.sh
fi
if [ ! -e "${COMMON_FUNCTIONS_DIR}/${COMMON_CONSTANTS_SHELL}" ]; then
  exit 1
fi
source "${COMMON_FUNCTIONS_DIR}/${COMMON_CONSTANTS_SHELL}"

# ------------------------------------------------
# Constants
# ------------------------------------------------

# ------------------------------------------------
# Logic
# ------------------------------------------------

# ----------------------------------------------------------------
# 改行ログ
# [Return]
# - 正常終了
# ----------------------------------------------------------------
line_log(){
  echo ""
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# 開始ログ
# [Arguments]
# - ログ
# [Return]
# - 正常終了
# ----------------------------------------------------------------
start_log(){
  local _start="[Start]"
  local _log="$1"
  if [ -z "${_log}" ]; then
    return ${COM_RESULT_SUCCESSED}
  fi

  echo " ${_start} ${_log}..."
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# 終了ログ
# [Arguments] 
# - ログ
# [Return]
# - 正常終了
# ----------------------------------------------------------------
end_log(){
  local _end="[End  ]"
  local _log="$1"
  if [ -z "${_log}" ]; then
    return ${COM_RESULT_SUCCESSED}
  fi

  echo " ${_end} ${_log}"
  line_log
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# 終了ログ
# [Arguments] 
# - 終了コード番号
# [Return]
# - 正常終了
# ----------------------------------------------------------------
exit_action(){
  local _exit_code="$1"

  echo "EXIT_CODE: ${_exit_code}"
  line_log
  exit ${_exit_code}
}

# ----------------------------------------------------------------
# エラーログ
# [Arguments] 
# - ログ
# [Return]
# - 正常終了
# ----------------------------------------------------------------
error_log(){
  local _error="[error]"
  local _log="$1"
  if [ -z "${_log}" ]; then
    return ${COM_RESULT_SUCCESSED}
  fi

  echo " ${_error} ${_log}">&2
  line_log
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# コマンドログ
# [Arguments] 
# - ログ
# [Return]
# - 正常終了
# ----------------------------------------------------------------
command_log(){
  local _log="$1"
  if [ -z "${_log}" ]; then
    return ${COM_RESULT_SUCCESSED}
  fi

  echo "  [${_log}...]"
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# コマンド完了ログ
# [Return]
# - 正常終了
# ----------------------------------------------------------------
command_end_log(){
  echo "  [done.]"
  echo ""
  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# 存在チェック
# [Arguments] 
# - ファイル名 or ディレクトリ名
# [Return]
# - 0: 存在チェックOK
# - 1: 存在チェックNG
# ----------------------------------------------------------------
exists(){
  local _target=$1

  if [ ! -e "${_target}" ]; then
    error_log "[${_target} is not exists.]"
    return ${COM_RESULT_FAILED}
  fi

  return ${COM_RESULT_SUCCESSED}
}

# ----------------------------------------------------------------
# データ有無チェック
# [Arguments] 
# - データ
# [Return]
# - 0: あり
# - 1: なし
# ----------------------------------------------------------------
isData(){
  local _target=$1

  if [ -z "${_target}" ]; then
    error_log "[${_target} in not values.]"
    return ${COM_RESULT_FAILED}
  fi

  return ${COM_RESULT_SUCCESSED}
}
