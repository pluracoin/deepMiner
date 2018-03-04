read -p "[1] Listen Port (7777) > " lport
read -p "[2] Your Domain (localhost) > " domain
read -p "[3] Pool Host&Port (mine.plurapool.com:3333) > " pool
read -p "[4] Your PLURA wallet (important!!!) > " addr
if [ ! -n "$lport" ];then
    lport="7777"
fi
if [ ! -n "$domain" ];then
    domain="localhost"
fi
if [ ! -n "$pool" ];then
    pool="mine.plurapool.com:3333"
fi
while  [ ! -n "$addr" ];do
    read -p "Please set PLURA wallet address!!! > " addr
done
read -p "[5] The Pool passwd (null) > " pass
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt install --yes nodejs git curl nginx
mkdir /srv
cd /srv
rm -rf deepMiner
git clone https://github.com/pluracoin/pluracoin-webminer-proxy.git -o pluracoinWebminer
cd pluracoinWebminer
sed -i "s/7777/$lport/g" config.json
sed -i "s/digxmr.com/$domain/g" config.json
sed -i "s/mine.plurapool.com:3333/$pool/g" config.json
sed -i "s/Pv7naGZ8w5n5DD5gcT8YMh74jigANb2xeTHREBs4YZq678bXGAK6oS2hfGZzyGjT9a5oHNw55ZzbJVsP5savSpNS2qNWTSQjd/$addr/g" config.json
sed -i "s/\"pass\": \"\"/\"pass\": \"$pass\"/g" config.json
npm update
npm install -g forever
forever stopall
forever start /srv/pluracoinWebminer/server.js
sed -i '/forever start \/srv\/pluracoinWebminer\/cluster.js/d' /etc/rc.local
sed -i '/exit 0/d' /etc/rc.local
echo "forever start /srv/pluracoinWebminer/cluster.js" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
rm -rf /etc/nginx/sites-available/pluracoinWebminer.conf
rm -rf /etc/nginx/sites-enabled/pluracoinWebminer.conf
echo 'server {' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'listen 80;' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo "server_name $domain;" >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'location / {' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'proxy_http_version 1.1;' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'proxy_set_header   Host	$http_host;' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'proxy_set_header   X-Real-IP $remote_addr;' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'proxy_set_header   Upgrade $http_upgrade;' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'proxy_set_header   Connection "upgrade";' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo 'proxy_cache_bypass $http_upgrade;' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo "proxy_pass         http://127.0.0.1:$lport;" >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo '}' >> /etc/nginx/sites-available/pluracoinWebminer.conf
echo '}' >> /etc/nginx/sites-available/pluracoinWebminer.conf
ln -s /etc/nginx/sites-available/pluracoinWebminer.conf /etc/nginx/sites-enabled/pluracoinWebminer.conf
clear
echo " >>> Serv : $domain (backend > 127.0.0.1:$lport)"
echo " >>> Pool : $pool"
echo " >>> Addr : $addr"
echo ""
echo " All done ! Enjoy pluracoinWebminer !"
echo ""
service nginx restart
