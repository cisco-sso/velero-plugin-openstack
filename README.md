# velero-plugin-openstack
An openstack provider for Heptio Velero

[![Build Status][1]][2]

This repository contains example plugins for Velero.

## Kinds of Plugins

This repository provides the following kinds of velero plugins:

- **Object Store** - persists and retrieves backups, backup log files, restore warning/error files, restore logs.
- **Block Store** - creates snapshots from volumes (during a backup) and volumes from snapshots (during a restore).

## Building the plugins

To build the plugins, run

```bash
$ make build
```

To build the image, run

```bash
$ make container
```

This builds an image tagged as `cisco-sso/velero-plugin-openstack`. If you want to specify a
different name, run

```bash
$ make container IMAGE=your-repo/your-name:here
```

## Deploying the plugins

To deploy your plugin image to an Velero server:

1. Make sure your image is pushed to a registry that is accessible to your cluster's nodes.
2. Run `velero plugin add <image>`, e.g. `velero plugin add cisco-sso/velero-plugin-openstack`

## Using the plugins

***Note***: As of v0.10.0, the Custom Resource Definitions used to define backup and block storage providers have changed. See [the previous docs][3] for using plugins with versions v0.6-v0.9.x.

When the plugin is deployed, it is only made available to use. To make the plugin effective, you must modify your configuration:

Backup storage:

1. Run `kubectl edit backupstoragelocation <location-name> -n <velero-namespace>` e.g. `kubectl edit backupstoragelocation default -n velero` OR `velero backup-location create <location-name> --provider swift`
2. Change the value of `spec.provider` to openstack to enable an **Object Store** plugin
3. Save and quit. The plugin will be used for the next `backup/restore`

Volume snapshot storage:

1. Run `kubectl edit volumesnapshotlocation <location-name> -n <velero-namespace>` e.g. `kubectl edit volumesnapshotlocation default -n velero` OR `velero snapshot-location create <location-name> --provider cinder`
   An example can be found at examples/06-ark
2. Change the value of `spec.provider` to enable a **Block Store** plugin
3. Save and quit. The plugin will be used for the next `backup/restore`

## Examples

To run with the example plugins, do the following:

1. Run `velero backup-location create  default --provider swift` Optional: `--config bucket:<your-bucket>,prefix:<your-prefix>` to configure a bucket and/or prefix directories.
2. Run `velero snapshot-location create example-default --provider cinder`
3. Run `kubectl edit deployment/velero -n <velero-namespace>`
4. Change the value of `spec.template.spec.args` to look like the following:

```yaml
      - args:
        - server
        envFrom:
        - secretRef:
            name: cloud-credentials

```

5. Run `kubectl create -f examples/with-pv.yaml` to apply a sample nginx application that uses the example block store plugin. ***Note***: This example works best on a virtual machine, as it uses the host's `/tmp` directory for data storage.
6. Save and quit. The plugins will be used for the next `backup/restore`