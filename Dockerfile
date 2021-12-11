FROM --platform=linux/amd64 ubuntu:20.04

WORKDIR /worker

RUN apt-get update &&\
  apt-get install -y curl unzip llvm-11 clang

RUN cd /worker && \
  curl -L "https://github.com/odin-lang/Odin/releases/download/dev-2021-12/odin-ubuntu-amd64-dev-2021-12.zip" --output odin-ubuntu-amd64-dev-2021-12.zip &&\
  unzip odin-ubuntu-amd64-dev-2021-12.zip &&\
  chmod +x ubuntu_artifacts/odin

RUN /worker/ubuntu_artifacts/odin version

ENV PATH /worker/ubuntu_artifacts:$PATH