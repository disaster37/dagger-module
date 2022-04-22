package helm

import (
	"universe.dagger.io/docker"
)

// The helm version to use when use default image
helmVersion: string | *"latest"

// The kubeval version to use when use default image
kubevalVersion: string | *"latest"

#DefaultHelmImage: docker.#Pull & {
    source: "alpine/helm:\(helmVersion)"
}

#DefaultKubevalImage: docker.#Pull & {
    source: "garethr/kubeval:\(kubevalVersion)"
}