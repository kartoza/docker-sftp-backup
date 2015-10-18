# README under construction

# Docker SFTP Backup


A simple docker container that runs remote backup via SFTP. It is intended as
generic as possible to be chained as remote backup service. By default it will 
create a backup once per night (at 23h00)in a nicely ordered directory by 
year / month.


## Getting the image

There are various ways to get the image onto your system:


The preferred way (but using most bandwidth for the initial image) is to
get our docker trusted build like this:


```
docker pull kartoza/sftp-backup:latest
docker pull kartoza/sftp-backup:1.0
```

We highly suggest that you use a tagged image (1.00 currently available) as 
latest may change and may not successfully back up your database.


To build the image yourself without apt-cacher (also consumes more bandwidth
since deb packages need to be refetched each time you build) do:

```
docker build -t kartoza/sftp-backup .
```

If you do not wish to do a local checkout first then build directly from github.

```
git clone git://github.com/kartoza/docker-sftp-backup
```

## Run


To create a running container do:

```
docker run --name="backup" \
           --hostname="sftp-backup" \
           --env-file test_env.env \
           -v backups:/backups \
           -v target:/target_backup \
           -i -d kartoza/sftp-backup
```
           
In this example we provide two volumes, backups and target. Backups volume is
used to store local backups. Target volume is a folder of files to back up. 
Put your files that needed to be backed up in target folder. We also specify
a test environment file __test_env.env__

# Specifying environment


You can also use the following environment variables to pass a 
user name and password etc for the database connection.

## Backup specific variables

* DUMPPREFIX the prefix of the backup file created by this service defaults to
 ```backup```
* DAILY number of daily backups to keep, defaults to : 7
* MONTHLY number of monthly backups to keep, defaults to : 12
* YEARLY number of yearly backups to keep, defaults to : 3

Daily, Monthly and Yearly environment variables are used to specify the 
frequency of backups to keep. For example, 7 Daily backups means the service
will keep 7 latest daily backups. 12 Monthly backups means the service will keep
12 latest monthly backups, with each backup is created at the first date each 
month. Similarly, yearly backup is created at 1st January each year.

## Remote backup connection variables

### SFTP

* USE_SFTP_BACKUP defaults to False. If set to True, it means the service will try to
  push the backup files to a remote sftp server
* SFTP_HOST should be set to IP address or domain name of SFTP server
* SFTP_USER should be set to relevant SFTP user
* SFTP_PASSWORD should be set to relevant SFTP password
* SFTP_DIR should be set to the default working directory that the backup will
  be stored into (in the SFTP server)

Example usage:

```
docker run -e USE_SFTP_BACKUP=True -e SFTP_HOST=localhost -e SFTP_USER=user -e SFTP_PASSWORD=secret -e SFTP_DIR=/ -i -d kartoza/sftp-backup
```

Here is a more typical example using docker-composer (formerly known as fig):

For ``docker-compose.yml``:

```
sftpbackup:
  image: kartoza/sftp-backup
  hostname: sftp-backup
  volumes:
    - ./backups:/backups
    - ./target:/target
  environment:
    - USE_SFTP_BACKUP=True
    - SFTP_DIR=/
  env_file:
    # Credential is stored in external file to make sure it's not
    # commited into git
    - sftp_credential.env
```

Then run using:

```
docker-compose up -d sftpbackup
```

# Remote backup connection

Sometimes we need to mirrors our local backup to another backup server. For
now, the means is supported via SFTP connection. By specifying SFTP related
environment variables, sftp-backup will try to copy new backup to specified
remote server and cleanup unnecessary backup files in remote server (if it is
deleted in local backup server). The service will try to make backup files
synchronized between servers.

At some times, we may want to manually force each server to resync the files.
We wrapped two additional simple commands in start.sh script:

* Push to remote SFTP. Push all local backup files to specified remote SFTP
server. If there are any conflicting backup files in remote,
it will be overwritten.
* Pull from remote SFTP. Pull all remote backup files to local directory.
Similarly if there are any conflicting local backup files, it will be
overwritten.

## Executing the command

You can directly execute the command using docker exec or run because the
command is received in start.sh script. For example, if you already have a
pg-backup container running named pg-backup:

```
docker exec sftp-backup /bin/sh -c "/start.sh push-to-remote-sftp"
```

or

```
docker exec sftp-backup /start.sh push-to-remote-sftp
```

The above command will push all local backup files in existing container
to remote sftp server.

# Credits

Tim Sutton (tim@kartoza.com)
April 2015

Rizky Maulana Nugraha (lana.pcfre@gmail.com)
October 2015
