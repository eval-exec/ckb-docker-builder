DOCKERHUB_REPO := nervos/ckb-docker-builder
GHCR_REPO := ghcr.io/nervosnetwork/ckb-docker-builder
RUST_VERSION := rust-$(shell sed -n "s/RUST_VERSION\s*=\s*'\(.*\)'$$/\1/p" gen-dockerfiles)
IMAGE_VERSION := ${RUST_VERSION}

bionic/Dockerfile: gen-dockerfiles templates/bionic.Dockerfile
	python3 gen-dockerfiles

centos-7/Dockerfile: gen-dockerfiles templates/centos-7.Dockerfile
	python3 gen-dockerfiles

aarch64/Dockerfile: gen-dockerfiles templates/aarch64.Dockerfile
	python3 gen-dockerfiles

build-all: build-bionic build-centos-7 build-aarch64

build-bionic: bionic/Dockerfile
	docker build -f bionic/Dockerfile --tag ${DOCKERHUB_REPO}:bionic-${IMAGE_VERSION} .

build-centos-7: centos-7/Dockerfile
	docker build -f centos-7/Dockerfile --tag ${DOCKERHUB_REPO}:centos-7-${IMAGE_VERSION} .

build-aarch64: aarch64/Dockerfile
	docker build -f aarch64/Dockerfile --tag ${DOCKERHUB_REPO}:aarch64-${IMAGE_VERSION} .

.PHONY: build-all build-bionic build-centos-7 build-aarch64
push-all: push-bionic push-centos-7 push-aarch64

push-bionic: build-bionic
	docker push ${DOCKERHUB_REPO}:bionic-${IMAGE_VERSION}

push-centos-7: build-centos-7
	docker push ${DOCKERHUB_REPO}:centos-7-${IMAGE_VERSION}

push-aarch64: build-aarch64
	docker push ${DOCKERHUB_REPO}:aarch64-${IMAGE_VERSION}

.PHONY: push-all push-bionic push-centos-7 push-aarch64

test-all: test-bionic test-centos-7

sync-ckb:
	if [ -d ckb ]; then git -C ckb pull; else git clone --depth 1 https://github.com/nervosnetwork/ckb.git; fi

test-bionic: sync-ckb
	docker run --rm -it -w /ckb -v "$$(pwd)/ckb:/ckb" ${DOCKERHUB_REPO}:bionic-${IMAGE_VERSION} make prod

test-centos-7: sync-ckb
	docker run --rm -it -w /ckb -v "$$(pwd)/ckb:/ckb" ${DOCKERHUB_REPO}:centos-7-${IMAGE_VERSION} make prod

.PHONY: test-all test-bionic test-centos-7 sync-ckb
