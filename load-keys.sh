#!/bin/ash

if [ -z $DUPLICITY_ENCRYPTER_FINGERPRINT ] ; then
 /bin/echo "Encrypter Fingerprint Not Found"
 return 1
fi
ENCRYPTER_KEY_FILE="/mnt/volumes/configmaps/$(/bin/echo $DUPLICITY_ENCRYPTER_FINGERPRINT).key"
# /bin/echo $ENCRYPTER_PUBLIC_KEY
if [ ! -f $ENCRYPTER_KEY_FILE ] ; then
 /bin/echo "Encrypter public key not found"
 return 2
fi
FILE_FINGERPRINT="$(/usr/bin/gpg --show-keys $ENCRYPTER_KEY_FILE | sed -n '2p' | xargs)"
if [ "$DUPLICITY_ENCRYPTER_FINGERPRINT" != "$FILE_FINGERPRINT" ] ; then
 /bin/echo "Configured fingerprint[$DUPLICITY_ENCRYPTER_FINGERPRINT] and provided file fingerprint[$FILE_FINGERPRINT] do not match"
 return 3
fi
/usr/bin/gpg --batch --trusted-key $DUPLICITY_ENCRYPTER_FINGERPRINT --import  $ENCRYPTER_KEY_FILE
/bin/echo "trusted-db $DUPLICITY_ENCRYPTER_FINGERPRINT" >> $HOME/.gnupg/gpg.conf

if [ -z $DUPLICITY_SIGNER_FINGERPRINT ] ; then
 /bin/echo "Signer Fingerprint Not Found skipping signer key load"
else
 SIGNER_PKEY_FILE="/mnt/volumes/configmaps/$(/bin/echo $DUPLICITY_SIGNER_FINGERPRINT).pkey"
 if [ ! -f $SIGNER_PKEY_FILE ] ; then
  /bin/echo "Signer public key not found"
  return 4
 fi 
 SIGNER_FILE_FINGERPRINT="$(/usr/bin/gpg --show-keys $SIGNER_PKEY_FILE | sed -n '2p' | xargs)"
 if [ "$DUPLICITY_SIGNER_FINGERPRINT" != "$SIGNER_FILE_FINGERPRINT" ] ; then
  /bin/echo "Configured fingerprint[$DUPLICITY_ENCRYPTER_FINGERPRINT] and provided file fingerprint[$SIGNER_FILE_FINGERPRINT] do not match"
  return 5
 fi
 /bin/echo $DUPLICITY_SIGNER_PASSPHRASE | /usr/bin/gpg --passphrase-fd 0 --batch --trusted-key $DUPLICITY_SIGNER_FINGERPRINT --import $SIGNER_PKEY_FILE
 /bin/echo "trusted-db $DUPLICITY_SIGNER_FINGERPRINT" >> $HOME/.gnupg/gpg.conf
fi

/usr/bin/gpg --list-keys


#!/bin/sh

# Specify the directory you want to iterate over
directory="/mnt/volumes/backup"

# Use find to get a list of all directories in the specified directory
# The -type d option ensures that only directories are selected
for folder in $(find "$directory" -mindepth 1 -type d); do
 FULLPATH=$folder
 FOLDER=$(basename $FULLPATH)
	echo "Processing folder: $FOLDER @ $FULLPATH"
	ls -rt "$FULLPATH" | while read -r file; do
		echo " --- Processing file: $file"
		# Add your logic or commands for each file here
	done
done