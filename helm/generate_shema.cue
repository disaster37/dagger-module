// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
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
  input: docker.#Image

  #input: input | *{
    #InstallTools & {
      "env": env
    }
  }

  run: docker.#Build & {
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
        export: files: "/tmp/values.schema.json": _
      }
    ]
  }

	output: run.export.files."/tmp/values.schema.json"
}