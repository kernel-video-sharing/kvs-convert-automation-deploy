#!/bin/bash
# Home https://github.com/kernel-video-sharing/kvs-convert-automation-deploy
# Define
APIFILE="https://gist.githubusercontent.com/ninetian/6ef8efd0f268b4a269be2adccc6e3ddf/raw/3a43d15ddcc43a711b6fe7896183268ebff90b84/RemoteCron5.51"
FTPPASS="yourftppass"
APIURLS="https://yourkvsdomain.com/admin/api/callback_api.php";
APIPASS="123456";

#==== Do not modify the content below ====#
systemctl stop firewalld
systemctl disable firewalld
hostnamectl set-hostname C1
/usr/sbin/getenforce
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
sed -i s/SELINUX=permissive/SELINUX=disabled/g /etc/selinux/config
setenforce 0
ulimit -n
cat >/etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
www soft nofile 65535
www hard nofile 65535
EOF
echo "ulimit -SHn 65535">>/etc/rc.local
echo "ulimit -SHn 65535">>/etc/profile
ulimit -SHn 65535
ulimit -s unlimited
cd /opt
yum install -y epel-release
dnf -y install dnf-utils
dnf config-manager --set-enabled powertools
#yum -y install atop iftop iotop wget screen curl yum-utils git net-tools
yum install -y wget tar xz tinyxml2 mediainfo libmediainfo bc unzip screen
yum install -y ImageMagick ImageMagick-devel
yum install -y screen unzip fuse fuse-common sshfs
## FFMPEG
cd /opt
wget https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz
tar xvf ffmpeg-git-amd64-static.tar.xz
[[ -d /usr/local/ffmpeg ]] && rm -rf /usr/local/ffmpeg
mv ffmpeg-git-2022*-amd64-static /usr/local/ffmpeg
ln -sf /usr/local/ffmpeg/ffprobe  /usr/bin/ffprobe
ln -sf /usr/local/ffmpeg/ffmpeg /usr/bin/ffmpeg
ln -sf /usr/local/ffmpeg/qt-faststart /usr/bin/qt-faststart
ln -sf /usr/local/ffmpeg/ffprobe  /usr/local/bin/ffprobe
ln -sf /usr/local/ffmpeg/ffmpeg /usr/local/bin/ffmpeg
ln -sf /usr/local/ffmpeg/qt-faststart /usr/local/bin/qt-faststart
ln -sf /usr/bin/convert /usr/local/bin/convert
rm -rf ffmpeg-git-amd64-static.tar.xz
# PHP Deploy
#sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf module reset php -y
sudo dnf module install -y php:remi-7.4
#sudo dnf update -y
#sudo yum install -y php-ftp php-json
## FTP Deploy
yum install -y proftpd proftpd-utils
systemctl start proftpd
systemctl enable proftpd
### Create FTP Account
useradd -m -d /home/convert convert
echo "convert:${FTPPASS}" | chpasswd
chown convert -R /home/convert
chmod 755 -R /home/convert
### Make work path
for ((n=1;n<=5;n++));do
mkdir -p /home/convert/$n
curl -L "${APIFILE}" -o /home/convert/${n}/remote_cron.php >/dev/null
chown convert -R /home/convert/$n
chmod 755 -R /home/convert/$n
done
## Create Crontab
cat > /etc/cron.d/transcoding << EOF
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
MAILTO=root HOME=/
* * * * * root /usr/bin/php /home/convert/1/remote_cron.php > /dev/null 2>&1
* * * * * root /usr/bin/php /home/convert/2/remote_cron.php > /dev/null 2>&1
* * * * * root /usr/bin/php /home/convert/3/remote_cron.php > /dev/null 2>&1
* * * * * root /usr/bin/php /home/convert/4/remote_cron.php > /dev/null 2>&1
* * * * * root /usr/bin/php /home/convert/5/remote_cron.php > /dev/null 2>&1
EOF
## Notify
PubIP=$(curl -s "https://checkip.amazonaws.com")
echo -e $PubIP;
curl -Ss "${APIURLS}?key=${APIPASS}&ip=${PubIP}&pass=${FTPPASS}";
echo -e "Done"
history -c
