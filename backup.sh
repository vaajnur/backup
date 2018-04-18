#!/bin/bash
PROJNAME=backupproject  #Имя проекта
CHARSET=utf8 #Кодировка базы данных (utf8)
DBNAME=new_db #Имя базы данных для резервного копирования
DBFILENAME=backup_db #Имя дампа базы данных
ARFILENAME=backuptar #Имя архива с файлами
UPLOADNAME=uploadtar 
HOST=localhost #Хост MySQL
USER=user #Имя пользователя базы данных
PASSWD=password123  #Пароль от базы данных
DATADIR='/home/d/dnkayu8j/backups'  #Путь к каталогу где будут храниться резервные копии
SRCFILES='/home/d/dnkayu8j/mebelev.net/public_html/'  #Путь к каталогу файлов для архивирования
UPLOADDIR='/home/d/dnkayu8j/mebelev.net/public_html/upload'
PREFIX=`date +%F` #Префикс по дате для структурирования резервных копий

#start backup
echo "[--------------------------------[`date +%F--%H-%M`]--------------------------------]" 
echo "[----------][`date +%F--%H-%M`] Run the backup script..."
# Удаляю предыдущий бэкап если он сущ-ет
if test "$(ls -A $DATADIR)";then
	rm -rf $DATADIR/*
	echo "old backup deleted"
else
	echo "old backup not deleted!!!"
fi
mkdir $DATADIR/$PREFIX  
echo "[++--------][`date +%F--%H-%M`] Generate a database backup..."
#MySQL dump
mysqldump --user=$USER --host=$HOST --password=$PASSWD --default-character-set=$CHARSET $DBNAME | gzip > $DATADIR/$PREFIX/$DBFILENAME-`date +%F--%H-%M`.sql.gz
if [[ $? -gt 0 ]];then 
echo "[++--------][`date +%F--%H-%M`] Aborted. Generate database backup failed."
# exit 1
fi
echo "[++++------][`date +%F--%H-%M`] Backup database [$DBNAME] - successfull."
echo "[++++++----][`date +%F--%H-%M`] Copy the source code project [$PROJNAME]..."
#Src dump
cd $SRCFILES/..
tar -czpf $DATADIR/$PREFIX/sources-`date +%F--%H-%M`.tar.gz --exclude 'upload' --exclude 'bitrix' `basename $SRCFILES` 
if [[ $? -gt 0 ]];then
echo "[++++++----][`date +%F--%H-%M`] Aborted. Copying the source code failed."
# exit 1
fi
# Upload dump
cd 'public_html'
tar -czpf $DATADIR/$PREFIX/upload-`date +%F--%H-%M`.tar.gz  upload 
if [[ $? -gt 0 ]];then
echo "[++++++++--][`date +%F--%H-%M`] Aborted. Copying the upload failed."
# exit 1
fi
# Bitrix dump
tar -czpf $DATADIR/$PREFIX/bitrix-`date +%F--%H-%M`.tar.gz  bitrix 
if [[ $? -gt 0 ]];then
echo "[++++++++--][`date +%F--%H-%M`] Aborted. Copying the bitrix failed."
# exit 1
fi
echo "[++++++++++][`date +%F--%H-%M`] All operations completed successfully!"
exit 0