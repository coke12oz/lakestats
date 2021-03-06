#!/bin/bash

############################
#
# Parameters to adjust
#
############################
RRDPATH="/opt/lakestats/data/"
IMGPATH="/opt/lakestats/img"
RRDFILE="lake.rrd"
LAT="32.0527N"
LON="95.5063W"

# Graph Colors
RAWCOLOUR="#FF9933"
RAWCOLOUR2="#0000FF"
RAWCOLOUR3="#336699"
RAWCOLOUR4="#006600"
RAWCOLOUR5="#000000"
TRENDCOLOUR="#FFFF00"

# Calculating Civil Twilight based on location from LAT LON
DUSKHR=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 45-46`
DUSKMIN=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 47-48`
DAWNHR=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 30-31`
DAWNMIN=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun rises/{:a;n;/Nautical twilight/b;p;ba}' | cut -c 32-33`

# Calculating sunset/sunrise based on location from LAT LON
SUNRISEHR=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 30-31`
SUNRISEMIN=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 32-33`
SUNSETHR=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 45-46`
SUNSETMIN=`/usr/bin/sunwait sun up $LAT $LON -p | sed -n '/Sun transits/{:a;n;/Civil twilight/b;p;ba}' | cut -c 47-48`

# Converting to seconds
SUNR=$(($SUNRISEHR * 3600 + $SUNRISEMIN * 60))
SUNS=$(($SUNSETHR * 3600 + $SUNSETMIN * 60))
DUSK=$(($DUSKHR * 3600 + $DUSKMIN * 60))
DAWN=$(($DAWNHR * 3600 + $DAWNMIN * 60))

############################
#
# Creating graphs
#
############################
#hour
rrdtool graph $IMGPATH/hour.png --start -6h --end now \
-v "Last 6 hours (°F)" \
--full-size-mode \
--width=700 --height=400 \
--slope-mode \
--color=SHADEB#9999CC \
--watermark="© Dan Shnowske - 2016" \
DEF:temp1=$RRDPATH/$RRDFILE:b:AVERAGE \
DEF:temp2=$RRDPATH/$RRDFILE:d:AVERAGE \
DEF:temp3=$RRDPATH/$RRDFILE:c:AVERAGE \
DEF:temp4=$RRDPATH/$RRDFILE:e:AVERAGE \
DEF:temp5=$RRDPATH/$RRDFILE:a:AVERAGE \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:dusktilldawn#CCCCCC \
AREA:dawntilldusk#CCCCCC \
COMMENT:"  Location         Last        Avg\l" \
LINE2:temp2$RAWCOLOUR2:"Outside(Air)" \
GPRINT:temp2:LAST:"%5.1lf °F" \
GPRINT:temp2:AVERAGE:"%5.1lf °F\l" \
LINE2:temp4$RAWCOLOUR4:"Humidity    " \
GPRINT:temp4:LAST:"%5.1lf  %%" \
GPRINT:temp4:AVERAGE:"%5.1lf  %%\l" \
COMMENT:"\t\t\t\t\t\t---------------------------\l" \
LINE1:temp5$RAWCOLOUR5:"Surface      " \
GPRINT:temp5:LAST:"%5.1lf °F" \
GPRINT:temp5:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Dawn\:    $DAWNHR\:$DAWNMIN\r" \
LINE1:temp1$RAWCOLOUR:"3 feet       " \
GPRINT:temp1:LAST:"%5.1lf °F" \
GPRINT:temp1:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunrise\: $SUNRISEHR\:$SUNRISEMIN\r" \
LINE1:temp3$RAWCOLOUR3:"6 feet       " \
GPRINT:temp3:LAST:"%5.1lf °F" \
GPRINT:temp3:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunset\:  $SUNSETHR\:$SUNSETMIN\r" \
HRULE:0#66CCFF:"freezing\l" \
COMMENT:"\u" \
COMMENT:"Dusk\:    $DUSKHR\:$DUSKMIN\r" 

#day
rrdtool graph $IMGPATH/day.png --start -1d --end now \
-v "Last day (°F)" \
--full-size-mode \
--width=700 --height=400 \
--slope-mode \
--color=SHADEA#9999CC \
--watermark="© Dan Shnowske - 2016" \
DEF:temp1=$RRDPATH/$RRDFILE:b:AVERAGE \
DEF:temp2=$RRDPATH/$RRDFILE:d:AVERAGE \
DEF:temp3=$RRDPATH/$RRDFILE:c:AVERAGE \
DEF:temp4=$RRDPATH/$RRDFILE:e:AVERAGE \
DEF:temp5=$RRDPATH/$RRDFILE:a:AVERAGE \
CDEF:trend1=temp4,21600,TREND \
CDEF:trend2=temp5,21600,TREND \
CDEF:trend3=temp1,21600,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:dusktilldawn#CCCCCC \
AREA:dawntilldusk#CCCCCC \
COMMENT:"  Location         Last        Avg\l" \
LINE2:temp2$RAWCOLOUR2:"Outside(Air)" \
GPRINT:temp2:LAST:"%5.1lf °F" \
GPRINT:temp2:AVERAGE:"%5.1lf °F\l" \
LINE2:temp4$RAWCOLOUR4:"Humidity    " \
GPRINT:temp4:LAST:"%5.1lf  %%" \
GPRINT:temp4:AVERAGE:"%5.1lf  %%\l" \
COMMENT:"\t\t\t\t\t\t---------------------------\l" \
LINE1:temp5$RAWCOLOUR5:"Surface      " \
GPRINT:temp5:LAST:"%5.1lf °F" \
GPRINT:temp5:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Dawn\:    $DAWNHR\:$DAWNMIN\r" \
LINE1:temp1$RAWCOLOUR:"3 feet       " \
GPRINT:temp1:LAST:"%5.1lf °F" \
GPRINT:temp1:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunrise\: $SUNRISEHR\:$SUNRISEMIN\r" \
LINE1:temp3$RAWCOLOUR3:"6 feet       " \
GPRINT:temp3:LAST:"%5.1lf °F" \
GPRINT:temp3:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunset\:  $SUNSETHR\:$SUNSETMIN\r" \
HRULE:0#66CCFF:"freezing\l" \
COMMENT:"\u" \
COMMENT:"Dusk\:    $DUSKHR\:$DUSKMIN\r"

#week
rrdtool graph $IMGPATH/week.png --start -1w \
--full-size-mode \
-v "Last week (°F)" \
--width=700 --height=400 \
--slope-mode \
--color=SHADEB#9999CC \
--watermark="© Dan Shnowske - 2016" \
DEF:temp1=$RRDPATH/$RRDFILE:b:AVERAGE \
DEF:temp2=$RRDPATH/$RRDFILE:d:AVERAGE \
DEF:temp3=$RRDPATH/$RRDFILE:c:AVERAGE \
DEF:temp4=$RRDPATH/$RRDFILE:e:AVERAGE \
DEF:temp5=$RRDPATH/$RRDFILE:a:AVERAGE \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:nightplus#E0E0E0 \
AREA:nightminus#E0E0E0 \
CDEF:dusktilldawn=LTIME,86400,%,$DAWN,LT,INF,LTIME,86400,%,$DUSK,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:dawntilldusk=LTIME,86400,%,$DAWN,LT,NEGINF,LTIME,86400,%,$DUSK,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:dusktilldawn#CCCCCC \
AREA:dawntilldusk#CCCCCC \
COMMENT:"  Location         Last        Avg\l" \
LINE2:temp2$RAWCOLOUR2:"Outside(Air)" \
GPRINT:temp2:LAST:"%5.1lf °F" \
GPRINT:temp2:AVERAGE:"%5.1lf °F\l" \
LINE2:temp4$RAWCOLOUR4:"Humidity    " \
GPRINT:temp4:LAST:"%5.1lf  %%" \
GPRINT:temp4:AVERAGE:"%5.1lf  %%\l" \
COMMENT:"\t\t\t\t\t\t---------------------------\l" \
LINE1:temp5$RAWCOLOUR5:"Surface      " \
GPRINT:temp5:LAST:"%5.1lf °F" \
GPRINT:temp5:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Dawn\:    $DAWNHR\:$DAWNMIN\r" \
LINE1:temp1$RAWCOLOUR:"3 feet       " \
GPRINT:temp1:LAST:"%5.1lf °F" \
GPRINT:temp1:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunrise\: $SUNRISEHR\:$SUNRISEMIN\r" \
LINE1:temp3$RAWCOLOUR3:"6 feet       " \
GPRINT:temp3:LAST:"%5.1lf °F" \
GPRINT:temp3:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunset\:  $SUNSETHR\:$SUNSETMIN\r" \
HRULE:0#66CCFF:"freezing\l" \
COMMENT:"\u" \
COMMENT:"Dusk\:    $DUSKHR\:$DUSKMIN\r"

#month
rrdtool graph $IMGPATH/month.png --start -1m \
-v "Last month (°F)" \
--full-size-mode \
--width=700 --height=400 \
--slope-mode \
--color=SHADEA#9999CC \
--watermark="© Dan Shnowske - 2016" \
DEF:temp1=$RRDPATH/$RRDFILE:b:AVERAGE \
DEF:temp2=$RRDPATH/$RRDFILE:d:AVERAGE \
DEF:temp3=$RRDPATH/$RRDFILE:c:AVERAGE \
DEF:temp4=$RRDPATH/$RRDFILE:e:AVERAGE \
DEF:temp5=$RRDPATH/$RRDFILE:a:AVERAGE \
COMMENT:"  Location         Last        Avg\l" \
LINE2:temp2$RAWCOLOUR2:"Outside(Air)" \
GPRINT:temp2:LAST:"%5.1lf °F" \
GPRINT:temp2:AVERAGE:"%5.1lf °F\l" \
LINE2:temp4$RAWCOLOUR4:"Humidity    " \
GPRINT:temp4:LAST:"%5.1lf  %%" \
GPRINT:temp4:AVERAGE:"%5.1lf  %%\l" \
COMMENT:"\t\t\t\t\t\t---------------------------\l" \
LINE1:temp5$RAWCOLOUR5:"Surface      " \
GPRINT:temp5:LAST:"%5.1lf °F" \
GPRINT:temp5:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Dawn\:    $DAWNHR\:$DAWNMIN\r" \
LINE1:temp1$RAWCOLOUR:"3 feet       " \
GPRINT:temp1:LAST:"%5.1lf °F" \
GPRINT:temp1:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunrise\: $SUNRISEHR\:$SUNRISEMIN\r" \
LINE1:temp3$RAWCOLOUR3:"6 feet       " \
GPRINT:temp3:LAST:"%5.1lf °F" \
GPRINT:temp3:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunset\:  $SUNSETHR\:$SUNSETMIN\r" \
HRULE:0#66CCFF:"freezing\l" \
COMMENT:"\u" \
COMMENT:"Dusk\:    $DUSKHR\:$DUSKMIN\r"

#year
rrdtool graph $IMGPATH/year.png --start -1y \
--full-size-mode \
-v "Last year (°F)" \
--width=700 --height=400 \
--color=SHADEB#9999CC \
--slope-mode \
--watermark="© Dan Shnowske - 2016" \
DEF:temp1=$RRDPATH/$RRDFILE:b:AVERAGE \
DEF:temp2=$RRDPATH/$RRDFILE:d:AVERAGE \
DEF:temp3=$RRDPATH/$RRDFILE:c:AVERAGE \
DEF:temp4=$RRDPATH/$RRDFILE:e:AVERAGE \
DEF:temp5=$RRDPATH/$RRDFILE:a:AVERAGE \
COMMENT:"  Location         Last        Avg\l" \
LINE2:temp2$RAWCOLOUR2:"Outside(Air)" \
GPRINT:temp2:LAST:"%5.1lf °F" \
GPRINT:temp2:AVERAGE:"%5.1lf °F\l" \
LINE2:temp4$RAWCOLOUR4:"Humidity    " \
GPRINT:temp4:LAST:"%5.1lf  %%" \
GPRINT:temp4:AVERAGE:"%5.1lf  %%\l" \
COMMENT:"\t\t\t\t\t\t---------------------------\l" \
LINE1:temp5$RAWCOLOUR5:"Surface      " \
GPRINT:temp5:LAST:"%5.1lf °F" \
GPRINT:temp5:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Dawn\:    $DAWNHR\:$DAWNMIN\r" \
LINE1:temp1$RAWCOLOUR:"3 feet       " \
GPRINT:temp1:LAST:"%5.1lf °F" \
GPRINT:temp1:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunrise\: $SUNRISEHR\:$SUNRISEMIN\r" \
LINE1:temp3$RAWCOLOUR3:"6 feet       " \
GPRINT:temp3:LAST:"%5.1lf °F" \
GPRINT:temp3:AVERAGE:"%5.1lf °F\l" \
COMMENT:"\u" \
COMMENT:"Sunset\:  $SUNSETHR\:$SUNSETMIN\r" \
HRULE:0#66CCFF:"freezing\l" \
COMMENT:"\u" \
COMMENT:"Dusk\:    $DUSKHR\:$DUSKMIN\r"

#averages
rrdtool graph $IMGPATH/avg.png --start -1w \
-v "Weekly averages (°F)" \
--full-size-mode \
--width=700 --height=400 \
--slope-mode \
--color=SHADEB#9999CC \
--watermark="© Dan Shnowske - 2016" \
DEF:temp1=$RRDPATH/$RRDFILE:b:AVERAGE \
DEF:temp2=$RRDPATH/$RRDFILE:d:AVERAGE \
DEF:temp3=$RRDPATH/$RRDFILE:c:AVERAGE \
DEF:temp4=$RRDPATH/$RRDFILE:e:AVERAGE \
DEF:temp5=$RRDPATH/$RRDFILE:a:AVERAGE \
CDEF:trend1=temp4,86400,TREND \
CDEF:trend2=temp5,86400,TREND \
CDEF:trend3=temp1,86400,TREND \
CDEF:trend4=temp2,86400,TREND \
CDEF:trend5=temp3,86400,TREND \
CDEF:nightplus=LTIME,86400,%,$SUNR,LT,INF,LTIME,86400,%,$SUNS,GT,INF,UNKN,temp1,*,IF,IF \
CDEF:nightminus=LTIME,86400,%,$SUNR,LT,NEGINF,LTIME,86400,%,$SUNS,GT,NEGINF,UNKN,temp1,*,IF,IF \
AREA:nightplus#CCCCCC \
AREA:nightminus#CCCCCC \
LINE2:trend4$RAWCOLOUR2:"Outside (Air) 6h average\l" \
COMMENT:"\u" \
LINE2:trend1$RAWCOLOUR4:"Humidity average\r" \
COMMENT:"\t\t\t\t\t\t---------------------------\l" \
LINE1:trend3$RAWCOLOUR:"Surface average\l" \
COMMENT:"\u" \
LINE1:trend2$RAWCOLOUR5:"3 Feet average  \r" \
LINE1:trend5$TRENDCOLOUR:"6 Feet average\l"

DATE=$(date +"%Y%m%d_%H%M")
raspistill -q 10 -o /opt/lakestats/camera/$DATE.jpg
ln -sf /opt/lakestats/camera/$DATE.jpg /opt/lakestats/img/current.jpg
