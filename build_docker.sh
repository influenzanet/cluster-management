
git clone https://github.com/influenzanet/web-client-nl.git
git clone https://github.com/influenzanet/user-management-service.git
git clone https://github.com/influenzanet/study-service.git
git clone https://github.com/influenzanet/api-gateway.git
git clone https://github.com/influenzanet/messaging-service.git
git clone https://github.com/influenzanet/logging-service.git

set -e

microservice="web-client-nl"
imagename="web-client-belgium-image"


cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/web-client:$version sajeeth1009/$imagename:$version
docker push sajeeth1009/$imagename:$version
cd ../


microservice="user-management-service"
imagename="user-management-image"


cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/$microservice:$version sajeeth1009/$imagename:$version
docker push sajeeth1009/$imagename:$version
cd ../


microservice="study-service"
imagename="study-service-image"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/$microservice:$version sajeeth1009/$imagename:$version
docker push sajeeth1009/$imagename:$version
cd ../


microservice="api-gateway"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker-participant-api
make docker-management-api
docker tag github.com/influenzanet/participant-api:$version sajeeth1009/participant-api-image:$version
docker tag github.com/influenzanet/management-api:$version sajeeth1009/management-api-image:$version
docker push sajeeth1009/participant-api-image:$version
docker push sajeeth1009/management-api-image:$version
cd ../


microservice="messaging-service"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker-email-client
make docker-message-scheduler
make docker-messaging-service
docker tag github.com/influenzanet/messaging-service:$version sajeeth1009/messaging-service-image:$version
docker tag github.com/influenzanet/message-scheduler:$version sajeeth1009/message-scheduler-image:$version
docker tag github.com/influenzanet/email-client-service:$version sajeeth1009/email-client-service-image:$version
docker push sajeeth1009/email-client-service-image:$version
docker push sajeeth1009/message-scheduler-image:$version
docker push sajeeth1009/messaging-service-image:$version
cd ../



microservice="logging-service"
imagename="logging-service-image"

cd $microservice
git pull
version=`git describe --tags --abbrev=0`
make docker
docker tag github.com/influenzanet/$microservice:$version sajeeth1009/$imagename:$version
docker push sajeeth1009/$imagename:$version
cd ../

read -p "Press enter to continue"
