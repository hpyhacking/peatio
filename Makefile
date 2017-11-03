VERSION := $(shell cat VERSION)
IMAGE   := gcr.io/hc-public/peatio:$(VERSION)

.PHONY: default build push run ci deploy

default: build run

build:
	@echo '> Building "peatio" docker image...'
	@docker build -t $(IMAGE) .

push: build
	gcloud docker -- push $(IMAGE)

run:
	@echo '> Starting "peatio" container...'
	@docker run -it --rm $(IMAGE) bash

ci:
	@fly -t ci set-pipeline -p peatio -c config/pipelines/review.yml -n
	@fly -t ci unpause-pipeline -p peatio

deploy: push
	@helm install ./config/charts/peatio --set "image.tag=$(VERSION)"
