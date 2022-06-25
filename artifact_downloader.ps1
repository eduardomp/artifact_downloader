<#
.SYNOPSIS
	List artifacts from past workflows executions to download
.DESCRIPTION
	List all past artifacts from github actions workflow by passing repo and branch flags
    and gives you option to select one of these artifacts to download
.PARAMETER Repo
    Specifies the GitHub repository
.PARAMETER Branch
	Specifies the new branch name
.EXAMPLE
	PS> ./artifact_downloader https://github.com/... branchName
.LINK
	https://github.com/eduardomp/artifact_downloader
.NOTES
	Author: Eduardo Medeiros Pereira <edu.medeirospereira@gmail.com>
#>

param([string]$Repo = "", [string]$Branch = "", [string]$limit = "")

try {

    if (Get-Module -ListAvailable -Name PS-Menu) {
        "✅ PS-Menu module installed..."
    }
    else {
        "🚨 PS-Menu not installed, installing..."
        Install-Module PS-Menu -Force -Confirm:$False
    }


    if (Get-Command "gh" -errorAction SilentlyContinue) {
        "✅ gh cli present..."
    }

    $ghLoginStatus = (gh auth status) 2>&1

    if ($ghLoginStatus -like "You are not logged*") {
        throw "gh is not logged in any github account, please run 'gh auth login' to authenticate first!"
    }

    if ($Repo -eq "") { $Repo = read-host "Enter repository url" }
    if ($Branch -eq "") { $Branch = read-host "Enter branch name" }

    if ($Repo -eq "") { throw "Repository argument is mandatory!" }
    if ($Branch -eq "") { throw "Branch argument is mandatory!" }

    if ($limit -eq "") { $limit = 15 }

    "⏳ Searching in the last $limit most recent workflows executions for valid artifacts..."

    $ghWorkflows = (gh run list -L $limit --json "createdAt,name,event,databaseId" --repo $Repo --branch $Branch ) | ConvertFrom-Json

    $runsWithArtifact = [System.Collections.ArrayList]@()
    
    #filtering workflows that contains artifacts
    foreach ($workflow in $ghWorkflows) {

        $runOutput = (gh run view $workflow.databaseId --repo $Repo) 

        if ($runOutput -contains "ARTIFACTS" && $runOutput -notcontains "expired") {
            $out = $runsWithArtifact.add($workflow) 
        }
    }

    "📋 Choose the workflow run to download the related artifacts"
    
    $selection = Menu @($runsWithArtifact)

    "⬇️ Downloading..."

    gh run download $selection.databaseId --repo $Repo -v
    
    "✅ All done!"

    exit 0 # success
}
catch {
    "[🚨 Error] Line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}