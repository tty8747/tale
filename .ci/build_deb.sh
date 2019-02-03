#!/bin/bash
set -e

ver=$1
pathbuild=$2
dpath=tale
arch=all

[ -e $dpath ] && rm -r $dpath
[ -f "tale.deb" ] && rm -f tale.deb

mkdir -p $dpath/DEBIAN $dpath/opt/tale $dpath/etc/systemd/system

echo -e "Package: tale\nVersion: $ver\nMaintainer:Chulanov Sergey\nSection:misc\nDescription: Lorem ipsum dolor sit amet,\n consectetur adipisci\nArchitecture: $arch" > $dpath/DEBIAN/control

echo -e "#!/bin/bash\nsystemctl daemon-reload\nsystemctl enable tale\nsystemctl start tale" >$dpath/DEBIAN/postinst

chmod 0755 $dpath/DEBIAN/postinst

# rsync -a --exclude tale.tar.gz tale.zip tale-p/ $dpath/opt/tale
cp -r $pathbuild/* $dpath/opt/tale/

cat << EOF > $dpath/etc/systemd/system/tale.service
[Unit]
Description=tale blog
After=network.target
[Service]
Type=simple
ExecStart=/bin/bash -c "/usr/bin/java -jar /opt/tale/tale-latest.jar"
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo chmod 664 $dpath/etc/systemd/system/tale.service

# md5deep -r $dpath > $dpath/DEBIAN/md5sums
find $dpath -type f -print0 | xargs -0 md5sum > $dpath/DEBIAN/md5sums

# fakeroot dpkg-deb --build $dpath
dpkg-deb --build $dpath

exit 0
