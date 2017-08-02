#!/bin/bash
# define protected DMZ to exclude for auto-adding key
DMZSN=129.168.100.
# threshold to email Warnings
WARN=0
# threshold to email Suggestions
SUGG=38
# find lynis executable or if not installed
if [[ -x "/usr/sbin/lynis" ]]; then
  LYNIS="/usr/sbin/lynis"
  LYNIS_DIR="/usr/share/lynis"
elif [[ -x "/usr/local/lynis/lynis" ]]; then
  LYNIS="/usr/local/lynis/lynis"
  LYNIS_DIR="/usr/local/lynis"
elif [[ -x "/usr/bin/lynis" ]]; then
  LYNIS="/usr/bin/lynis"
  LYNIS_DIR="/usr/share/lynis"
else
  dmz=$(ifconfig | grep -Fc $DMZSN)
  if [ "$dmz" -eq 0 ] && [ -x /usr/bin/apt-key ]; then
    apt-key adv --list-public-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F 2>&1 > /dev/null
    st=$?
    if [ "$st" -ne 0 ]; then
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
    fi
  fi
  echo "${0}: lynis not installed"
  exit 1
fi
AUDITOR="automated"
DATE=$(date +%Y%m%d)
HOST=$(hostname -s)
LOG_DIR="/var/log/lynis"
REPORT="$LOG_DIR/report-${HOST}.${DATE}"
DATA="$LOG_DIR/report-data-${HOST}.${DATE}.txt"
if [[ ! -d "$LOG_DIR" ]]; then
  mkdir $LOG_DIR
fi
cd $LYNIS_DIR

# Run Lynis
$LYNIS audit system --auditor "${AUDITOR}" --cronjob > ${REPORT}
# Optional step: Move report file if it exists
if [ -f /var/log/lynis-report.dat ]; then
    mv /var/log/lynis-report.dat ${DATA}
fi
w=$(grep -c Warnings $REPORT)
if [ "$w" -gt 0 ]; then
  w=$(grep Warnings $REPORT | awk '{split($2,a,")"); print substr(a[1],2)}')
  if [ "$w" -gt "$WARN" ]; then
    sed -n '/^  Warnings/,/^  Suggestions/p' $REPORT | grep -Fv "  Suggestions"
    exit $w
  fi
fi
s=$(grep -c Suggestions $REPORT)
if [ "$s" -gt 0 ]; then
  s=$(grep Suggestions $REPORT | awk '{split($2,a,")"); print substr(a[1],2)}')
  if [ "$s" -gt "$SUGG" ]; then
    sed -n '/^  Suggestions/,/^========/p' $REPORT | grep -Fv "========"
    exit $s
  fi
fi

# The End
