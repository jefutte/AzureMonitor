# Creates managed identity and adds Github repo as federated credential, then outputs information needed for Github
# The managed identity is assigned permissions on the subscription level, as all infrastructure, including resource group are created with code
#
# Make sure you are connected to Azure and have access to the subscription to be used
#
# Use output to create 3 secret in your Github repo: SUBSCRIPTION_ID, CLIENT_ID, TENANT_ID 


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
    $RoleDefinitionName = "Contributor",

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
$fedcred = New-AzFederatedIdentityCredentials -ResourceGroupName $rg.ResourceGroupName -IdentityName $uami.Name -Issuer "https://token.actions.githubusercontent.com" -Name $GithubRepoName -Subject "repo:${GithubOrganizationName}/${GithubRepoName}"

[ordered]@{
    SUBSCRIPTION_ID = $SubscriptionId
    CLIENT_ID = $uami.ClientId
    TENANT_ID = $uami.TenantId
} | ConvertTo-Json