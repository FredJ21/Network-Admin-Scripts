

./cisco-cmd-ssh.pl "sho int status"

cat cisco-cmd.out | grep connected | grep -v trunk | awk -F":" '{ print $1}' | sort | uniq -c


