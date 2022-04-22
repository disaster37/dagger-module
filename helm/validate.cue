// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
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

	// The proxy chain if needed to access on k8s
    proxy: string | *""

    // The no proxy chain
    noProxy: string | *""

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #DefaultKubevalImage & {}

	_script: "helm template \(chart)"

	if shownOnly != "" {
		_script: _script + "--show-only \(shownOnly)"
	}
	if values != "" {
        _write:    core.#WriteFile & {
			input:      dagger.#Scratch
			path:       "values.yaml"
			contents: values
		}
        _script: _script + "-f \(_write.output)"
    }

    docker.#Run & {
		entrypoint: ["/bin/sh"]
		command: {
		    name:   "-c"
			"args": [_script + " | kubeval"]
		}
		mounts: "helm charts": {
			contents: directory
			dest:     "/src"
		}
		env: {
            KUBECONFIG: "/kubeconfig"
            http_proxy: proxy
            https_proxy: proxy
            no_proxy: noProxy
        }
        workdir: "/src"
        input: input
	}
}