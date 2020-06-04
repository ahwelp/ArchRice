#!/bin/bash

# Usage: ytdlPart https://www.youtube.com/watch?v=xxxxxxxxx 00:10:00 00:01:00 video.mp4
# Download 1 minute from the video, starting from 00:10:00. So from 00:10:00 to 00:11:00

MESSAGE=''

#Check the stuff
  #Needs a youtube link 
  [ "$1" == "" ] && ! MESSAGE="$MESSAGE First argument must be a video URL\n"
  #Needs a time start
  [ "$2" == "" ] && ! MESSAGE="$MESSAGE Second argument must be a time start 00:00:00\n"
  #Needs how many time to extract
  [ "$3" == "" ] && ! MESSAGE="$MESSAGE Third argument must be the length from the point 00:00:00\n"

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
  [ "$4" == "" ] && ! FILENAME=`youtube-dl -e $1`".mkv"      #If no name defined, get the video name
  FILENAME=`echo $FILENAME | sed s/\ /_/g | sed "s/\//-/g"`  #No spaces or / on the filename

#Do the download
  ffmpeg -ss $2 -i "$FIRST" -t $3 -ss $2 -i "$SECOND" -t $3 -c copy -c:a aac $FILENAME
