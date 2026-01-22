#!/bin/bash
# папка в которой будет комбинированный репозиторий
NEWBASEDIR="{{ reposync_reporoot }}/redos/8.0/base-20240821"
# копия ДВД
MEDIADIR="{{ reposync_reporoot }}/redos/8.0/dvd-20240218.1"
# копия base
BASEDIR="{{ reposync_reporoot }}/redos/8.0/base"
# копия updates
UPDATESDIR="{{ reposync_reporoot }}/redos/8.0/updates"

# создадим жесткие ссылки на пакеты в папке с первым символом названия пакета
for A in { {A..Z},{a..z},{0..9} }
do
    echo $A
    for DIR in {$MEDIADIR,$BASEDIR,$UPDATESDIR}
    do
        if [ ! -d ${NEWBASEDIR}/$A ]; then mkdir -p ${NEWBASEDIR}/$A; fi
        find $DIR -type f -name "$A*.rpm" -exec ln {} ${NEWBASEDIR}/$A \; 2> /dev/null
    done
done

# удаляем пустые папки
find $NEWBASEDIR -empty -type d -delete

# копируем метаданные групп пакетов
cp -f $BASEDIR/comps.xml $NEWBASEDIR/

# оставим только самые свежие версии пакетов
rm -f $(repomanage --keep=1 --old ${NEWBASEDIR})

# создадим метаданные, если есть файл comps.xml то с группами
if [[ -f "${NEWBASEDIR}/comps.xml" ]];
then
  echo "Creating with -g comps.xml"
  createrepo --update ${NEWBASEDIR} -g comps.xml
else
  createrepo --update ${NEWBASEDIR}
fi
