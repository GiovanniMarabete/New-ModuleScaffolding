function New-ModuleStructure () {
<#
  .SYNOPSIS
  Put here your synopsis
  
  .DESCRIPTION
  Put here your description 
  
  .INPUTS
  Put here your inputs 
  
  .OUTPUTS
  Put here your inputs
  
  .EXAMPLE
  Example 1 - Simple use
  
  
  .EXAMPLE
  Example 2 - Passing to another object in the pipeline

  .PARAMETER Param1
  This param does this thing.
  
  .LINK
  Put here your links 
  
#>
[CmdletBinding()]
    param(
        [Parameter (Mandatory = $true, HelpMessage = "Provide the path where to create the structure")]
        [string]$Path = 'D:\Kimiki\Documents\Code\PowerShell',
        [Parameter (Mandatory = $True, HelpMessage = "Provide the name of the module")]
        [string]$ModuleName = 'Test-Module',
        [Parameter (Mandatory = $false, HelpMessage = "Provide the name of the author")]
        [string]$Author = 'Giovanni Marabete',
        [Parameter (Mandatory = $false, HelpMessage = "Provide a description for the module")]
        [string]$Description = 'Function to Create basic POSH Module Structure'
)

if ($(Test-Path $Path\$ModuleName) -eq $false) {

    # Create the module and private function directories
    New-Item $Path\$ModuleName -ItemType Directory
    New-Item $Path\$ModuleName\Private -ItemType Directory
    New-Item $Path\$ModuleName\Public -ItemType Directory
    New-Item $Path\$ModuleName\en-US -ItemType Directory # For about_Help files
    New-Item $Path\$ModuleName\Tests -ItemType Directory
    New-Item $Path\$ModuleName\Resources -ItemType Directory
    
    #Create the module and related files
    New-Item "$Path\$ModuleName\$ModuleName.psm1" -ItemType File

    # Content of the psm1 file

    $contetpsm1 = @"

    #Get public and private function definition files.
    `$Public = @(Get-ChildItem -Path `$PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
    `$Private = @(Get-ChildItem -Path `$PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

    #Dot source the files
    Foreach (`$import in @(`$Public + `$Private)) {
	    Try	{
	        . `$import.fullname
	    }
	    Catch {
		    Write-Error -Message "Failed to import function `$(`$import.fullname): `$_"
	    }
    }

    # Export all the functions
    Export-ModuleMember -Function `$Public.Basename -Alias *

"@

    $contetpsm1 | out-file -Encoding ascii -FilePath "$Path\$ModuleName\$ModuleName.psm1" -Append



    New-Item "$Path\$ModuleName\$ModuleName.Format.ps1xml" -ItemType File
    New-Item "$Path\$ModuleName\en-US\about_$ModuleName.help.txt" -ItemType File
    New-Item "$Path\$ModuleName\Tests\$ModuleName.Tests.ps1" -ItemType File

    #define Manifest properties
    $manifest = @{
        Path = "$Path\$ModuleName\$ModuleName.psd1"
        RootModule = "$ModuleName.psm1"
        Description = "$Description"
        PowerShellVersion = "3.0"
        Author = "$Author"
        FormatsToProcess = "$ModuleName.Format.ps1xml"
    
    }
    New-ModuleManifest @manifest
    }
else {
    Write-Output "The folder $Path\$ModuleName already exists !!!"
    }
}

#To Check the OS where POSH is running
$IsMacOS
$IsLinux
$IsWindows