package go

// Test a go package
#Test: {
	// Package to test
	package: *"." | string

  // Environment variables
	env: [string]: string | dagger.#Secret

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
	}
}