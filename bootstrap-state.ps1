<#
.SYNOPSIS
    Bootstrap: Creates the Azure storage account for Terraform remote state.
    Run this ONCE before `terraform init`.

.NOTES
    Prerequisites:
      - Azure CLI logged in: az login
      - Sufficient permissions on subscription

.USAGE
    .\bootstrap-state.ps1
#>

$ErrorActionPreference = "Stop"

$RESOURCE_GROUP    = "aswin-rg"
$LOCATION          = "centralindia"
$STORAGE_ACCOUNT   = "aegishealthstorage"   # must be globally unique, lowercase
$CONTAINER_NAME    = "tfstate"

function Write-Step($msg) { Write-Host "`n🔷 $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "  ✅ $msg" -ForegroundColor Green }

Write-Step "Creating Resource Group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION | Out-Null
Write-OK "Resource group ready"

Write-Step "Creating Storage Account: $STORAGE_ACCOUNT"
az storage account create `
    --resource-group $RESOURCE_GROUP `
    --name $STORAGE_ACCOUNT `
    --sku Standard_LRS `
    --kind StorageV2 `
    --https-only true `
    --min-tls-version TLS1_2 | Out-Null
Write-OK "Storage account created"

Write-Step "Creating blob container: $CONTAINER_NAME"
az storage container create `
    --name $CONTAINER_NAME `
    --account-name $STORAGE_ACCOUNT `
    --auth-mode login | Out-Null
Write-OK "Container created"

Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host   "║  ✅  Bootstrap Complete — Now run:                   ║" -ForegroundColor Green
Write-Host   "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  terraform init -backend-config=environments\dev\backend.hcl" -ForegroundColor Yellow
Write-Host "  terraform plan -var-file=terraform.tfvars -out=tfplan" -ForegroundColor Yellow
Write-Host "  terraform apply tfplan" -ForegroundColor Yellow
