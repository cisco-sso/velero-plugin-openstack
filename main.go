package main

import (
	"github.com/cisco-sso/velero-plugin-openstack/pkg/cinder"
	"github.com/cisco-sso/velero-plugin-openstack/pkg/swift"
	arkplugin "github.com/heptio/velero/pkg/plugin"
)

func main() {
	arkplugin.NewServer(arkplugin.NewLogger()).
		RegisterBlockStore("cinder", cinder.NewBlockStore).
		RegisterObjectStore("swift", swift.NewObjectStore).
		Serve()
}
