#!/bin/bash
# SYNC repo {{ item.name }} to {{ item.localpath }} from {{ item.baseurl }}
logger "reposync start syncing repo {{ item.name }} to {{ item.localpath }} from {{ item.baseurl }}"
if [ ! -d {{ item.localpath }} ]; then mkdir -p {{ item.localpath }}; fi
#dnf install dnf-utils createrepo
dnf makecache
if [[ -f "{{ item.localpath }}/.repodata" ]];
then
  rm -rf "{{ item.localpath }}/.repodata"
fi
logger "reposync {{ item.name }}"
reposync --repo {{ item.name }} --downloadcomps --download-metadata --norepopath --download-path={{ item.localpath }}
logger "reposync syncing {{ item.name }} done, starting createing comps"

# if [[ -f "{{ item.localpath }}/comps.xml" ]];
# then
#   createrepo --update {{ item.localpath }} -g comps.xml
# else
#   createrepo --update {{ item.localpath }}
# fi
# logger "reposync comps creating {{ item.name}} done"
