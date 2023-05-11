#FROM golang:alpine AS build
ARG arch
FROM 10.30.38.116/utccp-$arch/dependence-golang-builder:latest AS build1

COPY . /src/goproxy
RUN cd /src/goproxy &&\
    export CGO_ENABLED=0 &&\
    export GOPROXY="https://goproxy.cn" &&\
    make

FROM 10.30.38.116/utccp-$arch/dependence-golang-builder:latest AS build2

COPY ./tini /src/tini
RUN dnf install gcc gcc-c++ cmake -y
RUN cd /src/tini && \
    cmake . && \
    make

#FROM golang:alpine
FROM 10.30.38.116/utccp-$arch/dependence-base:latest

# Add tini
COPY --from=build2 /src/tini/tini /usr/bin/tini
COPY --from=build1 /src/goproxy/bin/goproxy /goproxy

VOLUME /go

EXPOSE 8081

ENTRYPOINT ["/usr/bin/tini", "--", "/goproxy"]
CMD []
