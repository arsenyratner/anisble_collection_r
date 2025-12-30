# podman

```bash
zpoolname="local-zfs"
datasetname=containers
mountpoint=/containers
zfs create $zpoolname/$datasetname
zfs set mountpoint=$mountpoint $zpoolname/$datasetname

cat > /etc/containers/storage.conf<<EOF
[storage]
# Default Storage Driver, Must be set for proper operation.
driver = "overlay"

# Primary Read/Write location of container storage
graphroot = "/containers/graphroot"
runroot = "/containers/runroot"
EOF

cd /containers
mkdir graphroot runroot
mv -f /var/lib/containers/* /containers/graphroot/
mv -f /run/containers/* /containers/runroot/

# rm -rf /var/lib/containers

```
