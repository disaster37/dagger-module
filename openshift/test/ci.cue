package ci

import (
	"dagger.io/dagger"
  "github.com/disaster37/dagger-module/openshift"
)


dagger.#Plan & {
  client: {

    env: {
      http_proxy?: dagger.#Secret
      https_proxy?: dagger.#Secret
      no_proxy?: string
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

    // Run helm lint
    push: #push

    _env: {
      if client.env.http_proxy != _|_ {
        http_proxy: client.env.http_proxy
      }
      if client.env.https_proxy != _|_ {
        https_proxy: client.env.https_proxy
      }
      if client.env.no_proxy != _|_ {
        no_proxy: client.env.no_proxy
      }
    }

    #push:  openshift.#PushDockerImage {
	    env: _env
      destination: core.#Ref
      auth: {
        username: string
        secret:   dagger.#Secret
      }
    }
  }
}