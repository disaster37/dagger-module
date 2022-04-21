// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

#Install: {

    kubeconfig: dagger.#FS

    // The source directory that contain helm and or values.yaml
    directory: dagger.#FS

    repository: string | *""
    chart: string | *""
    name: string
    version: string | *""
    values: string | *""
    valuesFile: string | *"values.yaml"
    proxy: string | *""
    noProxy: string | *""

    // The docker image to use
    input: docker.#Image | *_defaultImage.output

    _defaultImage: #DefaultImage & {}

    if values == "" {
        _values: ""
    } else {
        _write:    core.#WriteFile & {
			input:      dagger.#Scratch
			path:       "values.yaml"
			contents: values
		}
        _values: _write.output
    }
    

    if repository == "" {
        _repo: "."
    } else {
        _repo: "\(repository)/\(chart)"
    }

    if version == "" {
        _version = []
    } else {
        _version: ["--version", version]
    }

    
    

    _args: ["--install", name, _repo,  "-f", _values, ] + _version

    docker.#Run & {
		command: {
		    name:   "update"
			"args": _args
		}
        mounts: { 
            "kubeconfig": {
                contents: kubeconfig
                dest:     "/kubeconfig"
            }
            if directory != null {
                mounts: "helm charts": {
                    contents: directory
                    dest:     "/src"
		        }
            }
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