$ErrorActionPreference = "Stop"

$RG="rm557323-dimdim-rg"
$LOCATION="brazilsouth"
$ACR="rm557323dimdimacr"
$STORAGE="rm557323dimdimst"
$SHARE="dimdimdata"
$VNET="rm557323-dimdim-vnet"
$ACI_SUBNET="rm557323-dimdim-aci-subnet"
$AGW_SUBNET="rm557323-dimdim-agw-subnet"
$PUBLIC_IP="rm557323-dimdim-public-ip"

Write-Host "Registrando providers..."
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Storage

Write-Host "Criando Resource Group..."
az group create `
  --name $RG `
  --location $LOCATION

Write-Host "Criando Azure Container Registry..."
az acr create `
  --resource-group $RG `
  --name $ACR `
  --sku Basic `
  --admin-enabled true

Write-Host "Criando Storage Account..."
az storage account create `
  --resource-group $RG `
  --name $STORAGE `
  --location $LOCATION `
  --sku Standard_LRS `
  --kind StorageV2

$STORAGE_KEY = az storage account keys list `
  --resource-group $RG `
  --account-name $STORAGE `
  --query "[0].value" `
  --output tsv

Write-Host "Criando File Share..."
az storage share create `
  --account-name $STORAGE `
  --account-key $STORAGE_KEY `
  --name $SHARE

Write-Host "Criando VNet..."
az network vnet create `
  --resource-group $RG `
  --name $VNET `
  --location $LOCATION `
  --address-prefix 10.0.0.0/16 `
  --subnet-name $ACI_SUBNET `
  --subnet-prefix 10.0.1.0/24

Write-Host "Delegando subnet para ACI..."
az network vnet subnet update `
  --resource-group $RG `
  --vnet-name $VNET `
  --name $ACI_SUBNET `
  --delegations Microsoft.ContainerInstance/containerGroups

Write-Host "Criando subnet do Application Gateway..."
az network vnet subnet create `
  --resource-group $RG `
  --vnet-name $VNET `
  --name $AGW_SUBNET `
  --address-prefixes 10.0.2.0/24

Write-Host "Criando IP publico..."
az network public-ip create `
  --resource-group $RG `
  --name $PUBLIC_IP `
  --location $LOCATION `
  --allocation-method Static `
  --sku Standard

Write-Host "Infraestrutura base criada."