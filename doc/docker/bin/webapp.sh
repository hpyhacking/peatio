# build Dockerfile to image peatio:base first !!!
docker run -d --name webapp \
  -p 80:80 -p 18080:18080 -p 443:443 \
  --link rabbitmq:rabbitmq \
  --link dbmaster:dbmaster \
  --link redis:redis \
  peatio:base /sbin/my_init --enable-insecure-key

docker-bash webapp bash -lc 'cd /home/app/peatio/; git pull;'
docker-bash webapp bash -lc 'cd /home/app/peatio/; RAILS_ENV=production ./bin/rake db:migrate;'
docker-bash webapp bash -lc 'cd /home/app/peatio/; RAILS_ENV=production ./bin/rake assets:precompile;'
