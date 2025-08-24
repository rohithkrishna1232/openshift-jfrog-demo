oc project rohith-chirrareddy-dev

# Load environment variables from .env file
Write-Host "Loading .env file..."
Get-Content .env | ForEach-Object {
    if ($_ -match '^(\w+)=([^#]+)') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        if ($value) {
            [System.Environment]::SetEnvironmentVariable($name, $value)
            Write-Host "Set $name = $value"
        }
    }
}

# Debug: Show loaded environment variables
Write-Host "Debug - Environment Variables:"
Write-Host "NS: $env:NS"
Write-Host "DEST_REGISTRY: $env:DEST_REGISTRY"
Write-Host "JFROG_USER: $env:JFROG_USER"
Write-Host "JFROG_TOKEN: $($env:JFROG_TOKEN.Substring(0, 20))..."

if ($env:OC_LOGIN) {
    Write-Host "Logging into OpenShift..."
    Invoke-Expression $env:OC_LOGIN
}
oc project $env:NS
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\create-secrets.ps1 `
  -Namespace $env:NS `
  -DestRegistry $env:DEST_REGISTRY `
  -JfrogUser $env:JFROG_USER `
  -JfrogToken $env:JFROG_TOKEN


# --- ServiceAccounts ---
oc apply -f openshift\sa-deploy.yaml
oc apply -f openshift\sa-pipeline.yaml

# --- Tekton Pipeline ---
oc apply -f tekton\task-mirror.yaml
oc apply -f tekton\pipeline-mirror.yaml
oc apply -f tekton\pipelinerun-mirror.yaml

# --- Wait for pipeline to finish ---
oc get pr -n $env:NS

# --- Deploy App ---
oc apply -f apps\sample-ui\all.yaml

# --- Expose Route ---
oc rollout status deploy/sample-ui -n $env:NS
$routeHost = (oc get route sample-ui -n $env:NS -o jsonpath='{.spec.host}')
Write-Output "App available at: https://$routeHost"

