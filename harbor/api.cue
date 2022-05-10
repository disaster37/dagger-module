package harbor

import (
  "dagger.io/dagger"
)

#API: {

  // The harbor URL with API version
  url: string

  auth?: {
    // The username to access on harbor API
    username: string

    // The password to access on harbor API
    password: dagger.#Secret
  }

  // Self signed certificate on harbor API
  selfSignedCertificate: bool | *false

  // timeout
  timeout: string | *"180s"

  _apiParamaters: [
    "--url \(url)",
    "--timeout \"\(timeout)\"",
    if selfSignedCertificate {
      "--self-signed-certificate",
    }
    if auth != _|_ {
      "--username \(auth.username)",
    }
    if auth != _|_ {
      "--password \"${PASSWORD}\"",
    }
  ]

}