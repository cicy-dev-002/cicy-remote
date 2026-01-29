ls

docker rm -f redis
docker run -itd \
  --name redis \
  -p 6379:6379 \
  redis \
  redis-server --requirepass $CICY_PASSWORD



mkdir -p ~/data/mysql8
docker rm -f mysql
docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=$CICY_PASSWORD \
  -v ~/data/mysql8:/var/lib/mysql \
  mysql


