function PS-MassEncScript
{

<#
.SYNOPSIS

Mass encrypt all text files/scripts from specified directory.

Author: Karn Ganeshen
License: BSD 3-Clause
Required Dependencies: PowerSploit's Out-EncryptedScript
Optional Dependencies: None

.DESCRIPTION

PS-MassEncScript will encrypt all scripts present in the specified directory. The new, encrypted files will be saved out to the directory as <filename>_evil.ps1.

.PARAMETER ScriptPath

Path to the scripts directory

.PARAMETER Password

Password to encrypt/decrypt the scripts

.PARAMETER Salt

Salt value for encryption/decryption. This can be any string value.

Description
-----------
PS-MassEncScript is a wrapper script based upon PowerSploit's Out-EncryptedScript (Thanks Matthew Graeber (@mattifestation)!). This script extends Out-EncryptedScript's functionality to encrypt multiple PowerShell scripts quickly.

Use this script to encrypt all file(s) present in a directory & its sub-directories, with a password and salt. This will make analysis of the scripts impossible without the correct password and salt combination.


.EXAMPLE

The script will first import the PowerSploit's Out-EncryptedScript.ps1. It should be in system's Powershell module path, else file path will need to be provided on command-line.

PS C:\> Import-Module C:\PS-MassEncScript.ps1
PS C:\> PS-MassEncScript C:\Out-EncryptedScript.ps1 C:\scripts\ password salty
PS C:\> dir .\scripts\


    Directory: C:\scripts


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---          9/9/2016  12:06 PM       8863 Get-LSASecret.ps1
-a---         9/10/2016   6:37 PM      12809 Get-LSASecret_evil.ps1
-a---          9/9/2016  11:46 AM      14948 Get-PassHashes.ps1
-a---         9/10/2016   6:37 PM      20925 Get-PassHashes_evil.ps1
-a---          9/9/2016  11:38 AM    1271440 Invoke-Mimikatz.ps1
-a---         9/10/2016   6:37 PM    1696253 Invoke-Mimikatz_evil.ps1

Note: The script will remove any existing _evil.ps1 files before starting the encryption run.

.NOTES

Use this PS script to quickly encrypt multiple text-based file/scripts from a directory.

#>

[CmdletBinding()] param(
	[Parameter(Position = 0, Mandatory = $False)]
	[string]
	$OutEncryptedScriptPath,

	[Parameter(Position = 1, Mandatory = $True)]
	[string]
	$ScriptPath,

        [Parameter(Position = 2, Mandatory = $True)]
        [String]
        $Password,
    
        [Parameter(Position = 3, Mandatory = $True)]
        [String]
        $Salt
)

Import-Module $OutEncryptedScriptPath

# Clean up any left-over *_evil.ps1 files
Get-ChildItem -Path $ScriptPath -Filter "*_evil.ps1" | Remove-Item

$EvilScripts = Get-ChildItem -Path $ScriptPath -Filter "*.ps1" | Select-Object -ExpandProperty BaseName

foreach ($Script in $EvilScripts) {

	# In case *_evil.ps1 already exists, remove them
	if (Test-Path .\evil.ps1) {
		Remove-Item .\evil.ps1
	}
 
	Out-EncryptedScript $ScriptPath\$Script.ps1 $Password $Salt
	Move-Item .\evil.ps1 $ScriptPath
	Rename-Item $ScriptPath\evil.ps1 $ScriptPath\"$Script"_evil.ps1	
	Write-Verbose "$Script.ps1 encrypted."
}

Write-Verbose "Decrypt using PS-DecScript.ps1."
}