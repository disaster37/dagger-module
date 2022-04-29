package openshift

import (
  "dagger.io/dagger"
  "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// Permit to build helm image with all tools required
#InstallTools: {

  // The docker image to use
  input: docker.#Image | *{
    #DefaultImage
  }

  // Environment variables
	env: [string]: string | dagger.#Secret

  openshiftVersion: string | *"latest"

  _openshiftURL: "https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz"
  if  openshiftVersion != "latest" {
    _openshiftURL: "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/\(openshiftVersion)/openshift-client-linux-\(openshiftVersion).tar.gz"
  }


  _scripts: core.#Source & {
		path: "_scripts"
	}

  #input: input | *{
    #DefaultImage
  }

  docker.#Build & {
    steps: [
      #input,
      docker.#Run & {
          entrypoint: ["/sbin/apk"]
          command: {
            name: "add"
            args: ["curl", "bash"]
            flags: {
              "-U":         true
            }
          }
          "env": {
              env
          }
      },
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name: "/scripts/install_openshift_cli.sh"
          args: [_openshiftURL]
        }
        mounts: scripts: {
          dest:     "/scripts"
          contents: _scripts.output
        }
        "env": {
            env
        }
      },
    ]
  }
}