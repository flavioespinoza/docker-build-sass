NAME   := webshielddev/demo
TAG    := $(shell git rev-parse --abbrev-ref HEAD)
IMG    := ${NAME}:${TAG}

green=\033[92m
end_green=\033[0m

red=\033[1;31m
end_red=\033[1;31m

color:
	# green log
	@echo ${STRING}

build-latest:
	@echo "***** Build Demo Docker image:" "${red}${LATEST}${end_green}" "*****"
	docker build -f Dockerfile -t flavioespinoza/docker-build-sass:latest .
	@echo "***** Complete Demo Docker image:" "${red}${LATEST}${end_green}" "*****"

build:
	@echo "***** Build Demo Docker image:" "${red}${IMG}${end_green}" "*****"
	docker build -f Dockerfile -t ${IMG} .
	@echo "***** Complete Demo Docker image:" "${red}${IMG}${end_green}" "*****"

push-latest:
	@echo "***** Pusing Demo Docker image:" "${red}${IMG}${end_green}" "*****"
	docker push flavioespinoza/docker-build-sass:latest
	@echo "***** Pushed Demo Docker image:" "${red}${IMG}${end_green}" "*****"

push:
	@echo "***** Pusing Demo Docker image:" "${red}${IMG}${end_green}" "*****"
	docker push ${IMG}
	@echo "***** Pushed Demo Docker image:" "${red}${IMG}${end_green}" "*****"
