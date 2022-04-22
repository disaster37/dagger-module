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
    values: dagger.#Secret | *""

	// Environment variables
	env: [string]: string | dagger.#Secret

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #DefaultKubevalImage & {}

	_helm: "helm template \(chart)"

	_showOnly: string | *""
	if showOnly != "" {
		_showOnly: " --show-only \(showOnly)"
	}
	_values: string | *""
	if values != "" {
        _write:    core.#WriteFile & {
			input:      dagger.#Scratch
			path:       "values.yaml"
			contents: values
		}
        _values: " -f \(_write.output)"
    }
	_version: string | *""
	if version != "" {
		_version: " --kubernetes-version \(version)"
	}
	_schema: [ for _, schema in schemas {" --schema-location \(schema)" }]

    docker.#Run & {
		entrypoint: ["/bin/sh"]
		command: {
		    name:   "-c"
			"args": [_helm + _showOnly + _values + " | kubeconform --verbose --summary --ignore-missing-schemas" + _version + strings.Join(_schema, "")]
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