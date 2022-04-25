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
    input: docker.#Image | *_defaultImage.output

    // Environment variables
	env: [string]: string | dagger.#Secret

    kubeconformVersion: string | *"latest"

    _kubeconformURL: "https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz"
    if  kubeconformVersion != "latest" {
        _kubeconformURL: "https://github.com/yannh/kubeconform/releases/download/\(kubevalVersion)/kubeconform-linux-amd64.tar.gz"
    }

    _helmSchemaGenURL: "https://github.com/karuppiah7890/helm-schema-gen.git"

    _defaultImage: #DefaultHelmImage & {}

    _scripts: core.#Source & {
		path: "_scripts"
	}


    docker.#Build & {
        steps: [
            docker.#Step & {
                output: input
            },
            docker.#Run & {
                entrypoint: ["/sbin/apk"]
				command: {
					name: "add"
					args: ["curl"]
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
					name: "/scripts/install_kubeconform.sh"
					args: [_helmSchemaGenURL]
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