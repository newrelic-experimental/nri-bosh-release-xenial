# nri-bosh-release-xenial
A bosh release for deploying the New Relic Infrastructure agent 

This is a self contained bosh release for installing the New Relic Infrastructure agent. It includes the deb package as a blob and has an install script that installs the package. The package is the install package for Ubuntu Xenial.

The release is meant to be installed as an addon. In order to facilitate that, a sample runtime.yml file is included.

## Upload the release

To use, upload the release:
```bash
bosh upload-release ~/Downloads/nr-bosh-release-xenial-1.2.3.tgz
```

## Update license key

In runtime.yml, modify the `license_key` parameter to be the license key for the target New Relic account.

## Update runtime config

...and then, update the runtime config:
```bash
bosh update-runtime-config runtime.yml
```

Finally, redeploy to pick up the addon.
