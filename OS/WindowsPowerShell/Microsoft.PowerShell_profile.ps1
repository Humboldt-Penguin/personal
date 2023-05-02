############################################################################
# System
############################################################################



#---------------------------------------------------------------------------
<#
Move prompt input to newline

More examples available here:
	https://superuser.com/questions/446827/configure-windows-powershell-to-display-only-the-current-folder-name-in-the-shel
#>
function prompt {
	# "PS " + (Get-Location) + "\`n$ "
	Write-Host ("PS " + (Get-Location) + "\")
	Write-Host "$" -NoNewline -ForegroundColor Green
	" "
	
}


<#
Open notepad++ to edit a file
#>
function vi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $file = ""
    )
	
	& "C:\Program Files\Notepad++\notepad++.exe" $file

}




#---------------------------------------------------------------------------
<#
Better "ls"
#>
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



	#################
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





#---------------------------------------------------------------------------
<#
Found on this blog post: https://blog.cpolydorou.net/2019/01/get-filesystem-hierarchy-using.html
Copied from this file: https://www.powershellgallery.com/packages/CPolydorou.General/2.13.2/Content/General.psm1
#>
function print-tree
{
    #region Parameters
    [cmdletBinding()]

    Param
    (
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $Path = (Get-Location).Path,

        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $IncludeType,

        [Parameter(
            Mandatory = $false
        )]
        [string]
        $Indentation = "`t",

        [Parameter(
            Mandatory = $false
        )]
        [int]
        $MaxDepth = [int]::MaxValue
    )

    Begin
    {
        Function _RecursiveDisplayTree
        {
            Param
            (
                $RecursivePath,
                $Depth,
                $IncludeItemType,
                $IndentationString,
                $MaximumDepth
            )

            # Check the current depth
            if($Depth -ge $MaximumDepth)
            {
                Write-Verbose "Maximum depth $MaximumDepth was reached."
                return
            }

            # Get the files
            Get-ChildItem -Path $RecursivePath -File -Force |
                %{
                    if($IncludeItemType -eq $true)
                    {
                        ($IndentationString * $Depth) + "[F] " + $_.Name
                    }
                    else
                    {
                        ($IndentationString * $Depth) + $_.Name
                    }
                }

            # Process directories
            Get-ChildItem -Path $RecursivePath -Directory -Force |
                %{
                    if($IncludeItemType -eq $true)
                    {
                        ($IndentationString * $Depth) + "[D] " + $_.Name
                    }
                    else
                    {
                        ($IndentationString * $Depth) + $_.Name
                    }

                    _RecursiveDisplayTree -RecursivePath $_.FullName `
                                          -Depth ($Depth + 1) `
                                          -IncludeItemType $IncludeItemType `
                                          -IndentationString $IndentationString `
                                          -MaximumDepth $MaximumDepth
                }
        }
    }

    Process
    {
        if( (Test-Path -Path $Path) -ne $true)
        {
            Write-Error "Could not find folder $Path"
        }
        else
        {
            $fullPath = Resolve-Path -Path $Path

            _RecursiveDisplayTree -RecursivePath $fullPath.Path `
                                  -Depth 0 `
                                  -IncludeItemType ($MyInvocation.BoundParameters["IncludeType"].IsPresent -eq $true) `
                                  -IndentationString $Indentation `
                                  -MaximumDepth $MaxDepth
        }
    }

    End {}
}










############################################################################
# Mars research
############################################################################


#---------------------------------------------------------------------------
function gotomars {
	# cd D:\sync\01_Research\Mars_Magnetics # if on D:sync partition
	cd C:\Users\Eris\Documents\sync_local\01_Research\Mars_Magnetics # if on local
}


<#
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
#>




#---------------------------------------------------------------------------
<#
Go to mars repository, activate mamba environment, and launch jupyter lab

Usage:
	`launchmars 4` -- final integer argument "4" simply changes which mamba environment gets activated
#>
function launchmars {
    param (
        [Parameter(Mandatory=$true)]
        [int]$n
    )

    try {
        $envName = "mars" + $n
        gotomars
        mamba activate $envName
        jupyter lab --ContentsManager.allow_hidden=True
    }
    catch {
        Write-Error $_
        Break
    }
}










############################################################################
# Mamba
############################################################################



#---------------------------------------------------------------------------
<#
Takes the current environment and writes a YAML file to the current directory containing the packages manually installed by the user.

Usage:
	`exportenv "mars1 + pandas for crater databases"` -- final string specifies comment at the top of the YAML file.
#>
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




#---------------------------------------------------------------------------
function exportenv_nocomment {
    $envName = (Get-ChildItem Env:\CONDA_DEFAULT_ENV).Value
    $date = Get-Date -Format "yyMMdd_HHmm"
    $filename = "environment--$date--$envName.yml"
    mamba env export --from-history > $filename
    Write-Host "Exported Mamba environment to $filename"
}






#---------------------------------------------------------------------------
<#
Generates HTML documentation for a module (class) in the current folder.


I stopped using pdoc because it doesn't work when a local class is using another local class (i.e. I want to generate documentation for GRS.py, but GRS.py has `from lib.Utils import Utils` -- this throws an error). Plus pdoc is kind of ugly for more complicated stuff lol. fml.
#>
<#
function make-docs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $directory
    )
	
	pdoc3 --html -o . $directory
}
#>