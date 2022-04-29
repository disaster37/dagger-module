package openshift

import (
  "universe.dagger.io/docker"
)

// The alpine version to use when use default image
alpineVersion: string | *"latest"

// The kubeval version to use when use default image
kubevalVersion: string | *"latest"

#DefaultHelmImage: docker.#Pull & {
  source: "alpine:\(helmVersion)"
}
