package test

import (
	"dagger.io/dagger"
  "github.com/disaster37/dagger-module/helm"
)


dagger.#Plan & {
  client: {
    env: {
      http_proxy: dagger.#Secret | *null
      https_proxy: dagger.#Secret | *null
      no_proxy: string | *null
    }
    filesystem: {
      "./": read: contents: dagger.#FS
      "./test/values.yaml": read: contents: dagger.#Secret
    }
  }
      

  actions: test: {
    //_k8sVersion: "1.22.8"

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


    helm.#InstallTools & {
      env: _env
    }

    helm.#GenerateSchema & {
      env: _env
      directory: client.filesystem."./".read.contents
      chart: "test"
    }

    helm.#Lint & {
      env: _env
      directory: client.filesystem."./".read.contents
      chart: "test"
    }

    helm.#Validate & {
      env: _env
      directory: client.filesystem."./".read.contents
      chart: "test"
      "version": "1.22.8"
      values: client.filesystem."./test/values.yaml".read.contents
    }

    helm.#Deprecated & {
      env: _env
      directory: client.filesystem."./".read.contents
      chart: "test"
      "version": "k8s=v1.22.8"
      values: client.filesystem."./test/values.yaml".read.contents
    }

    helm.#UnitTest & {
      env: _env
      directory: client.filesystem."./".read.contents
      chart: "test"
    }

    //#install: helm.#Install & {
    //  env: _env
    //  name: "jarvis-api"
    //  values: client.filesystem."./examples/jarvis-api/values.yaml".read.contents
    //  source: {
    //     directory: client.filesystem."./".read.contents
    //  }
    //  kubeconfig: client.commands.kubeconfig.stdout
    //}

    //#push: helm.#PushToChartmuseum & {
    // directory: client.filesystem."./".read.contents
    //  env: _env
    //  input: _repos.output
    //  repositoryName: _repositoryName
    //  username: dagger.#Secret
    //  password: dagger.#Secret
    //}
  }
}