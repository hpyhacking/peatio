docker run -d --name redis dockerfile/redis
docker run -d --name dbmaster -v /dbdata:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=ROOT_PASSWORD -e MYSQL_USER=DATABASE_USER -e MYSQL_PASSWORD=PASSWORD -e MYSQL_DATABASE=DATABSE_NAME mysql
docker run -d --name rabbitmq dockerfile/rabbitmq
