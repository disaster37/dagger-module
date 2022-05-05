package image

import (
  "strings"
  "dagger.io/dagger"
	"universe.dagger.io/docker"
)

_baseImage: "redhat/ubi8-minimal"
_basePackage: [
  "bash",
  "shadow-utils"
]

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
      docker.#Run & {
        command: {
          name: "/bin/sh"
          args: ["-c", "microdnf install -y " + strings.Join(_basePackages, " ")]
        }
        "env": {
            env
        }
      },
      if user != _|_ {
        docker.#Run & {
          command: {
            name: "/bin/sh"
            args: ["-c", "groupadd --gid \(user.gid) \(user.group) && useradd -d \(user.home) -m -g \(user.group) -s /bin/bash -u \(user.uid) \(user.user)"]
          }
          "env": {
              env
          }
        },
      }
      if packages != _|_ {
        docker.#Run & {
          command: {
            name: "/bin/sh"
            args: ["-c", "microdnf install -y " + strings.Join(packages, " ")]
          }
          "env": {
              env
          }
        },
      }
      docker.#Run & {
        command: {
          name: "/bin/sh"
          args: ["-c", "microdnf clean all && rm -rf /tmp/* /var/tmp/*"]
        }
        "env": {
            env
        }
      },
    ]
  }
}