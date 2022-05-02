// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
  "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// Permit to deploy app from helm chart
#Install: {

  // the kubeconfig content to access on k8s
  kubeconfig: dagger.#Secret

  // the release name
  name: string

  // The namespace where install chart
  namespace: string | *"default"

  // The values contend
  values: dagger.#Secret

  // Environment variables
	env: [string]: string | dagger.#Secret

  // The docker image that contain helm and repositories to use
  input?: docker.#Image

  // The chart source
  source: {

    // The chart name
    chart: string

    // The repository name
    repository: string

    // The chart version
    version: string | *""

    _cmd: "helm upgrade --install -n \(namespace) \(name) \(repository)/\(chart)"

    if version != "" {
      "_cmd": _cmd + " --version \(version)"
    }

    _mountsSource: [string]: core.#Mount
  } | {
    
    // The source directory that contain helm and or values.yaml
    directory: dagger.#FS

    _mountsSource: {
      "helm charts": {
        contents: directory
        dest:     "/src"
      }
    }
    _cmd: "helm upgrade --install -n \(namespace) \(name) ."
  }

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
  
  _mountsValues: [string]: core.#Mount
  _cmdValues: string | *""
	if values != null {
    _cmdValues: " -f /tmp/values.yaml"
    _mountsValues: {
      "values.yaml": {
        dest:     "/tmp/values.yaml"
        type:     "secret"
        contents: values
      }
    }
  }
  

  docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          "args": [source._cmd + _cmdValues]
        }
        mounts: {
          _mountsValues
          source._mountsSource
          "/root/.kube/config": {
            dest:     "/kubeconfig"
            type:     "secret"
            contents: kubeconfig
          }
        }
        "env": {
          env
          KUBECONFIG: "/kubeconfig"
        }
        workdir: "/src"
      }
    ]
  }
}