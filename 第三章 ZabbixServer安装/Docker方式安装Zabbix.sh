Docker方式安装Zabbix

安装和启动docker:
yum install docker-latest -y 
systemctl start docker-latest
systemctl status docker-latest
ps -ef | grep docker

测试容器功能
docker run -d -p 80:80 httpd
ps -ef | grep httpd
docker stop ffc18f4d40c9

安装mysql
docker run --name mysql-server -t -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="ZCJ24576" -e MYSQL_ROOT_PASSWORD="123456" -d mysql:5.7 --character-set-server=utf8 --collation-server=utf8_bin

运行结果如下：

9779cb64318e        mysql:5.7                              "docker-entrypoint..."   44 minutes ago      Up 44 minutes       3306/tcp, 33060/tcp           mysql-server

安装zabbix-java-gateway
docker run --name zabbix-java-gateway -t -d zabbix/zabbix-java-gateway:latest
23d4cceb8f06        zabbix/zabbix-java-gateway:latest      "docker-entrypoint.sh"   41 minutes ago      Up 41 minutes       10052/tcp                     zabbix-java-gateway

安装zabbix-server的容器
docker run --name zabbix-server-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="ZCJ24576" -e MYSQL_ROOT_PASSWORD="123456" -e ZBX_JAVAGATEWAY="zabbix-java-gateway" --link mysql-server:mysql --link zabbix-java-gateway:zabbix-java-gateway -p 10051:10051 -d zabbix/zabbix-server-mysql:latest
*这里的link后面跟的是已经正在运行的mysql容器和zabbix-java-gateway容器的NAME字段名称
运行结果如下：
23d4cceb8f06        zabbix/zabbix-java-gateway:latest      "docker-entrypoint.sh"   41 minutes ago      Up 41 minutes       10052/tcp                     zabbix-java-gateway


安装zabbix的前端
docker run --name zabbix-web-nginx-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="ZCJ24576" -e MYSQL_ROOT_PASSWORD="123456" --link mysql-server:mysql --link zabbix-server-mysql:zabbix-server -p 80:80 -d zabbix/zabbix-web-nginx-mysql:latest
运行结果如下：
a2fcd886b106        zabbix/zabbix-web-nginx-mysql:latest   "docker-entrypoint.sh"   10 minutes ago      Up 10 minutes       0.0.0.0:80->80/tcp, 443/tcp   zabbix-web-nginx-mysql


安装zabbix_agent
docker run --name zabbix-agent -e ZBX_HOSTNAME="Zabbix server" -e ZBX_SERVER_HOST="zabbix-server-mysql" --link zabbix-server-mysql:zabbix-server -d zabbix/zabbix-agent:latest
711101115ca0        zabbix/zabbix-agent:latest             "/sbin/tini -- /us..."   8 minutes ago       Up 8 minutes        10050/tcp                     zabbix-agent
