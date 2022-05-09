package go

import(
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Test a go package
#Test: {
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
			"args": [package, "-coverprofile=/coverage.txt", "-covermode=atomic"] + args
			flags: {
				test: true
				"-v": true
        "-race": true
			}
		}
    "env": env
		export: files: "/coverage.txt": _
	}

	// file that contain the code coverage
	output: container.export.directories."/coverage.txt"
}