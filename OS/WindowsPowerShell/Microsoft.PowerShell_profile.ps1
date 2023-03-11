function gotomars {
	cd D:\sync\01_Research\Mars_Magnetics
}

function exportenv_nocomment {
    $envName = (Get-ChildItem Env:\CONDA_DEFAULT_ENV).Value
    $date = Get-Date -Format "yyMMdd_HHmm"
    $filename = "environment--$date--$envName.yml"
    mamba env export --from-history > $filename
    Write-Host "Exported Mamba environment to $filename"
}

function launchmars {
	gotomars
	mamba activate mars1
	jupyter lab  --ContentsManager.allow_hidden=True
}

function exportenv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string] $comment = ""
    )
	
	$output = & mamba env export --from-history
		
    # If comment is specified, format it as a comment
    if ($comment -ne "") {
        $comment = "# $comment`r`n`r`n"
    }
	
	# Concatenate (THIS TOOK ME A FUCKING HOUR FUCK POWERSHELL GARBAGE FUCKING LANGAUGE)
	$output = $comment + ($output | Out-String)
	
	# Save
	$envName = (Get-ChildItem Env:\CONDA_DEFAULT_ENV).Value
    $date = Get-Date -Format "yyMMdd_HHmm"
    $filename = "environment--$date--$envName.yml"
	$output | Out-File -FilePath $filename -Encoding UTF8
	
}