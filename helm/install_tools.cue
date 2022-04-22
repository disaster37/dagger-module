// Helpers to run helm commands in containers
package helm

import (
    "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// Permit to build helm image with all tools required
#InstallTools: {

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    // Environment variables
	env: [string]: string | dagger.#Secret

    kubevalVersion: string | *"latest"

    _kubevalURL: "https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz"
    if  kubevalVersion != "latest" {
        _kubevalURL: "https://github.com/instrumenta/kubeval/releases/download/\(kubevalVersion)/kubeval-linux-amd64.tar.gz"
    }

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
                env: {
                    env
                }
			},
            docker.#Run & {
                entrypoint: ["/bin/sh"]
				command: {
					name: "/scripts/install_kubeval.sh"
					args: [_kubevalURL]
				}
				mounts: scripts: {
					dest:     "/scripts"
					contents: _scripts.output
				}
                env: {
                    env
                }
			},
        ]
    }
}