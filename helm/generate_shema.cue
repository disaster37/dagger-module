// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
  "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// Permit to generate the schema values.yaml.json
// Becarrefull, it overwrite all the file
#GenerateSchema: {

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

  _run: docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          args: ["helm schema-gen values.yaml > /tmp/values.schema.json"]
        }
        mounts: {
          "helm charts": {
            contents: directory
            dest:     "/src"
          }
        }
        "env": {
          env
        }
        workdir: "/src"
      }
    ]
  }

  _output: core.#ReadFile & {
    input: _run.output.rootfs
    path: "/tmp/values.schema.json"
  }
    

	output: _output.contents
}