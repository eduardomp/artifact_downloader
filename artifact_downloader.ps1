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

param([string]$Repo = "", [string]$Branch = "")

try {
    if ($Repo -eq "") { $Repo = read-host "Enter repository url" }
    if ($Branch -eq "") { $Branch = read-host "Enter branch name" }

    "Repository: $Repo"
    "Branch: $Branch"


    
    exit 0 # success
}
catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
    exit 1
}