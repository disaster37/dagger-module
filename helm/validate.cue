// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
	"strings"
)

// Permit to validate helm chart with kubeval
#Validate: {

    // The source directory that contain helm charts
    directory: dagger.#FS

    // The relative path from `directory` where to run helm generate
    chart: string | *"."

	// The file to validate on template
	showOnly: string | *""

	// The kubernetes version to validate schema
	version: string | *""

	// The list of URL to validate custom CRDs
	schemas: [...string]

	// The values contend
    values: dagger.#Secret

	// Environment variables
	env: [string]: string | dagger.#Secret

	// The docker image to use
	input: docker.#Image

	_helm: "helm template \(chart)"
	_mounts: [string]: core.#Mount

	if input == null {
        input: #InstallTools & {
            "env": env
        }
    }

	_showOnly: string | *""
	if showOnly != "" {
		_showOnly: " --show-only \(showOnly)"
	}
	_values: string | *""
	if values != null {
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
		_version: " --kubernetes-version \(version)"
	}
	_schema: [ for _, schema in schemas {" --schema-location '\(schema)'" }]

    docker.#Run & {
		entrypoint: ["/bin/sh"]
		command: {
		    name:   "-c"
			"args": [_helm + _showOnly + _values + " | kubeconform --verbose --summary --ignore-missing-schemas" + _version + strings.Join(_schema, "")]
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
        "input": input
	}
}