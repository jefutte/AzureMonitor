<#
.Synopsis
   Create federated credentials for GitHub
.DESCRIPTION
   The script creates a resource group containing a User-Assigned Managed Identity, assigns permissions to that identity on the subscription provided, and creates federated credentials on the identity
.EXAMPLE
   Connect-AzAccount 
   .\FederatedCredentials.ps1 -SubscriptionId "susbcriptionid" -Location "westeurope" -GithubOrganizationName "jefutte" -GithubRepoName "rgName"
.OUTPUTS
   Use output to create 3 secret in your Github repo: SUBSCRIPTION_ID, CLIENT_ID, TENANT_ID 
.NOTES
   Creator: Jesper Fütterer Bing
   Blog: cloudpuzzles.net
#>



[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $SubscriptionId,

    [Parameter()]
    [string]
    $ResourceGroupName = "rg-deployment-pr-001",

    [Parameter()]
    [string]
    $Location,

    [Parameter()]
    [string]
    $ManagedIdentityName = "id-monitoring-pr-001",

    [Parameter()]
    [string]
    $RoleDefinitionName = "Owner",

    [Parameter()]
    [string]
    $GithubOrganizationName,

    [Parameter()]
    [string]
    $GithubRepoName
)

#Set AzContext
Select-AzSubscription -SubscriptionId $SubscriptionId

#Create resource group
$rg = New-AzResourceGroup -Name $ResourceGroupName $Location

#Creating Managed Identity and assign permission
$uami = New-AzUserAssignedIdentity -ResourceGroupName $rg.ResourceGroupName -Name $ManagedIdentityName -Location $Location
$roleassignment = New-AzRoleAssignment -PrincipalId $uami.PrincipalId -RoleDefinitionName $RoleDefinitionName -Scope "/subscriptions/$SubscriptionId/" -ObjectType 'ServicePrincipal'

#Create federated credential for managed identity
$fedcred = New-AzFederatedIdentityCredentials -ResourceGroupName $rg.ResourceGroupName -IdentityName $uami.Name -Issuer "https://token.actions.githubusercontent.com" -Name $GithubRepoName -Subject "repo:${GithubOrganizationName}/${GithubRepoName}:ref:refs/heads/main"

[ordered]@{
    SUBSCRIPTION_ID = $SubscriptionId
    CLIENT_ID = $uami.ClientId
    TENANT_ID = $uami.TenantId
} | ConvertTo-Json