$ErrorActionPreference = "Stop"

$RG="rm557323-dimdim-rg"
$LOCATION="brazilsouth"

$ACR="rm557323dimdimacr"
$ACR_LOGIN_SERVER="$ACR.azurecr.io"

$VNET="rm557323-dimdim-vnet"
$SUBNET="rm557323-dimdim-aci-subnet"
$AGW_SUBNET="rm557323-dimdim-agw-subnet"

$DB_CONTAINER="rm557323-dimdim-db"
$APP_CONTAINER="rm557323-dimdim-app"

$PUBLIC_IP="rm557323-dimdim-public-ip"
$APP_GATEWAY="rm557323-dimdim-agw"

if (-not $env:DIMDIM_DB_PASSWORD) {
    throw "Defina DIMDIM_DB_PASSWORD antes de executar este script."
}

$DB_PASSWORD=$env:DIMDIM_DB_PASSWORD

$ACR_USER = az acr credential show `
  --name $ACR `
  --query username `
  --output tsv

$ACR_PASSWORD = az acr credential show `
  --name $ACR `
  --query "passwords[0].value" `
  --output tsv

Write-Host "Criando PostgreSQL no ACI..."

az container create `
  --resource-group $RG `
  --name $DB_CONTAINER `
  --image "$ACR_LOGIN_SERVER/dimdim-db:v1" `
  --registry-login-server $ACR_LOGIN_SERVER `
  --registry-username $ACR_USER `
  --registry-password $ACR_PASSWORD `
  --vnet $VNET `
  --subnet $SUBNET `
  --ports 5432 `
  --environment-variables `
      POSTGRES_DB=dimdim `
      POSTGRES_USER=postgres `
  --secure-environment-variables `
      POSTGRES_PASSWORD=$DB_PASSWORD `
  --cpu 1 `
  --memory 1.5 `
  --os-type Linux

$DB_IP = az container show `
  --resource-group $RG `
  --name $DB_CONTAINER `
  --query "ipAddress.ip" `
  --output tsv

$JDBC_URL="jdbc:postgresql://$DB_IP`:5432/dimdim"

Write-Host "PostgreSQL: $DB_IP"
Write-Host "Criando aplicacao..."

az container create `
  --resource-group $RG `
  --name $APP_CONTAINER `
  --image "$ACR_LOGIN_SERVER/dimdim-app:v1" `
  --registry-login-server $ACR_LOGIN_SERVER `
  --registry-username $ACR_USER `
  --registry-password $ACR_PASSWORD `
  --vnet $VNET `
  --subnet $SUBNET `
  --ports 8080 `
  --environment-variables `
      SPRING_DATASOURCE_URL=$JDBC_URL `
      SPRING_DATASOURCE_USERNAME=postgres `
  --secure-environment-variables `
      SPRING_DATASOURCE_PASSWORD=$DB_PASSWORD `
  --cpu 1 `
  --memory 1.5 `
  --os-type Linux

$APP_IP = az container show `
  --resource-group $RG `
  --name $APP_CONTAINER `
  --query "ipAddress.ip" `
  --output tsv

Write-Host "Aplicacao: $APP_IP"
Write-Host "Criando Application Gateway..."

az network application-gateway create `
  --resource-group $RG `
  --name $APP_GATEWAY `
  --location $LOCATION `
  --sku Standard_v2 `
  --capacity 1 `
  --vnet-name $VNET `
  --subnet $AGW_SUBNET `
  --public-ip-address $PUBLIC_IP `
  --servers $APP_IP `
  --frontend-port 80 `
  --http-settings-port 8080 `
  --http-settings-protocol Http `
  --priority 100

$PROBE_NAME="dimdim-api-probe"

az network application-gateway probe create `
  --resource-group $RG `
  --gateway-name $APP_GATEWAY `
  --name $PROBE_NAME `
  --protocol Http `
  --host $APP_IP `
  --path "/api/transacoes" `
  --interval 30 `
  --timeout 30 `
  --threshold 3

az network application-gateway http-settings update `
  --resource-group $RG `
  --gateway-name $APP_GATEWAY `
  --name "appGatewayBackendHttpSettings" `
  --probe $PROBE_NAME

$PUBLIC_IP_ADDRESS = az network public-ip show `
  --resource-group $RG `
  --name $PUBLIC_IP `
  --query "ipAddress" `
  --output tsv

Write-Host ""
Write-Host "Deploy concluido."
Write-Host "API: http://$PUBLIC_IP_ADDRESS/api/transacoes"