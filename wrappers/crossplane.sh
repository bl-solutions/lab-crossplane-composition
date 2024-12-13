#!/usr/bin/env bash

parse_args() {
  CONTEXT="${1}"
  ACTION="${2}"
}

wait_for_crossplane_is_ready() {
  kubectl --context "${CONTEXT}" wait \
    --for=condition=ready --namespace crossplane-system \
    pod -l app=crossplane
}

wait_for_kubernetes_provider_is_ready() {
  kubectl --context "${CONTEXT}" wait \
    --for=condition=ready --namespace crossplane-system \
    pod -l pkg.crossplane.io/provider=provider-kubernetes
}

namespace_exists() {
  local namespace
  namespace="${1}"
  return_code=$(kubectl get ns "${namespace}" &>/dev/null && echo "1" || echo "0")
  echo "${return_code}"
}

parse_args "${@}"

case $ACTION in
  "init")
    helm repo add crossplane-stable https://charts.crossplane.io/stable
    helm repo update crossplane-stable
  ;;

  "install")
    helm --kube-context "${CONTEXT}" install crossplane \
      --namespace crossplane-system --create-namespace \
      --version 1.18.1 \
      --atomic \
      crossplane-stable/crossplane
  ;;

  "uninstall")
    helm --kube-context "${CONTEXT}" uninstall crossplane \
      --namespace crossplane-system
  ;;

  "apply-function")
    wait_for_crossplane_is_ready
    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/config/function \
      --namespace crossplane-system
  ;;

  "apply-provider")
    wait_for_crossplane_is_ready
    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/config/provider/kubernetes-provider.yaml \
      --namespace crossplane-system
    sleep 10
  ;;

  "apply-provider-config")
    wait_for_kubernetes_provider_is_ready
    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/config/provider/kubernetes-provider-config.yaml \
      --namespace crossplane-system
  ;;

  "apply-xrd")
    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/config/composition/xrd.yaml \
      --namespace crossplane-system
    sleep 5
  ;;

  "apply-composition")
    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/config/composition/composition.yaml \
      --namespace crossplane-system
  ;;

  "apply-whoami")
    if [ "$(namespace_exists whoami)" -eq 0 ]
    then
      kubectl create namespace whoami
    fi

    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/manifest/ac-whoami.yaml \
      --namespace whoami
  ;;

  "apply-alpine")
    if [ "$(namespace_exists whoami)" -eq 0 ]
      then
        kubectl create namespace whoami
      fi
    kubectl --context "${CONTEXT}" apply \
      --filename crossplane/manifest/alpine.yaml \
      --namespace whoami
  ;;

  "interactive-alpine")
    kubectl --context "${CONTEXT}" exec \
      --namespace whoami -it pod/alpine -- sh
  ;;

  *)
    echo "${ACTION} not supported"
    exit 1
    ;;
esac
