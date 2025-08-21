param(
  [string]$Namespace = $env:NS,
  [string]$DestRegistry = $env:DEST_REGISTRY,   # e.g. devrabbit.jfrog.io OR devrabbit.jfrog.io/artifactory
  [string]$JfrogUser = $env:JFROG_USER,         # e.g. 'robot$openshift'
  [string]$JfrogToken = $env:JFROG_TOKEN        # API key or password
)

if (-not $Namespace)    { $Namespace = "demo-ui" }
if (-not $DestRegistry) { Write-Error "DEST_REGISTRY not set"; exit 1 }
if (-not $JfrogUser)    { Write-Error "JFROG_USER not set"; exit 1 }
if (-not $JfrogToken)   { Write-Error "JFROG_TOKEN not set"; exit 1 }

Write-Host "Using namespace: $Namespace"
oc new-project $Namespace 2>$null | Out-Null
oc project $Namespace | Out-Null

# Opaque secret for Tekton (push to JFrog)
@"
apiVersion: v1
kind: Secret
metadata:
  name: jfrog-auth
  namespace: $Namespace
type: Opaque
stringData:
  username: "$JfrogUser"
  password: "$JfrogToken"
"@ | Out-File -Encoding ascii jfrog-auth.yaml

oc apply -f jfrog-auth.yaml | Out-Null
Remove-Item jfrog-auth.yaml

# docker-registry secret for the app (pull from JFrog)
oc create secret docker-registry jfrog-docker-secret `
  --docker-server="$DestRegistry" `
  --docker-username="$JfrogUser" `
  --docker-password="$JfrogToken" `
  --docker-email="devnull@local" `
  -n $Namespace --dry-run=client -o yaml | oc apply -f - | Out-Null

# Link secrets to ServiceAccounts (you already committed these YAMLs)
oc apply -f ..\openshift\sa-deploy.yaml | Out-Null
oc apply -f ..\openshift\sa-pipeline.yaml | Out-Null

Write-Host "✅ Secrets created and ServiceAccounts applied."
Write-Host "   - jfrog-auth (opaque) for Tekton"
Write-Host "   - jfrog-docker-secret (docker-registry) for app pulls"