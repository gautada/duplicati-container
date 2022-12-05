# duplicity-container

[Duplicity](https://duplicity.gitlab.io) backs directories by producing encrypted tar-format volumes and uploading them to a remote or local file server. Because duplicity uses librsync, the incremental archives are space efficient and only record the parts of files that have changed since the last backup. Because duplicity uses GnuPG to encrypt and/or sign these archives, they will be safe from spying and/or modification by the server.


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
