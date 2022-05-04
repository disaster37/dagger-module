package go

import(
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Test a go package
#Test: {
	// Package to test
	package: *"./..." | string

  // Environment variables
	env: [string]: string | dagger.#Secret

   // The docker image
  input?: docker.#Image

	#Container & {
    "input": input
		command: {
			name: "go"
			args: [package]
			flags: {
				test: true
				"-v": true
			}
		}
    "env": env
	}
}