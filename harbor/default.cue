package harbor

import (
  "universe.dagger.io/docker"
)

// The harbor cli version to use when use default image
harborCliVersion: string | *"main"

#DefaultImage: docker.#Pull & {
  source: "webcenter/harbor-cli:\(harborCliVersion)"
}
