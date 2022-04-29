package openshift

import (
  "dagger.io/dagger"
  "dagger.io/dagger/core"
)

// Permit to build helm image with all tools required
#PushDockerImage: {

  // Environment variables
	env: [string]: string | dagger.#Secret

  // The docker image to use
  input?: docker.#Image

  // The docker registry where to push image
  destination: core.#Ref

  auth?: {
		username: string
		secret:   dagger.#Secret
	}



  core.#Push & {
		"dest": destination
    "env": {
      env
    }
		if auth != _|_ {
			"auth": auth
		}
    if input != _|_ {
      "input": input.rootfs
		  config:  input.config
    }
    if input == _|_ {
      _default: #InstallTools & {
        "env": env
      }
      "input": _default.output.rootfs
		  config:  _default.output.config
    }
	}