#!/bin/bash

MESSAGE=''

#Check the stuff
  [ "$1" == "" ] && ! MESSAGE="$MESSAGE First argument must be a video URL\n"                         #Needs a youtube link 
  [ "$2" == "" ] && ! MESSAGE="$MESSAGE Second argument must be a time start 00:00:00\n"              #Needs a time start
  [ "$3" == "" ] && ! MESSAGE="$MESSAGE Third argument must be the length from the point 00:00:00\n"  #Needs how many time to extract

#printf "$MESSAGE"

#If is DEAD is DEAD
  [ "$MESSAGE" != "" ] && ! printf "$MESSAGE"
  [ "$MESSAGE" != "" ] && ! exit 

#Handle Audio and Video URL Streams
  LINKS=`youtube-dl -g $1`
  FIRST=`echo $LINKS | cut -d' ' -f1`
  SECOND=`echo $LINKS | cut -d' ' -f2`

#Handle filename
  FILENAME=$4
  [ "$4" == "" ] && ! FILENAME=`youtube-dl -e $1`".mp4" #If no name defined, get the video name
  FILENAME=`echo $FILENAME | sed s/\ /_/g`        #No spaces on the filename

#Do the download
  ffmpeg -ss $2 -i "$FIRST" -t $3 -ss $2 -i "$SECOND" -t $3 -c copy -c:a aac $FILENAME
