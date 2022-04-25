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
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #InstallTools & {
       "env": env
    }

    docker.#Run & {
		entrypoint: ["/bin/sh"]
		command: {
		    name:   "-c"
			"args": ["scripts/generate_schema.sh"]
		}
		mounts: "helm charts": {
			contents: directory
			dest:     "/src"
		}
		"env": {
			env
		}
        workdir: "/src"
        "input": input
	}
}