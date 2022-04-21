package kubectl

import (
    "dagger.io/dagger"
	"dagger.io/dagger/core"
)

#Install: {
    path: *"./bin" | string
    version: *"v1.21.7" | string

    install: bash.#Run 

}