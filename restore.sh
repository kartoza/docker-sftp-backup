#!/bin/bash

source /env.sh

echo "This will overwrite target folder."

BACKUP_LOCATION=$1

echo "Backup file used: $BACKUP_LOCATION"

echo "Restoring into ${TARGET_FOLDER}"
echo "Cleaning ${TARGET_FOLDER}"
rm -rf ${TARGET_FOLDER}/*
tar -xf ${BACKUP_LOCATION} -C ${TARGET_FOLDER}

echo "Restore finished"
