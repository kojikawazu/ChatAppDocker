#!/bin/bash
# -------------------------------------------------------------------------------------
#
# Tomcatコンテナ起動実行
#
# since: 2023/02/07
#
# -------------------------------------------------------------------------------------

# ------------------------------------------------------------------
# Constants settings
# ------------------------------------------------------------------
readonly CATALINA_HOME=/var/tomcat
readonly TOMCAT_NAME=tomcat

readonly OPERATION_ENABLE=enable

# ------------------------------------------------------------------
# Logic
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Tomcatの有効化
# ------------------------------------------------------------------
tomcat_enable(){
  local _is_enable=""
  _is_enable=$(/usr/bin/systemctl list-unit-files --type=service | \
                    /bin/grep tomcat | \
                    /bin/awk '{print $2}')

  if [ "_is_enable" != "${OPERATION_ENABLE}" ]; then
    /usr/bin/systemctl ${OPERATION_ENABLE} ${TOMCAT_NAME}
    /usr/bin/systemctl list-unit-files --type=service | grep tomcat
    echo " successed ${OPERATION_ENABLE} ${TOMCAT_NAME} service."
  else
    echo " already ${OPERATION_ENABLE} ${TOMCAT_NAME} service."
  fi

  echo ""
}

# ------------------------------------------------------------------
# systemdの起動
# ------------------------------------------------------------------
start_systemd(){
  exec /usr/sbin/init
  echo " successed start init."
  echo ""
}

# ------------------------------------------------------------------
# Main関数
# ------------------------------------------------------------------
main(){
  # Tomcatの有効化
  tomcat_enable
  # systemdの起動
  start_systemd
}

main "$@"
exit "$?"
