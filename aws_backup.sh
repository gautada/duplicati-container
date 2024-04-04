#!/bin/sh

# echo "$AWS_ACCESS_KEY"
# echo "$AWS_SECRET_ACCESS_KEY"

export PASSPHRASE=$DUPLICITY_ENCRYPTER_PASSWORD
export SIGN_PASSPHRASE=$DUPLICITY_SIGNER_PASSWORD

OLDER_THAN="1h"

MONTH_NUM="$(/bin/date +%m)"
MONTH_NAME="$(date +%b)"
DAY="$(/bin/date +%d)"

DESTINATION="s3://duplicity.gautier.org/$MONTH_NUM-$MONTH_NAME/"
echo "$DESTINATION"

# is_running=$(ps -ef | grep duplicity  | grep python | wc -l)


/usr/bin/duplicity remove-older-than ${OLDER_THAN} ${DESTINATION}
#  >> ${DAILYLOGFILE} 2>&1

/usr/bin/duplicity \
 --archive-dir $HOME/tmp \
 --encrypt-key $DUPLICITY_ENCRYPTER_FINGERPRINT \
 --sign-key $DUPLICITY_SIGNER_FINGERPRINT \
 --verbosity d $HOME/test $DESTINATION