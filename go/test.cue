package go

import(
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Test a go package
#Test: {
	// Package to test
	package: *"." | string

  // Environment variables
	env: [string]: string | dagger.#Secret

  input?: docker.#Image

	#Container & {
		command: {
			name: "go"
			args: [package]
			flags: {
				test: true
				"-v": true
			}
		}
    "env": env

    if input != _|_ {
      "input": input
    }
	}
}