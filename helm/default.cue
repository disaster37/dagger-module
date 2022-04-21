package helm

import (
	"universe.dagger.io/docker"
)

#DefaultImage: docker.#Pull & {
    source: "alpine/helm:latest"
}