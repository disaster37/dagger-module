// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// Permit to run helm lint
#GenerateSchema: {

    // The source directory that contain helm charts
    directory: dagger.#FS

    // The relative path from `directory` where to lint 
    chart: string | *"."

	// Environment variables
	env: [string]: string | dagger.#Secret

    // The docker image to use
    input: docker.#Image

	_scripts: core.#Source & {
		path: "_scripts"
	}

    if input == null {
        input: #InstallTools & {
            "env": env
        }
    }

    docker.#Run & {
		entrypoint: ["/bin/sh"]
		command: {
		    name:   "-c"
			"args": ["/scripts/generate_schema.sh"]
		}
		mounts: {
			"helm charts": {
				contents: directory
				dest:     "/src"
			}
			scripts: {
					dest:     "/scripts"
					contents: _scripts.output
			}
		}
		"env": {
			env
		}
        workdir: "/src"
        "input": input
	}
}