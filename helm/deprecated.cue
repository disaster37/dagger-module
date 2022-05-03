// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// Permit to check if use deprecated API with pluto
#Deprecated: {

  // The source directory that contain helm charts
  directory: dagger.#FS

  // The relative path from `directory` where to run helm generate
  chart: string | *"."

	// The kubernetes version to check deprecated
	version: string | *""

	// The list of URL to validate custom CRDs
	customsVersion: [...string]

	// The values contend
  values?: dagger.#Secret

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

	_helm: "helm template \(chart)"
	_mounts: [string]: core.#Mount

	_values: string | *""
	if values != _|_ {
    _values: " -f /tmp/values.yaml"
    _mounts: {
      "values.yaml": {
        dest:     "/tmp/values.yaml"
        type:     "secret"
        contents: values
      }
    }
  }
	_version: string | *""
	if version != "" {
		_version: " --target-versions \(version)"
	}

  docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          "args": [_helm + _values + " | pluto detect - --output wide" + _version]
        }
        mounts: {
          _mounts
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
}