$RG="rm557323-dimdim-rg"

Write-Host "ATENCAO: todos os recursos Azure do projeto serao removidos."

$confirmation = Read-Host "Digite SIM para continuar"

if ($confirmation -ne "SIM") {
    Write-Host "Operacao cancelada."
    exit
}

az group delete `
  --name $RG `
  --yes `
  --no-wait

Write-Host "Exclusao solicitada."