cd ~/.config/pcInfo/
#bat1=`./batCapacity1.sh`
#bat0=`./batCapacity2.sh`

for bat in /sys/class/power_supply/BAT?
do
  charge=$charge`cat $bat/capacity`"% "
done

datetime=`date +"%d/%m/%Y %T"`

string=$charge
string="xsetroot -name '"$string" "$datetime"'"

eval $string

