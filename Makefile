#get target arch and os from envvars, default to linux-amd64
#supported oses are: linux, darwin, windows
#supported arches are: amd64, arm64
#run make as follows: make build TARGETOS=linux TARGETARCH=arm64
#make build TARGETOS=darwin TARGETARCH=arm64

TARGETOS ?= linux
TARGETARCH ?= amd64

#container registry to use
REGISTRY := ghcr.io/kaathepython

APP=$(shell basename $(shell git remote get-url origin))
#VERSION = $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
VERSION = $(shell git describe --tags --abbrev=0)
CURRENT_SYS = $(shell uname -a)

IMG_NAME := ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

BUILD_CMD = go build -v -o kbot -ldflags "-X="github.com/kaathepython/telebot/cmd.appVersion=${VERSION}

format:

	@gofmt -s -w ./

get:
	@go get

lint:
	@golint

test:
	@go test -v

build: format get 
	@printf "Building for: $(TARGETOS)/$(TARGETARCH)\n"
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) $(BUILD_CMD)

linux: format get 
	@printf "Building for: linux/$(TARGETARCH)\n"
	CGO_ENABLED=0 GOOS=linux GOARCH=$(TARGETARCH) $(BUILD_CMD)

windows: format get 
	@printf "Building for: Windows/$(TARGETARCH)\n"
	CGO_ENABLED=0 GOOS=windows GOARCH=$(TARGETARCH) $(BUILD_CMD)

macos: format get 
	@printf "Building for: MacOS/$(TARGETARCH)\n"
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(TARGETARCH) $(BUILD_CMD)

image:
	@printf "Building image: $(IMG_NAME)\n"
	docker build . -t $(IMG_NAME) --build-arg TARGETARCH=${TARGETARCH}

push: image
	docker push $(IMG_NAME)

dive: image
	IMG=$$(docker images --quiet $(IMG_NAME))
	CI=true docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive --ci --lowestEfficiency=0.99 $${IMG}
	docker rmi $${IMG}

clean:
	rm -rf kbot
	docker rmi $(IMG_NAME)

