package harbor

import (
  "strings"
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// Permit to scan image
#Scan: {

  // The API parameters
  api: #API

  // The harbor project
  project: string

  // The harbor repository
  repository: string

  // The harbor artifact
  artifact: string

  // The severity
  severity: string | *""

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
      #DefaultImage & {
      }
    }
  }

  _severity: string | *""
  if severity != "" {
    _severity: " --severity \(severity)"
  }
  
  docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          "args": ["harbor-cli " + strings.Join(api._apiParamaters, " ") + " check-vulnerabilities --project \(project) --repository \(repository) --artifact \(artifact) --force-scan" + _severity ]
        }
        "env": {
          env
          if api.auth != _|_ {
            PASSWORD: api.auth.password
          }
        }
      }
    ]
  }
}