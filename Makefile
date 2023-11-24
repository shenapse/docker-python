VERSION=3.11.6
IMAGE=shena4746/python:${VERSION}

ifeq ($(OS),Windows_NT)
	PWD=$(CURDIR)
endif

.PHONY: build
build:
	docker build -f ${VERSION}/Dockerfile -t ${IMAGE} .

# create new container and login to shell
.PHONY: shell
shell:
	docker run -it --rm ${IMAGE}

.PHONY: push
push:
	docker push ${IMAGE}