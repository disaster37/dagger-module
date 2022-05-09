package go

import(
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Lint a go package
#Lint: {
	// Source code
	source: dagger.#FS

	// Package to test
	package: *"./..." | string

	args: [...string]

  // Environment variables
	env: [string]: string | dagger.#Secret

   // The docker image
  input?: docker.#Image

	container: #Container & {
    "input": input
		"source": source
		command: {
			name: "go"
			"args": ["vet", package] + args
		}
    "env": env
	}
}