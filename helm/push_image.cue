package helm

import (
  "dagger.io/dagger"
  "dagger.io/dagger/core"
  "universe.dagger.io/docker"
)

// Permit to build helm image with all tools required
#PushDockerImage: {

  // Environment variables
	env: [string]: string | dagger.#Secret

  // The docker image to use
  image?: docker.#Image

  // The docker registry where to push image
  destination: core.#Ref

  auth?: {
		username: string
		secret:   dagger.#Secret
	}


  if image == _|_ {
    _default: #InstallTools & {
      "env": env
    }

    _push: core.#Push & {
		  "dest": destination
      if auth != _|_ {
        "auth": auth
      }
      input: _default.output.rootfs
      config:  _default.output.config
    }
  }

  if image != _|_ {
    _push: core.#Push & {
      "dest": destination
      if auth != _|_ {
        "auth": auth
      }
      input: image.rootfs
      config:  image.config
    }
  }
}