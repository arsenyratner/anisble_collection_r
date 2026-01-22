#!/bin/bash
# папка в которой будет комбинированный репозиторий
REPODIR=/srv/http/repo/redos/8.0/base-20240821
# копия ДВД
MEDIADIR=/srv/http/repo/redos/8.0/dvd-20240218.1
# копия base
BASEDIR=/srv/http/repo/redos/8.0/base
# копия updates
UPDATESDIR=/srv/http/repo/redos/8.0/updates

# создадим жесткие ссылки на пакеты в папке с первым символом названия пакета
for A in {{A..Z},{a..z},{0..9}}
do
    echo $A
    for DIR in {$MEDIADIR,$BASEDIR,$UPDATESDIR}
    do
        if [ ! -d ${REPODIR}/$A ]; then mkdir -p ${REPODIR}/$A; fi
        find $DIR -type f -name "$A*.rpm" -exec ln {} ${REPODIR}/$A \; 2> /dev/null
    done
done

# удаляем пустые папки
find $REPODIR -empty -type d -delete

# копируем метаданные групп пакетов
cp -f $BASEDIR/comps.xml $REPODIR/

# оставим только самые свежие версии пакетов
rm -f $(repomanage --keep=1 --old ${REPODIR})

# создадим метаданные, если есть файл comps.xml то с группами
if [[ -f "${REPODIR}/comps.xml" ]];
then
  echo "Create with -g comps.xml"
  createrepo --update ${REPODIR} -g comps.xml
else
  createrepo --update ${REPODIR}
fi
