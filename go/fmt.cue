package go

import(
  "dagger.io/dagger"
  "universe.dagger.io/docker"
)

// Fmt a go package
#Fmt: {
	// Source code
	source: dagger.#FS

	// Package to test
	package: *"./" | string

	args: [...string]

  // Environment variables
	env: [string]: string | dagger.#Secret

   // The docker image
  input?: docker.#Image

	container: #Container & {
    "input": input
		"source": source
		command: {
			name: "gofmt"
			"args": [package] + args
			flags: {
				"-s": true
        "-w": true
			}
		}
    "env": env
		export: directories: "/src": _
	}

	// Source folders
	output: container.export.directories."/src"
}