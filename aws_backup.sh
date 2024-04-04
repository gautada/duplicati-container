#!/bin/sh

echo "$AWS_ACCESS_KEY"
echo "$AWS_SECRET_ACCESS_KEY"

OLDER_THAN="3M"

MONTH_NUM="$(/bin/date +%m)"
MONTH_NAME="$(date +%b)"
DAY="$(/bin/date +%d)"

DESTINATION="s3://duplicity.gautier.org/$MONTH_NUM-$MONTH_NAME/"
echo "$DESTINATION"

is_running=$(ps -ef | grep duplicity  | grep python | wc -l)


/usr/bin/duplicity remove-older-than ${OLDER_THAN} ${DESTINATION}
#  >> ${DAILYLOGFILE} 2>&1