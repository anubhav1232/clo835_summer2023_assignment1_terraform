sudo yum install docker -y
sudo service docker start
aws configure
vim ~/.aws/credentials
ECR_URL=318623136204.dkr.ecr.us-east-1.amazonaws.com/webapp-repo


aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker pull $ECR_URL:mysql-v0.1
docker pull $ECR_URL:webapp-v0.1

docker network create my_bridge_network

docker run -d --network my_bridge_network -e MYSQL_ROOT_PASSWORD=pw --name mysql_db $ECR_URL:mysql-v0.1

docker exec -it mysql_db /bin/sh
--> mysql -u root -ppw
--> USE employees;
--> SELECT * FROM employee;


# Get the DB container IP
DBHOST=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql_db)

# Run the blue instance
docker run -d --network my_bridge_network -p 8081:8080 \
    -e DBHOST=$DBHOST \
    -e DBPORT=3306 \
    -e DBUSER=root \
    -e DBPWD=pw \
    -e DATABASE=employees \
    -e APP_COLOR=blue \
    --name blue \
    $ECR_URL:webapp-v0.1

# Run the lime instance
docker run -d --network my_bridge_network -p 8082:8080 \
    -e DBHOST=$DBHOST \
    -e DBPORT=3306 \
    -e DBUSER=root \
    -e DBPWD=pw \
    -e DATABASE=employees \
    -e APP_COLOR=lime \
    --name lime \
    $ECR_URL:webapp-v0.1

# Run the pink instance
docker run -d --network my_bridge_network -p 8083:8080 \
    -e DBHOST=$DBHOST \
    -e DBPORT=3306 \
    -e DBUSER=root \
    -e DBPWD=pw \
    -e DATABASE=employees \
    -e APP_COLOR=pink \
    --name pink \
    $ECR_URL:webapp-v0.1

docker exec -it blue /bin/sh
ping lime
ping pink