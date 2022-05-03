package ci

import (
	"dagger.io/dagger"
  "github.com/disaster37/dagger-module/openshift"
)


dagger.#Plan & {
  client: {
    env: {
      http_proxy: dagger.#Secret | *null
      https_proxy: dagger.#Secret | *null
      no_proxy: string | *null
      TARGET_IMAGE: string | *"webcenter/dagger-plugin:openshift"
      DOCKER_USERNAME: string
      DOCKER_PASSWORD: dagger.#Secret
    }

    commands: {
      branchName: {
        name: "git"
        args: ["branch --show-current"]
        stdout: string
      }
    }
  }
      

  actions: {

    // Push docker image on registry
    push: #push

    _env: {
      if client.env.http_proxy != null {
        http_proxy: client.env.http_proxy
      }
      if client.env.https_proxy != null {
        https_proxy: client.env.https_proxy
      }
      if client.env.no_proxy != null {
        no_proxy: client.env.no_proxy
      }
    }

    #push: openshift.#PushDockerImage & {
	    env: _env
      destination: client.env.TARGET_IMAGE
      auth: {
        username: client.env.DOCKER_USERNAME
        secret:   client.env.DOCKER_PASSWORD
      }
    }
  }
}