# these commands do some magic that make workstation 11 work

curl http://pastie.org/pastes/9934018/download -o /tmp/vmnet-3.19.patch
cd /usr/lib/vmware/modules/source
tar -xf vmnet.tar
patch -p0 -i /tmp/vmnet-3.19.patch
tar -cf vmnet.tar vmnet-only
rm -r *-only
vmware-modconfig --console --install-all
