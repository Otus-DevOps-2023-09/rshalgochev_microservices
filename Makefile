D_BUILD = docker build -t
D_PUSH = docker push

ifeq ($(USER_NAME),)
    $(info USER_NAME is empty)
	exit 1
endif

all:
	@echo "make build - Builds all images"
	@echo "make push - Push all images"

build: monitoring src

monitoring: blackbox prometheus
src: comment post ui

blackbox:
	$(D_BUILD) $(USER_NAME)/blackbox_exporter monitoring/blackbox-exporter

prometheus:
	$(D_BUILD) $(USER_NAME)/prometheus monitoring/prometheus

comment:
	$(D_BUILD) $(USER_NAME)/comment src/comment

post:
	$(D_BUILD) $(USER_NAME)/post src/post-py

ui:
	$(D_BUILD) $(USER_NAME)/ui src/ui

push:
	$(D_PUSH) $(USER_NAME)/comment
	$(D_PUSH) $(USER_NAME)/post
	$(D_PUSH) $(USER_NAME)/ui
	$(D_PUSH) $(USER_NAME)/prometheus
	$(D_PUSH) $(USER_NAME)/blackbox_exporter
	$(D_PUSH) $(USER_NAME)/mongoD_BUILD_exporter:0.20.2

.PHONY: blackbox prometheus comment post ui push
