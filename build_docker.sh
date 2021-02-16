
git clone https://github.com/influenzanet/web-app.git
git clone https://github.com/influenzanet/user-management-service.git
git clone https://github.com/influenzanet/study-service.git
git clone https://github.com/influenzanet/api-gateway.git
git clone https://github.com/influenzanet/messaging-service.git
git clone https://github.com/influenzanet/logging-service.git

set -e

microservice="web-app"
imagename="web-app"


cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/web-app:$version infectieradarbe/$imagename:$version
docker push infectieradarbe/$imagename:$version
cd ../


microservice="user-management-service"
imagename="user-management-image"


cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/$microservice:$version infectieradarbe/$imagename:$version
docker push infectieradarbe/$imagename:$version
cd ../


microservice="study-service"
imagename="study-service-image"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/$microservice:$version infectieradarbe/$imagename:$version
docker push infectieradarbe/$imagename:$version
cd ../


microservice="api-gateway"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker-participant-api
make docker-management-api
docker tag github.com/influenzanet/participant-api:$version infectieradarbe/participant-api-image:$version
docker tag github.com/influenzanet/management-api:$version infectieradarbe/management-api-image:$version
docker push infectieradarbe/participant-api-image:$version
docker push infectieradarbe/management-api-image:$version
cd ../


microservice="messaging-service"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker-email-client
make docker-message-scheduler
make docker-messaging-service
docker tag github.com/influenzanet/messaging-service:$version infectieradarbe/messaging-service-image:$version
docker tag github.com/influenzanet/message-scheduler:$version infectieradarbe/message-scheduler-image:$version
docker tag github.com/influenzanet/email-client-service:$version infectieradarbe/email-client-service-image:$version
docker push infectieradarbe/email-client-service-image:$version
docker push infectieradarbe/message-scheduler-image:$version
docker push infectieradarbe/messaging-service-image:$version
cd ../



microservice="logging-service"
imagename="logging-service-image"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/$microservice:$version infectieradarbe/$imagename:$version
docker push infectieradarbe/$imagename:$version
cd ../

read -p "Press enter to continue"
