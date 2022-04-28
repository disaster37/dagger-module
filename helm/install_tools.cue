// Helpers to run helm commands in containers
package helm

import (
  "dagger.io/dagger"
  "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// Permit to build helm image with all tools required
#InstallTools: {

  // The docker image to use
  input: docker.#Image | *{
    #DefaultHelmImage
  }

  // Environment variables
	env: [string]: string | dagger.#Secret

  kubeconformVersion: string | *"latest"

  _kubeconformURL: "https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz"
  if  kubeconformVersion != "latest" {
    _kubeconformURL: "https://github.com/yannh/kubeconform/releases/download/\(kubevalVersion)/kubeconform-linux-amd64.tar.gz"
  }

  _helmSchemaGenURL: "https://github.com/karuppiah7890/helm-schema-gen.git"
  _helmUnitTestURL: "https://github.com/vbehar/helm3-unittest"


  _scripts: core.#Source & {
		path: "_scripts"
	}

  #input: input | *{
    #DefaultHelmImage
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
          name: "/scripts/install_kubeconform.sh"
          args: [_kubeconformURL]
        }
        mounts: scripts: {
          dest:     "/scripts"
          contents: _scripts.output
        }
        "env": {
            env
        }
      },
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name: "-c"
          args: ["helm plugin install \(_helmSchemaGenURL)"]
        }
        "env": {
            env
        }
      },
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name: "-c"
          args: ["helm plugin install \(_helmUnitTestURL)"]
        }
        "env": {
            env
        }
      },
    ]
  }
}