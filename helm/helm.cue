// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// Permit to run helm lint
#Lint: {

    // The source directory that contain helm charts
    directory: dagger.#FS

    // The relative path from `directory` where to lint 
    chart: string | *"."

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #DefaultImage & {}

    docker.#Run & {
		command: {
		    name:   "lint"
			"args": [chart]
		}
		mounts: "helm charts": {
			contents: directory
			dest:     "/src"
		}
        workdir: "/src"
        input: input
	}
}

#Repo: {
    // The helm repository to add
    repositories: [repoName=string] {
        // The repisitory URL
        url: string
    }

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #DefaultImage & {}

    for repoName, repo in repositories {
        docker.#Run & {
            command: {
                name:   "repo"
                "args":
                - "add"
                - repoName
                - repo.url
            }
            input: input
        }
    }
}