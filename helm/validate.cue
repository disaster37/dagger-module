// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// Permit to validate helm chart with kubeval
#Validate: {

    // The source directory that contain helm charts
    directory: dagger.#FS

    // The relative path from `directory` where to run helm generate
    chart: string | *"."

	// The file to validate on template
	shownOnly: string | *""

	// The values contend
    values: dagger.#Secret | *""

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #DefaultKubevalImage & {}

	_args: ["helm", "template", chart]

	if shownOnly != "" {
		_args: _args + ["--show-only", shownOnly]
	}
	if values != "" {
        _write:    core.#WriteFile & {a
			input:      dagger.#Scratch
			path:       "values.yaml"
			contents: values
		}
        _args: _args + ["-f", _write.output]
    }

    docker.#Run & {
		command: {
		    name:   "-c"
			"args": _args + ["|", "kubeval"]
		}
		mounts: "helm charts": {
			contents: directory
			dest:     "/src"
		}
        workdir: "/src"
        input: input
	}
}