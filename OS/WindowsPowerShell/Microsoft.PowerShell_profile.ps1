function gotomars {
	# cd D:\sync\01_Research\Mars_Magnetics # if on D:sync partition
	cd C:\Users\Eris\Documents\sync_local\01_Research\Mars_Magnetics # if on local
}

function exportenv_nocomment {
    $envName = (Get-ChildItem Env:\CONDA_DEFAULT_ENV).Value
    $date = Get-Date -Format "yyMMdd_HHmm"
    $filename = "environment--$date--$envName.yml"
    mamba env export --from-history > $filename
    Write-Host "Exported Mamba environment to $filename"
}

function launchmars1 {
	gotomars
	mamba activate mars1
	jupyter lab  --ContentsManager.allow_hidden=True
}

function launchmars2 {
	gotomars
	mamba activate mars2
	jupyter lab  --ContentsManager.allow_hidden=True
}

function launchmars3 {
	gotomars
	mamba activate mars3
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


# Move prompt input to newline
function prompt {
	"PS " + (Get-Location) + "\`n> "
	
	# more examples available here: https://superuser.com/questions/446827/configure-windows-powershell-to-display-only-the-current-folder-name-in-the-shel
}

# Better "ls"

Remove-Item Alias:ls

function ls {

	Get-ChildItem | Format-Table -HideTableHeaders -Property `
		@{ `
			Name="Name"; `
			Expression={
				if($_.PSIsContainer){
					$_.Name + ("/       ")
				}
				else{
					$_.Name + ("       ")
				}
			}; `
			Width=50
		},
		@{ `
			Name="LastWriteTime"; `
			Expression={
				[string]($_.LastWriteTime) + ("       ")
			}; `
			Width=30
		},
		@{ `
			Name="Length (MB)"; `
			Expression={
				[string]([math]::Round($_.Length/1MB)) + " MB"
			}
		}



	#############################################################
	## other options
	
	
	<#
	Get-ChildItem | Format-Table -HideTableHeaders -Property `
		@{ `
			Name="Name"; `
			Expression={
				if($_.PSIsContainer){
					$_.Name + ("/       ")
				}
				else{
					$_.Name + ("       ")
				}
			}; `
			Width=50
		},
		@{ `
			Name="LastWriteTime"; `
			Expression={
				[string]($_.LastWriteTime) + ("       ")
			}; `
			Width=30
		},
		@{ `
			Name="Length (MB)"; `
			Expression={
				[string]([math]::Round($_.Length/1MB)) + " MB"
			}
		}
	#>
	
	
	<#
	Get-ChildItem | Format-Table -HideTableHeaders -Property @{Name="Name";Expression={$_.Name};Width=40}, @{Name="LastWriteTime";Expression={$_.LastWriteTime};Width=25}, @{Name="Length (MB)";Expression={[math]::Round($_.Length/1MB)};Width=15}
	#>


	<#
	Get-ChildItem | Format-Table -HideTableHeaders -Property @{Name="Name";Expression={$_.Name + ("   ")};Width=40}, @{Name="LastWriteTime";Expression={$_.LastWriteTime};Width=25}, @{Name="Length (MB)";Expression={[math]::Round($_.Length/1MB)};Width=15} -Wrap
	#>

}