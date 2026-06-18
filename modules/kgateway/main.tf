# ── Step 1: Install Kubernetes Gateway API CRDs ───────────────────────────────
resource "helm_release" "gateway_api_crds" {
  name             = "gateway-api-crds"
  repository       = "https://kubernetes-sigs.github.io/gateway-api"
  chart            = "gateway-api"
  version          = "1.2.1"
  namespace        = "gateway-system"
  create_namespace = true

  # CRDs only — no controller deployment from this chart
  set {
    name  = "fullnameOverride"
    value = "gateway-api"
  }
}

# ── Step 2: Install KGateway (Envoy-based Gateway API implementation) ──────────
resource "helm_release" "kgateway" {
  name             = "kgateway"
  repository       = "oci://cr.kgateway.dev/kgateway-helm"
  chart            = "kgateway"
  version          = var.kgateway_version
  namespace        = "kgateway-system"
  create_namespace = true
  wait             = true
  timeout          = 300

  depends_on = [helm_release.gateway_api_crds]
}
