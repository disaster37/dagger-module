// Go operation
package go

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

// A standalone go environment to run go command
#Container: {
	// Container app name
	name: *"go_builder" | string

	// Source code
	source: dagger.#FS

	// Environment variables
	env: [string]: string | dagger.#Secret

  // The docker image
  input?: docker.#Image

	

	_sourcePath:     "/src"
	_modCachePath:   "/root/.cache/go-mod"
	_buildCachePath: "/root/.cache/go-build"

	docker.#Run & {
		if input != _|_ {
      "input": input
    },
    if input == _|_ {
      // Default golang image
	    _image: #Image
      input: _image.output
    }
		workdir: _sourcePath
		mounts: {
			"source": {
				dest:     _sourcePath
				contents: source
			}
			"go mod cache": {
				contents: core.#CacheDir & {
					id: "\(name)_mod"
				}
				dest: _modCachePath
			}
			"go build cache": {
				contents: core.#CacheDir & {
					id: "\(name)_build"
				}
				dest: _buildCachePath
			}
		}
		env: {
			env
			GOMODCACHE: _modCachePath
		}
	}
}