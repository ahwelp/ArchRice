#  _______          ____  __ 
# |  __ \ \        / /  \/  |   Status bar generator
# | |  | \ \  /\  / /| \  / |
# | |  | |\ \/  \/ / | |\/| |
# | |__| | \  /\  /  | |  | |
# |_____/   \/  \/   |_|  |_|
#


#Calculate Battery
  for bat in /sys/class/power_supply/BAT?
  do
    charge=$charge`cat $bat/capacity`"%"
  done

#Calculate Free RAM
  ram=`free -h | grep 'Mem' | sed -n 's/ \+/ /gp' | cut -d' ' -f6`

#Search for date/time
  datetime=`date +"%d/%m/%Y %a %T"`

#Core Temperature
  coretemp=`sensors | grep 'Core' | awk 'NR==1' | sed -n 's/ \+/ /gp' | cut -d' ' -f3 | sed s/\+//`

#PingTime
  ms=`ping 1.1.1.1 -c1 -W 0.5 | awk 'NR==2' | cut -d' ' -f 7 | cut -d'=' -f2`

#Free space
  freespace=`df -h | grep '/$' | sed -n 's/ \+/ /gp' | cut -d' ' -f4`

#Build Header Content
  string="$ms ms|$freespace|$coretemp|$ram|$charge|$datetime"

#Eval content 
  xsetroot -name "$string"
