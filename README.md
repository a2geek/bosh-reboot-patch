# BOSH Reboot Patch

> NOTE: This should no longer be required unless you are running from an older copy of [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment). See [this issue](https://github.com/cloudfoundry/bosh/issues/2131) for details.

The BOSH Director (and some BOSH deployments) don't always start up successfully after a reboot (intentional or not). The solution seems to be just a simple `monit stop all` followed by a `monit start all`. _BOSH Reboot Patch_ injects that into `/etc/rc.local`.

## BOSH Director

When (re-)deploying the BOSH Director, just include the ops file from this repository. Typically, the usage is to simply clone a local copy of the repository, set `BOSH_REBOOT_DIR` to that directory and then add the ops file like this:
```
$ bosh create-env ${BOSH_DEPLOYMENT_DIR}/bosh.yml \
    --ops-file=... \
    --ops-file=... \
    --ops-file=... \
    --ops-file=${BOSH_REBOOT_DIR}/operations/add-to-director.yml \
    --ops-file=... \
    --ops-file=... \
    ...etc...
```

For a fuller example when deploying a director, pleaes see the [libvirt-bosh-cpi](https://github.com/a2geek/libvirt-bosh-cpi).

## Runtime Config

To apply to other deployments, this patch can be added as a runtime config:
```
bosh update-runtime-config --name reboot-patch \
    ${BOSH_REBOOT_DIR}/manifests/runtime-config.yml
```

## Hacking

Everything of interest is in the `reboot-patch` job. That source is [here](https://github.com/a2geek/bosh-reboot-patch/tree/master/jobs/reboot-patch).  The `templates/pre-start` injects the hook into `/etc/rc.local` while `templates/startup.sh` is what does the Monit stop/start.
