$ErrorActionPreference = "Stop"

$ACR="rm557323dimdimacr"
$ACR_LOGIN_SERVER="$ACR.azurecr.io"

Write-Host "Realizando login no ACR..."
az acr login --name $ACR

Write-Host "Construindo imagens locais..."
docker compose build

Write-Host "Criando tags..."
docker tag checkpoint-4---devops-app:latest "$ACR_LOGIN_SERVER/dimdim-app:v1"
docker tag checkpoint-4---devops-db:latest "$ACR_LOGIN_SERVER/dimdim-db:v1"

Write-Host "Enviando imagem da aplicacao..."
docker push "$ACR_LOGIN_SERVER/dimdim-app:v1"

Write-Host "Enviando imagem do banco..."
docker push "$ACR_LOGIN_SERVER/dimdim-db:v1"

Write-Host "Imagens enviadas ao ACR."