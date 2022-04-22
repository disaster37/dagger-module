// Helpers to run helm commands in containers
package helm

import (
	"universe.dagger.io/docker"
)

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

    _defaultImage: #DefaultHelmImage & {}

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
                        http_proxy: proxy
                        https_proxy: proxy
                        no_proxy: noProxy
                    }
                }
            },
            docker.#Run & {
                command: {
                    name: "repo"
                    args: ["update"]
                }
                env: {
                    http_proxy: proxy
                    https_proxy: proxy
                    no_proxy: noProxy
                }
            }
        ]
    }
}