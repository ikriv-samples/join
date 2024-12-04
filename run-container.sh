docker run --name mysql-test \
       	-e MYSQL_ROOT_PASSWORD=qweqwe \
	-p 3306:3306 \
	-v mysql-data:/var/lib/mysql \
	-d mysql:latest
