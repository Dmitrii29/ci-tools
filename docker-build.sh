#!/bin/sh

# Expected global vars:
#   FULL_VERSION - version for tagging image
#   VERSION - version for jar file

DEFAULT_TAG="latest"
if [ "$CI_COMMIT_REF_NAME" = "master" ]
then
  DEFAULT_TAG="stable";
fi

docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY
# build and tag
docker build \
  --build-arg http_proxy=$HTTP_PROXY \
  --build-arg https_proxy=$HTTP_PROXY \
  --build-arg PROXY_HOST=$PROXY_HOST \
  --build-arg PROXY_PORT=$PROXY_PORT \
  --build-arg VERSION=$VERSION \
  -t $CI_REGISTRY_IMAGE:$DEFAULT_TAG .
docker tag $CI_REGISTRY_IMAGE:$DEFAULT_TAG $CI_REGISTRY_IMAGE:$FULL_VERSION
docker tag $CI_REGISTRY_IMAGE:$DEFAULT_TAG $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME
# push
docker push $CI_REGISTRY_IMAGE:$DEFAULT_TAG
docker push $CI_REGISTRY_IMAGE:$FULL_VERSION
docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME
# clean up
docker rmi $CI_REGISTRY_IMAGE:$FULL_VERSION
docker rmi $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_NAME
docker rmi $CI_REGISTRY_IMAGE:$DEFAULT_TAG
