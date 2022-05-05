package go

import(
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Test a go package
#Test: {
	// Package to test
	package: *"./..." | string

	args: [...string]

  // Environment variables
	env: [string]: string | dagger.#Secret

   // The docker image
  input?: docker.#Image

	#Container & {
    "input": input
		command: {
			name: "go"
			"args": [package, "-race -coverprofile=coverage.txt -covermode=atomic"] + args
			flags: {
				test: true
				"-v": true
			}
		}
    "env": env
		export: files: "coverage.txt": _
	}

	// file that contain the code coverage
	output: container.export.files."coverage.txt"
}