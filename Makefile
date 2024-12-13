KIND_CLUSTER_NAME := crossplane
CONTEXT := kind-$(KIND_CLUSTER_NAME)

up:
	@wrappers/cluster.sh create $(KIND_CLUSTER_NAME)
	@wrappers/crossplane.sh $(CONTEXT) init
	@wrappers/crossplane.sh $(CONTEXT) install
	@wrappers/crossplane.sh $(CONTEXT) apply-function
	@wrappers/crossplane.sh $(CONTEXT) apply-provider
	@wrappers/crossplane.sh $(CONTEXT) apply-provider-config
	@wrappers/crossplane.sh $(CONTEXT) apply-xrd
	@wrappers/crossplane.sh $(CONTEXT) apply-composition

down:
	@wrappers/cluster.sh delete $(KIND_CLUSTER_NAME)

deploy_app:
	@wrappers/crossplane.sh $(CONTEXT) apply-whoami

deploy_alpine:
	@wrappers/crossplane.sh kind-crossplane apply-alpine

open_alpine_terminal:
	@wrappers/crossplane.sh kind-crossplane interactive-alpine
