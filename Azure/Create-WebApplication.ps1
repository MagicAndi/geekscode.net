# =============================================================================
#
# Script Name: 		Create-WebApplication
#
# Author: 			Andy Parkhill
#
# Date Created: 	07/09/2018
#
# Description: 		Script to create a basic web application.
#
# Usage:            .\Create-WebApplication.ps1
#
# =============================================================================


# =============================================================================
# Parameters
# =============================================================================
Param
(
	[Parameter(Position=0, Mandatory=$false, HelpMessage='Azure subscription to use')]
    [string] $AzureSubscription = "Visual Studio Enterprise with MSDN"
)

# =============================================================================
# Import Modules
# =============================================================================
Import-Module Azure
Import-Module AzureRm

# =============================================================================
# Constants
# =============================================================================
Set-Variable ScriptName -option Constant -value "Create-WebApplication" 

# =============================================================================
# Script Variables
# =============================================================================
$ErrorActionPreference = "Stop"

Set-Variable -name resourceGroupName -value "GeeksCode" -scope Script
Set-Variable -name resourceLocation -value "North Europe" -scope Script
Set-Variable -name servicePlanName -value "GeeksCodeServicePlan" -scope Script
Set-Variable -name webAppName -value "GeeksCode" -scope Script

# =============================================================================
# Functions
# =============================================================================

function Add-ResourceGroup
{
    param
    (
        [string] $name,
        [string] $location
    )

    $resourceGroup = Get-AzureRmResourceGroup -ResourceGroupName $name -ErrorAction SilentlyContinue
                        
    if(!$resourceGroup)
    {
        Write-Host "Creating the resource group $name."
        New-AzureRmResourceGroup -Name $name -Location $location
    }
}

function Add-ServicePlan
{
    param
    (
        [string] $name,
        [string] $resourceGroupName,
        [string] $location
    )

    $servicePlan = Get-AzureRmAppServicePlan -Name $name -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                        
    if(!$servicePlan)
    {
        Write-Host "Creating the service plan $name."
        # Note we use the Standard tier in this case as this tier offers deployment slots...
        New-AzureRmAppServicePlan -ResourceGroupName $resourceGroupName -Name $name -Location $location -Tier "Standard" -NumberOfWorkers 2 -WorkerSize "Small"
    }
}

function Add-WebApplication
{
    param
    (
        [string] $name,
        [string] $resourceGroupName,
        [string] $servicePlanName,
        [string] $location
    )

    $webApp = Get-AzureRmWebApp -Name $name -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
                        
    if(!$webApp)
    {
        Write-Host "Creating the web application $name."
        New-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name $name -Location $location -AppServicePlan $servicePlanName
    }
}

function Main
{
    Login-AzureRMAccount | Out-Null 
    Select-AzureRmSubscription -SubscriptionName $AzureSubscription | Out-Null 

    Write-Host "Selected subscription $AzureSubscription"
    # Get-AzureRmContext # Check that correct subscription has been selected

    Add-ResourceGroup -name $Script:resourceGroupName -location $Script:resourceLocation
    Add-ServicePlan -name $Script:servicePlanName -resourceGroupName $Script:resourceGroupName -location $Script:resourceLocation
    Add-WebApplication -name $Script:webAppName -servicePlanName $Script:servicePlanName -resourceGroupName $Script:resourceGroupName -location $Script:resourceLocation
}

# =============================================================================
# Start of Script Body
# =============================================================================

# cls
$timeStamp= (Get-Date).ToString("HH:mm dd/MM/yyyy")
Write-Host "Starting $ScriptName at $timeStamp"
$scriptTimer = [System.Diagnostics.Stopwatch]::StartNew()

Main

$elapsedTimeInseconds = $scriptTimer.ElapsedMilliseconds / 1000
$message = [string]::Format("Script total execution time: {0} seconds", $elapsedTimeInseconds)
Write-Host $message

Write-Host
Write-Host "Exiting $ScriptName"

# =============================================================================
# End of Script Body
# =============================================================================