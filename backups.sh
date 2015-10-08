#!/bin/bash

source /pgenv.sh

#echo "Running with these environment options" >> /var/log/cron.log

MYDATE=`date +%d-%B-%Y`
MONTH=$(date +%B)
YEAR=$(date +%Y)
MYBASEDIR=/backups
MYBACKUPDIR=${MYBASEDIR}/${YEAR}/${MONTH}
mkdir -p ${MYBACKUPDIR}
cd ${MYBACKUPDIR}

echo "Backup running to $MYBACKUPDIR" >> /var/log/cron.log


echo "Backing up $TARGET_FOLDER"  >> /var/log/cron.log
FILENAME=${MYBACKUPDIR}/${DUMPPREFIX}.${MYDATE}.tar.gz
tar -zcvf ${FILENAME} ${TARGET_FOLDER}/*
echo "push backup to remote server" >> /var/log/cron.log
/usr/bin/python /sftp_remote.py ${FILENAME} >> /var/log/cron.log

