// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// Permit to run helm lint
#UnitTest: {

  // The source directory that contain helm charts
  directory: dagger.#FS

  // The relative path from `directory` where to lint 
  chart: string | *"."

	// Environment variables
	env: [string]: string | dagger.#Secret

  // The docker image to use
  input?: docker.#Image

  #input: {
    if input != _|_ {
      docker.#Step & {
        output: input
      }
    },
    if input == _|_ {
      #InstallTools & {
        "env": env
      }
    }
  }
  
  docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          "args": ["helm unittest \(chart)"]
        }
        mounts: "helm charts": {
          contents: directory
          dest:     "/src"
        }
        "env": {
          env
        }
        workdir: "/src"
      }
    ]
  }

  
}