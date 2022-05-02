// Helpers to run helm commands in containers
package helm

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// Permit to push helm chart on chartmuseum
#PushToChartmuseum: {

  // The source directory that contain helm charts
  directory: dagger.#FS

  // The relative path from `directory` where to lint 
  chart: string | *"."

  // The repository name where to push chart helm
  repositoryName: string | *"chartmuseum"

	// Environment variables
	env: [string]: string | dagger.#Secret

  // username to connect on chartmuseum
  username: dagger.#Secret

  // password to connect on chartmuseum
  password: dagger.#Secret

  // The docker image to use
  input?: docker.#Image

  #input: {
    if input != _|_ {
      docker.#Step & {
        output: input
      }
    },
    if input == _|_ {
      #InstallTools & {
        "env": env
      }
    }
  }
  
  docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          "args": ["helm cm-push \(chart) \(repositoryName) --dependency-update"]
        }
        mounts: "helm charts": {
          contents: directory
          dest:     "/src"
        }
        "env": {
          env
          HELM_REPO_USERNAME: username
          HELM_REPO_PASSWORD: password
        }
        workdir: "/src"
      }
    ]
  }  
}

// Permit to push helm chart on Artifactory
#PushToArtifactory: {

  // The source directory that contain helm charts
  directory: dagger.#FS

  // The relative path from `directory` where to lint 
  chart: string | *"."

  // The repository name where to push chart helm
  repositoryName: string | *"artifactory"

	// Environment variables
	env: [string]: string | dagger.#Secret

  // username to connect on chartmuseum
  username: dagger.#Secret

  // password to connect on chartmuseum
  password: dagger.#Secret

  // The docker image to use
  input?: docker.#Image

  #input: {
    if input != _|_ {
      docker.#Step & {
        output: input
      }
    },
    if input == _|_ {
      #InstallTools & {
        "env": env
      }
    }
  }
  
  docker.#Build & {
		steps: [
      #input,
      docker.#Run & {
        entrypoint: ["/bin/sh"]
        command: {
          name:   "-c"
          "args": ["helm dependency update \(chart) && helm push-artifactory \(chart) \(repositoryName) --dependency-update"]
        }
        mounts: "helm charts": {
          contents: directory
          dest:     "/src"
        }
        "env": {
          env
          HELM_REPO_USERNAME: username
          HELM_REPO_PASSWORD: password
        }
        workdir: "/src"
      }
    ]
  }  
}