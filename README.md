# duplicity-container
A duplicati container

https://www.duplicati.com

https://github.com/duplicati/duplicati

https://github.com/hydazz/docker-duplicati

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
  
  
  
