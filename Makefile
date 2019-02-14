
# Copyright 2017 the Heptio Ark contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

REPO ?= github.com/cisco-sso/velero-plugin-openstack

BUILD_IMAGE ?= gcr.io/heptio-images/golang:1.9-alpine3.6

IMAGE ?= cisco-sso/velero-plugin-openstack

ARCH ?= amd64

test:
	go test ./...

all: build

build:
	mkdir -p .go/src/$(REPO) .go/pkg .go/std/$(ARCH) _output
	docker run \
				 --rm \
				 -u $$(id -u):$$(id -g) \
				 -v $$(pwd)/.go/pkg:/go/pkg \
				 -v $$(pwd)/.go/src:/go/src \
				 -v $$(pwd)/.go/std:/go/std \
				 -v $$(pwd):/go/src/$(REPO) \
				 -v $$(pwd)/.go/std/$(ARCH):/usr/local/go/pkg/linux_$(ARCH)_static \
				 -e CGO_ENABLED=0 \
				 -w /go/src/$(REPO) \
				 $(BUILD_IMAGE) \
				 go build -installsuffix "static" -i -v -o _output/velero-plugin-openstack .

container:
	# The docker file also performs a build so it can be part of an automated docker hub build
	docker build -t $(IMAGE) .

ci:
	mkdir -p _output
	# Ensure Tests
	go test ./...
	# Ensure Build
	CGO_ENABLED=0 go build -v -o _output/velero-plugin-openstack .

clean:
	rm -rf .go _output