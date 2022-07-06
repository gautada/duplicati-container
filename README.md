# duplicity-container

[Duplicity](https://duplicity.gitlab.io) backs directories by producing encrypted tar-format volumes and uploading them to a remote or local file server. Because duplicity uses librsync, the incremental archives are space efficient and only record the parts of files that have changed since the last backup. Because duplicity uses GnuPG to encrypt and/or sign these archives, they will be safe from spying and/or modification by the server.

*Note:* This container originally was going to be implemented using [Duplicati](https://www.duplicati.com) that idea was dropped due to the difficulty in implementing mono from source.

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
  
  
  

