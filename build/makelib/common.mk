# Copyright 2016 The Rook Authors. All rights reserved.
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

# remove default suffixes as we dont use them
.SUFFIXES:

ifeq ($(origin PLATFORM), undefined)
GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)
PLATFORM := $(GOOS)_$(GOARCH)
else
GOOS := $(word 1, $(subst _, ,$(PLATFORM)))
GOARCH := $(word 2, $(subst _, ,$(PLATFORM)))
endif

GOHOSTOS := $(shell go env GOHOSTOS)
GOHOSTARCH := $(shell go env GOHOSTARCH)
HOST_PLATFORM := $(shell go env GOHOSTOS)_$(shell go env GOHOSTARCH)

ALL_PLATFORMS ?= darwin_amd64 windows_amd64 linux_arm linux_amd64 linux_arm64

ifeq ($(PLATFORM),linux_amd64)
CROSS_TRIPLE = x86_64-linux-gnu
DEBIAN_ARCH = amd64
endif
ifeq ($(PLATFORM),linux_arm)
GOARM=7
DEBIAN_ARCH = armhf
CROSS_TRIPLE = arm-linux-gnueabihf
endif
ifeq ($(PLATFORM),linux_arm64)
DEBIAN_ARCH = arm64
CROSS_TRIPLE = aarch64-linux-gnu
endif
ifeq ($(PLATFORM),darwin_amd64)
CROSS_TRIPLE=x86_64-apple-darwin15
endif
ifeq ($(PLATFORM),windows_amd64)
CROSS_TRIPLE=x86_64-w64-mingw32
endif

ifneq ($(PLATFORM),$(HOST_PLATFORM))
CC := $(CROSS_TRIPLE)-gcc
CXX := $(CROSS_TRIPLE)-g++
export CC CXX
endif

# set the version number. you should not need to do this
# for the majority of scenarios.
ifeq ($(origin VERSION), undefined)
VERSION := $(shell git describe --dirty --always --tags)
endif

# a registry that is scoped to the current build tree on this host
ifeq ($(origin BUILD_REGISTRY), undefined)
HOSTNAME := $(shell hostname)
SELFDIR := $(dir $(lastword $(MAKEFILE_LIST)))
ROOTDIR := $(shell cd $(SELFDIR)/../.. && pwd -P)
BUILD_REGISTRY := build-$(shell echo $(HOSTNAME)-$(ROOTDIR) | shasum -a 256 | cut -c1-8)
endif

# include the common make file
COMMON_SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

ifeq ($(origin OUTPUT_DIR),undefined)
OUTPUT_DIR := $(abspath $(COMMON_SELF_DIR)/../../_output)
endif
ifeq ($(origin WORK_DIR), undefined)
WORK_DIR := $(abspath $(COMMON_SELF_DIR)/../../.work)
endif
ifeq ($(origin CACHE_DIR), undefined)
CACHE_DIR := $(abspath $(COMMON_SELF_DIR)/../../.cache)
endif
TOOLS_DIR := $(CACHE_DIR)/tools
TOOLS_HOST_DIR := $(TOOLS_DIR)/$(HOST_PLATFORM)

COMMA := ,
SPACE :=
SPACE +=