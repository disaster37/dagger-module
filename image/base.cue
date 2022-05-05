package image

import (
  "strings"
  "dagger.io/dagger"
  "dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

_baseImage: "redhat/ubi8-minimal"

// Permit to get base image with user and some extra tools
#Base: {

  version: string | *"latest"

  user?: {
    gid: int | *1000
    uid: int | *1000
    group: string
    user: string
    home: string
  }

  packages?: [...string]

  // Environment variables
	env: [string]: string | dagger.#Secret

  docker.#Build & {
    steps: [
      docker.#Pull & {
        source: "\(_baseImage):\(version)"
      },
      if user != _|_ {
        docker.#Run & {
          command: {
            name: "-c"
            args: ["groupadd --gid \(gid) \(group) && useradd -d \(home) -m -g \(group) -s /bin/bash -u \(uid) \(user)"]
          }
          "env": {
              env
          }
        },
      }
      if packages != _|_ {
        docker.#Run & {
          command: {
            name: "-c"
            args: ["microdnf install -y " + strings.Join(packages, " ") + " && microdnf clean all && rm -rf /tmp/* /var/tmp/*"]
          }
          "env": {
              env
          }
        },
      }
    ]
  }
}