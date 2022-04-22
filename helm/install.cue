// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
    "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Install: {

    // the kubeconfig content to access on k8s
    kubeconfig: dagger.#Secret

    // the release name
    name: string

    // The values contend
    values: dagger.#Secret | *""

    // The proxy chain if needed to access on k8s
    proxy: string | *""

    // The no proxy chain
    noProxy: string | *""

    // The docker image that contain helm and repositories to use
    input: docker.#Image | *_defaultImage.output

    // The chart source
    source: *"repository" | "local"
    {
        source: "repository"

        // The chart name
        chart: string

        // The repository name
        repository: string

        // The chart version
        version: string | *""

        _args: _args + ["\(repository)/\(chart)"]

        if version != "" {
            _args: _args + ["--version", version]
        }
    } | {
        source: "local"
        
        // The source directory that contain helm and or values.yaml
        directory: dagger.#FS

        _mounts: {
            "helm charts": {
                contents: directory
                dest:     "/src"
            }
        }
        _args: _args + ["."]
    }

    _args: ["--install", name]
    _mounts: [name=string]: core.#Mount
    _defaultImage: #DefaultHelmImage & {}

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
		    name:   "update"
			"args": _args
		}
        mounts: _mounts + { 
            "kubeconfig": {
                dest:     "/kubeconfig"
                type:     "secret"
                contents: kubeconfig
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