package openshift

import (
  "universe.dagger.io/docker"
)

// The UBI version to use when use default image
ubiVersion: string | *"latest"

#DefaultImage: docker.#Pull & {
  source: "redhat/ubi8-minimal:\(ubiVersion)"
}
