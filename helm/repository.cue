// Helpers to run helm commands in containers
package helm

import (
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Permit to add external repository available for helm
#Repository: {

  // The helm repository to add
  repositories: [repoName=string]: {
    // The repisitory URL
    url: string
  }

  // The docker image to use
  input: docker.#Image

  // Environment variables
	env: [string]: string | dagger.#Secret

  #input: input | *{
    #InstallTools & {
      "env": env
    }
  }

  docker.#Build & {
    steps: [
      #input,
      for repoName, repo in repositories {
        docker.#Run & {
          command: {
            name: "repo"
            args: ["add", repoName, repo.url]
          }
          "env": {
            env
          }
        }
      },
      docker.#Run & {
        command: {
            name: "repo"
            args: ["update"]
        }
        "env": {
            env
        }
      }
    ]
  }
}