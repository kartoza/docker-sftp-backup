#!/bin/bash

source /env.sh

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
tar -zcf ${FILENAME} ${TARGET_FOLDER}/*

# Track latest backup
ln -sf ${YEAR}/${MONTH}/${DUMPPREFIX}.${MYDATE}.tar.gz ${MYBASEDIR}/latest.tar.gz

echo "push backup to remote server" >> /var/log/cron.log
/usr/bin/python /sftp_remote.py ${FILENAME} >> /var/log/cron.log

