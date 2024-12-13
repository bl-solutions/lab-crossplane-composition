#!/usr/bin/env bash

parse_args() {
  ACTION="${1}"
  CLUSTER_NAME="${2:-crossplane}"
}

exists() {
  local return_code
  return_code=$(kind get clusters | grep -q "${CLUSTER_NAME}" && echo "1" || echo "0")
  echo "${return_code}"
}

parse_args "${@}"

case $ACTION in
  "create")
    if [ "$(exists)" -eq "1" ]
    then
      echo "The cluster \"${CLUSTER_NAME}\" already exists, skipping"
    else
      kind create cluster --name "${CLUSTER_NAME}"
    fi
    ;;

  "delete")
    if [ "$(exists)" -eq "0" ]
    then
      echo "The cluster \"${CLUSTER_NAME}\" not exists, skipping"
    else
      kind delete cluster --name "${CLUSTER_NAME}"
    fi
    ;;

  *)
    echo "${ACTION} not supported"
    exit 1
    ;;
esac
