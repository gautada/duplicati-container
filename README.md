# duplicati-container
A duplicati container

https://www.duplicati.com

https://github.com/duplicati/duplicati

https://github.com/hydazz/docker-duplicati



## Working directory
`/var/backup `

## Destination directory
`/opt/backup` which should be mounted via nfs from nfs:///<ip>/nas/volumes/duplicity/<container>

Usage: 
  
### Full
duplicity full --encrypt-key <id> --name daily --dry-run /var/backup file:///opt/backup/alpine
  
  
  
