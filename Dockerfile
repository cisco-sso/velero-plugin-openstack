FROM golang:latest AS golang
ENV GOPATH /go
WORKDIR /go/src/github.com/cisco-sso/velero-plugin-openstack
RUN go get -u github.com/golang/dep/cmd/dep
COPY . .
RUN dep ensure
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o velero-plugin-openstack .

FROM alpine:3.6
COPY --from=golang /go/src/github.com/cisco-sso/velero-plugin-openstack/velero-plugin-openstack /
ENTRYPOINT ["/bin/ash", "-c", "cp /velero-plugin-openstack /target/."]