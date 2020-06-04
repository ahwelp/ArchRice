cd ~/.config/pcInfo/

#Calculate Battery
  for bat in /sys/class/power_supply/BAT?
  do
    charge=$charge`cat $bat/capacity`"%|"
  done

#Calculate Free RAM
  ram=`cat /proc/meminfo | grep MemFree | sed s/\ //g | sed s/kB//g | cut -d ':' -f 2`
  ram=$((ram / 1024))
  ram="RAM:$ram MB"

#Search for date/time
  datetime=`date +"%d/%m/%Y %a %T"`

string="$ram|$charge$datetime"
string="xsetroot -name '"$string" '"

eval $string

