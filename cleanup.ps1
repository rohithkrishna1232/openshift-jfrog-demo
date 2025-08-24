# Load environment variables from .env file
Get-Content .env | ForEach-Object {
    if ($_ -match '^(\w+)=([^#]+)') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        if ($value) {
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
}

Invoke-Expression $env:OC_LOGIN
oc project $env:NS

oc delete -f .\apps\sample-ui\all.yaml -n $env:NS
oc delete -f .\tekton\pipelinerun-mirror.yaml -n $env:NS
oc delete -f .\tekton\pipeline-mirror.yaml -n $env:NS
oc delete -f .\tekton\task-mirror.yaml -n $env:NS
oc delete -f .\openshift\sa-deploy.yaml -n $env:NS
$secrets = oc get secrets -n $env:NS --no-headers | ForEach-Object { $_.Split()[0] }
foreach ($secret in $secrets) {
    oc delete secret $secret -n $env:NS
}
Write-Host "Cleanup complete. All resources and secrets deleted from $env:NS."
