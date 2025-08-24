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

# Login to OpenShift
Invoke-Expression $env:OC_LOGIN
oc project $env:NS

Set-Location -Path "apps/sample-ui"
docker build -t ${env:DEST_REGISTRY}/demo-docker/sample-ui:DR .
docker login $env:DEST_REGISTRY -u $env:JFROG_USER -p $env:JFROG_TOKEN
docker push ${env:DEST_REGISTRY}/demo-docker/sample-ui:DR
(Get-Content all.yaml) | ForEach-Object {
    if ($_ -match "image:") {
        "              image: ${env:DEST_REGISTRY}/demo-docker/sample-ui:DR"
    } else {
        $_
    }
} | Set-Content all.yaml
Set-Location ../..
.\scripts\create-secrets.ps1 -Namespace $env:NS -DestRegistry $env:DEST_REGISTRY -JfrogUser $env:JFROG_USER -JfrogToken $env:JFROG_TOKEN
oc apply -f .\apps\sample-ui\all.yaml -n $env:NS
$Route = oc get route sample-ui -n $env:NS -o jsonpath='{.spec.host}'
Write-Host "App URL: https://$Route/"