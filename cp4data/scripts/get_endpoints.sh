#!/bin/bash

# Obtains the credentials and endpoints for the installed CP4D control plane
printEndpoint() {
  console_url_address=$1
  namespace=$2
  echo "[INFO] CPD Endpoint: ${console_url_address}"

  # NOTE: The credentials are statics and defined by the installer, in the future this
  # may not be the case.
  echo "[INFO] CPD Username:  admin"
  echo "[INFO] CPD Password:  password"
  echo "[INFO] CPD Namespace: ${namespace}"
  echo "[INFO] Please update your username and password within the CPD console as soon as possible."
}

