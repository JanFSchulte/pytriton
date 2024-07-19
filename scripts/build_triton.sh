#!/usr/bin/env bash
# Copyright (c) 2023, NVIDIA CORPORATION. All rights reserved.
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
export TRITON_SERVER_IMAGE=$1
export PYTRITON_IMAGE_NAME=$2
export PLATFORM=$3

set -x

# check if docker image name has docker registry prefix to not try to pull development image
PULL_RESULT="1"
if [[ "${PYTRITON_IMAGE_NAME}" == *"/"* && "${PYTRITON_IMAGE_REBUILD}" != "1" ]]; then
  singularity pull "docker://${PYTRITON_IMAGE_NAME}"
  PULL_RESULT=$?
fi

# fetch base image earlier as in some environments there are issues with pulling base images while building
singularity pull  "docker://${TRITON_SERVER_IMAGE}"

BUILD_ARGS=${BUILD_ARGS:-""}
if [[ "${PULL_RESULT}" != "0" ]]; then
  if [ ! -z "${PYTHON_VERSIONS+x}" ]; then
    BUILD_ARGS+=" --build-arg PYTHON_VERSIONS=${PYTHON_VERSIONS}"
  fi
  if [ ! -z "${PYTRITON_MAKEFLAGS+x}" ]; then
    BUILD_ARGS+=" --build-arg MAKEFLAGS=${PYTRITON_MAKEFLAGS}"
  fi

  singularity build pytriton_23.04.sif scripts/pytriton.def
fi
