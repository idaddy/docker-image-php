all: 5.3/Dockerfile 5.6/Dockerfile
	docker build -t registry.idaddy.cn:5043/idaddy/php:5.3 5.3
	docker build -t registry.idaddy.cn:5043/idaddy/php:5.6 5.6

clean:
	docker rmi registry.idaddy.cn:5043/idaddy/php:5.3
	docker rmi registry.idaddy.cn:5043/idaddy/php:5.6

push:
	docker push registry.idaddy.cn:5043/idaddy/php:5.3
	docker push registry.idaddy.cn:5043/idaddy/php:5.6

