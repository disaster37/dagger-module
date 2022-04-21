// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
  "dagger.io/dagger/core"
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

    _values: ""
   if values != "" {
        _write:    core.#WriteFile & {a
			input:      dagger.#Scratch
			path:       "values.yaml"
			contents: values
		}
        _values: _write.output
    }
    

    _repo: "."
    if repository != "" {
        _repo: "\(repository)/\(chart)"
    }

    _version: [...string]
    _version: []
    if version != "" {
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