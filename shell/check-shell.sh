if [ "$(ps h -o comm -p "$PPID")" != "sshd" ] ; then 
  echo "This script can only be run directly from ssh." > /dev/stderr
  exit 1
else
  echo "This script is running directly from ssh."
  exit 1
fi