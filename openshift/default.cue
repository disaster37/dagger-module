package openshift

import (
  "universe.dagger.io/docker"
)

// The alpine version to use when use default image
alpineVersion: string | *"latest"

#DefaultImage: docker.#Pull & {
  source: "alpine:\(alpineVersion)"
}
