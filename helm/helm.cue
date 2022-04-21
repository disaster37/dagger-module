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

#Repository: {
    // The helm repository to add
    repositories: [repoName=string]: {
        // The repisitory URL
        url: string
    }

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    // Environment variables
	  proxy: string | *""
    noProxy: string | *""

    _defaultImage: #DefaultImage & {}

    docker.#Build & {
      steps: [
        docker.#Step & {
          output: input
        },
        for repoName, repo in repositories {
          docker.#Run & {
            command: {
              name: "repo"
              args: ["add", repoName, repo.url]
            }
            env: {
                if proxy != "" {
                    http_proxy: proxy
                    https_proxy: proxy
                }
                if noProxy != "" {
                    no_proxy: noProxy
                }
            }
          }
        },
      ]
    }
}

#Install: {


}