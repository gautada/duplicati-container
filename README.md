# duplicity

[Duplicity](https://duplicity.gitlab.io) backs directories by producing encrypted tar-format volumes and uploading them 
to a remote or local file server. Because duplicity uses librsync, the incremental archives are space efficient and only 
record the parts of files that have changed since the last backup. Because duplicity uses GnuPG to encrypt and/or sign 
these archives, they will be safe from spying and/or modification by the server.

https://gock.net/blog/2020/gpg-cheat-sheet

https://easyengine.io/tutorials/backups/duplicity-amazon-s3/

## Commands

List keys
```
/usr/bin/gpg --list-keys
```

Time formats
```
Time Formats

duplicity uses time strings in two places. Firstly, many of the files duplicity creates will have the time in their filenames in the w3 datetime format as described in a w3 note at http://www.w3.org/TR/NOTE-datetime. Basically they look like "2001-07-15T04:09:38-07:00", which means what it looks like. The "-07:00" section means the time zone is 7 hours behind UTC.
Secondly, the -t, --time, and --restore-time options take a time string, which can be given in any of several formats:

1.
the string "now" (refers to the current time)
2.
a sequences of digits, like "123456890" (indicating the time in seconds after the epoch)
3.
A string like "2002-01-25T07:00:00+02:00" in datetime format
4.
An interval, which is a number followed by one of the characters s, m, h, D, W, M, or Y (indicating seconds, minutes, hours, days, weeks, months, or years respectively), or a series of such pairs. In this case the string refers to the time that preceded the current time by the length of the interval. For instance, "1h78m" indicates the time that was one hour and 78 minutes ago. The calendar here is unsophisticated: a month is always 30 days, a year is always 365 days, and a day is always 86400 seconds.
5.
A date format of the form YYYY/MM/DD, YYYY-MM-DD, MM/DD/YYYY, or MM-DD-YYYY, which indicates midnight on the day in question, relative to the current time zone settings. For instance, "2002/3/5", "03-05-2002", and "2002-3-05" all mean March 5th, 2002.
```


## Setup

### AWS Setup

Create an S3 Bucket to hold duplicity archives. Because bucket names must be unique globally a FQDN like `duplicity.fqdn.tld` 
should probably be used. Next create an IAM user for CLI access and make sure the user has the permissions 
`arn:aws:iam::aws:policy/AmazonS3FullAccess` either directly or through a user group.

Check that credentials are available through credentials file or environment variables - Check login using boto3. `aws_test.py`



The duplicity container is designed to push the backup files outside of the local environment and therefore must be both encrypted and signed in order to guarantee data security. Two password protected public-private key sets must be generated using `gpg` in development (or independently) then provided to the production environment.

**Encrypter** - This key set is used to encrypt the backup.  The container will use the public key to encrypt the data which can only be unlocked using the private key. The private key should be protected with a very strong password which is stored separately from the container.

**Signer** - This is used to verify that the file was created with access to the private key (which is obviously limited).  This does not guarantee data integrity only that the backup files were generated using the signer private key.

### Key Generation

This will need to be run for both the **Encrypter** and **Signer** key sets.

```
/usr/bin/gpg --generate-key

```

Interactive Responses:
- **Real Name**: `Duplicity Backup Encrypter` or `Duplicity Backup Signer`
- **Email address**: `duplicity-backup-`**[encrypter|signer]**`@example.com`
- **Change (N)ame, (E)mail, or (O)kay/(Q)uit?**: `O`
- **Password**: (Paste from password manager)

Note the following:
- **Fingerprint**: 40 character hexidecimal code (add to password manager)
- **Expiration**: If you want unlimited expiration use `--full-generate-key` (add to password manager)

### Export Keys

All of the keys should be exported so that they may be deployed in production.  Two variables must be set:
- **Name**`-a "..."`: Should be set to `Duplicity Backup `[Encrypter|Signer]
- **File**: should be set to [encrypter|signer]`.[p]key`
 
```
rXjqDkxCj2wYYeNVYivbBUTdiYZXGjw4mK6kuYiiWBbPK7ToqRCAeYCR4FKDwt48MyrtuV3wo6NkPghxQQuCDecTbHFNEsioHbT2
/usr/bin/gpg --export-secret-key -a "Duplicity Backup Encrypter" > /mnt/volumes/container/encrypter.pkey
```

The exported files should be attached to the password credentials in a a password manager. Also note the private will require the password to be provided in order to export.

### Import Keys

For valid operation only the Encrypter Public Key `encrypter.key` is required. The container will attempt to import this key automatically. Below are the manual operations for import.

**Import public key**
```
/usr/bin/gpg --import /mnt/volumes/container/encrypter.key
```

For optional but reccomended signing of backups you will need to import `signer.key` and `signer.pkey`

**Import private key**
```
gpg --allow-secret-key-import --import /mnt/volumes/container/encrypter.key
```

Note that to decrypt a backup the `encrypter.pkey` must be imported manually.

**Trust the imported key**
The above imports provide an unknown key to the gpg keychain. To make sure the key is trusted set the fingerprint to trusted-key in the `~/.gnupg/gpg.conf`

```
/bin/echo "trusted-key $DUPLICITY_ENCRYPTER_FINGERPRINT" >> ~/.gnupg/gpg.conf
```

## Backup

```
/usr/bin/duplicity --encrypt-key 63A2C4C45BE268B17DACBFE2BCA1D3415F896321 /mnt/volumes/configmaps file:///home/duplicity/backup
```


![Component Diagram](https://puml.gautier.org/plantuml/png/dLDRQzim57xthr3DO0duyfAdCHPMEzqUqgqqZ3wC4HHPjKLqGpxEQhByzyftEqqsM5uidVDTT3ufDqmINYGKVOmMORG8T27u9-TcMjr6IW9zWRzqCPFKNEqBhIILr_XnAR5Wv5gNQgvACT2TzwWzZrtvpS-kZfio1oh-h6pBQCDokZtTga8cs9Gpp1dEFSJnZd8F7PTGQdhoq19mQillE9FxkTLue2PNyhXTlS3fZBDCQ4wC_UPM6-XRRcF_Fznse3h2OQHwgBv-hWYKPFBVfwebslJVIBVrLZe8WeRmI3a6fcIUCJtcD3JRdO7oqBDHmaErVKFx6ItG0ySIVjolVyqo09r_24DTLUor-JaadEs2b45Mx0AcxDNw7Joq6G03Jf7Rdmh53AS62-IZkD2S4GQbwpZzZRgaYyRrAbgtcQEZCvhDVIuagQQPeD0j9lj2exjHCwH0mbuqtDK8T-wWmH9pRNiLk5dvP6exzXLOuhGvN6jstrJGXXYceROiScl4v63h3xPZiQHFmB8ccrvYg9vnKvrMm5GMpQ9dL0sBFJadfuV7kvdxMvbz1NooNoPJTATuqWmIWj13C1CImIIhaucg1LehWljW3zXSOTdd0qpso7ZOJXM4XF2WU25eFYWvrLCSvzmTlAPIYpW7JDu2vlm2P1Bk63FcTaQHqcNNdn0xm2F5oKL07zTdGp9se1T1P-dOVmkfW8wp-VhzQRjUVLbzYsVpLm00)

https://puml.gautier.org/plantuml/png/dLFBZjCm5DtdApmH4gsKn9kk4A9YaWuiEZ2Q2iq2eSfrF8bLnxPifqme_NUSbvDqMf38njVtddFkoxcX7BCo9U1zl83n8f9bmJvuDrFlDXRSa1VpboYYdAYhyK8AJlWrVb9nL51yBKea4rKnqBsteAl7Mc7xMUkugRGXnU-L3Icfg2RRqwqeUOfKDKEC8Xq0XdQ41U2uD9Kafm0i3Sgi-msZV3-t6Wz4QS6FszMBEPrnbYdHMDbJMsr3NdFRzF_3xHfgHZYqr3Jb_EUAXk2S_xkgHgAR_Ylfpjz9Hr7K4Xu9GuOAhdCgnvoMPgCp8mBmh4GHW2PzI_iUBy03Gznykr__cEN6IFqEGbbxxDf2RL96Tr56JLxk8YhiQiCU3kqC33MC0DzL1HAACeKA48Aab8nYQYhVyzn6VToFnWzgMd-PWwCtwir_BZckkvcWm2t2-rA2kr4G4eEX4uMx1k7FFJ2aH4pQM0rkhH1FquxpOYLuMaET0KkjeDvH3blNV4ee44TPsqrNtNth0Hkig3HEeb7e4uT3dMEnr8tCiYON9p5upxYPp6fWnilMS8mwOB6dALnN7DUmZJrpsnZzHTAhYKwUOoQxcVzJg7sDVR8dvHcu4onjHm1D8OSTJ4WOuRnPGbmRO2qmSZiy87M5PL-geTmXa-4wLIYuWGV1oeBeGSchN_ruGttX3PLOn3bWykmGOnSWaxMCCMDkdoWMikhZ4s8FU2GelGXmu_geS4uFv2BeR3hsnyJ4zUrUi5krLKnBrY2ypUUlJzlrwjFgIpAR_m40
    
## Restore

```
gpg --trusted-key $(gpg --show-keys /opt/backup/decryption.key  | sed -n '2p' | xargs) --import /opt/backup/decryption.key
duplicity restore --archive-dir /tmp/backup file:///opt/backup /var/backup
```


[GPG Documentation](https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration-Options.html)
```
gpg --trusted-key $BACKUP_KEY --import /opt/duplicity/testkey.pkey
```

gpg --trusted-key F637FEA3CEFBF0B21DBEE9E6585A99256A092267 --import /opt/duplicity/testkey.pkey
 duplicity full --encrypt-key F637FEA3CEFBF0B21DBEE9E6585A99256A092267  --archive-dir /etc file:///opt/duplicity
```
duplicity full --encrypt-key <key-id> /var/backup file:///opt/backup
```

[duplicity](https://linux.die.net/man/1/duplicity)

## Working directory
`/var/backup `

## Destination directory
`/opt/backup` which should be mounted via nfs from nfs:///<ip>/nas/volumes/duplicity/<container>

Usage: 
  
### Full
duplicity full --encrypt-key <id> --name daily --dry-run /var/backup file:///opt/backup/alpine
  
  
## Notes

- This container originally was going to be implemented using [Duplicati](https://www.duplicati.com) that idea was dropped due to the difficulty in implementing mono from source.
- The container uses the [distro pacakge for duplicity](https://pkgs.alpinelinux.org/packages?name=duplicity&branch=edge&repo=&arch=&maintainer=) use the package db for version.
- 2024-02-02: References [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-use-duplicity-with-gpg-to-securely-automate-backups-on-ubuntu) and [How to install and use Duplicity to Automate Backups](https://www.webhi.com/how-to/setup-use-duplicity-automatic-backups/)
- 2024-02-05: FF




