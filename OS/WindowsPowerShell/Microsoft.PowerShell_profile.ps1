############################################################################
# System
############################################################################

function catfact {
    ( New-Object -com SAPI.SpVoice ).speak(( Invoke-RestMethod -Uri 'https://catfact.ninja/fact' ).fact )
}

function profile {
	code $PROFILE
}



# from chatpgt lol
function run_as_admin {
    param(
        [string]$Command
    )
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$Command`"" -Verb RunAs
}





# source: https://stackoverflow.com/a/21209726
function Copy-WithProgress {
    [CmdletBinding()]
    param (
            [Parameter(Mandatory = $true)]
            [string] $Source
        , [Parameter(Mandatory = $true)]
            [string] $Destination
        , [int] $Gap = 200
        , [int] $ReportGap = 2000
    )
    # Define regular expression that will gather number of bytes copied
    $RegexBytes = '(?<=\s+)\d+(?=\s+)';

    #region Robocopy params
    # MIR = Mirror mode
    # NP  = Don't show progress percentage in log
    # NC  = Don't log file classes (existing, new file, etc.)
    # BYTES = Show file sizes in bytes
    # NJH = Do not display robocopy job header (JH)
    # NJS = Do not display robocopy job summary (JS)
    # TEE = Display log in stdout AND in target log file
    $CommonRobocopyParams = '/MIR /NP /NDL /NC /BYTES /NJH /NJS';
    #endregion Robocopy params

    #region Robocopy Staging
    Write-Verbose -Message 'Analyzing robocopy job ...';
    $StagingLogPath = '{0}\temp\{1} robocopy staging.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss');

    $StagingArgumentList = '"{0}" "{1}" /LOG:"{2}" /L {3}' -f $Source, $Destination, $StagingLogPath, $CommonRobocopyParams;
    Write-Verbose -Message ('Staging arguments: {0}' -f $StagingArgumentList);
    Start-Process -Wait -FilePath robocopy.exe -ArgumentList $StagingArgumentList -NoNewWindow;
    # Get the total number of files that will be copied
    $StagingContent = Get-Content -Path $StagingLogPath;
    $TotalFileCount = $StagingContent.Count - 1;

    # Get the total number of bytes to be copied
    [RegEx]::Matches(($StagingContent -join "`n"), $RegexBytes) | % { $BytesTotal = 0; } { $BytesTotal += $_.Value; };
    Write-Verbose -Message ('Total bytes to be copied: {0}' -f $BytesTotal);
    #endregion Robocopy Staging

    #region Start Robocopy
    # Begin the robocopy process
    $RobocopyLogPath = '{0}\temp\{1} robocopy.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss');
    $ArgumentList = '"{0}" "{1}" /LOG:"{2}" /ipg:{3} {4}' -f $Source, $Destination, $RobocopyLogPath, $Gap, $CommonRobocopyParams;
    Write-Verbose -Message ('Beginning the robocopy process with arguments: {0}' -f $ArgumentList);
    $Robocopy = Start-Process -FilePath robocopy.exe -ArgumentList $ArgumentList -Verbose -PassThru -NoNewWindow;
    Start-Sleep -Milliseconds 100;
    #endregion Start Robocopy

    #region Progress bar loop
    while (!$Robocopy.HasExited) {
        Start-Sleep -Milliseconds $ReportGap;
        $BytesCopied = 0;
        $LogContent = Get-Content -Path $RobocopyLogPath;
        $BytesCopied = [Regex]::Matches($LogContent, $RegexBytes) | ForEach-Object -Process { $BytesCopied += $_.Value; } -End { $BytesCopied; };
        $CopiedFileCount = $LogContent.Count - 1;
        Write-Verbose -Message ('Bytes copied: {0}' -f $BytesCopied);
        Write-Verbose -Message ('Files copied: {0}' -f $LogContent.Count);
        $Percentage = 0;
        if ($BytesCopied -gt 0) {
           $Percentage = (($BytesCopied/$BytesTotal)*100)
        }
        Write-Progress -Activity Robocopy -Status ("Copied {0} of {1} files; Copied {2} of {3} bytes" -f $CopiedFileCount, $TotalFileCount, $BytesCopied, $BytesTotal) -PercentComplete $Percentage
    }
    #endregion Progress loop

    #region Function output
    [PSCustomObject]@{
        BytesCopied = $BytesCopied;
        FilesCopied = $CopiedFileCount;
    };
    #endregion Function output
}




#-------------------------------------------------------------------------------------------------------------------
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




<#
Calling `gap` makes 50 newlines. Calling `gap n`, where n is an integer, creates n newlines.
(Meant as an alternative to 'clear' that creates space but doesn't lose all history)
#>
function gap {
    param (
        [int]$count = 50
    )

    for ($i = 1; $i -le $count; $i++) {
        Write-Host
    }
}





function ce {
    explorer .
    code .
}




#-------------------------------------------------------------------------------------------------------------------
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





#-------------------------------------------------------------------------------------------------------------------
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







# see https://stackoverflow.com/a/34905638
function symlink ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target
}













############################################################################
# Movement
############################################################################


function gotosync {
	cd C:\Users\Eris\Documents\sync_local
}
function gohome {
	cd C:\Users\Eris\Documents\sync_local
}




#-------------------------------------------------------------------------------------------------------------------

<#
function gotomars {
	# cd D:\sync\01_Research\Mars_Magnetics # if on D:sync partition
	cd C:\Users\Eris\Documents\sync_local\01_Research\Mars_Magnetics # if on local
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
#>



#-------------------------------------------------------------------------------------------------------------------
<#
Go to mars repository, activate mamba environment, and launch jupyter lab

Usage:
	`launchmars 4` -- final integer argument "4" simply changes which mamba environment gets activated
#>
<#
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
#>









############################################################################
# Mamba
############################################################################







function mamba-help {
	Write-Host ""
    Write-Host ""
    Write-Host "Useful/frequent Mamba commands:"
    Write-Host ""
    Write-Host "--------------"
    Write-Host "[1] PEEK" -ForegroundColor Cyan
    Write-Host "--------------"
    Write-Host ""
    Write-Host "- See available envs:"
    Write-Host "`t" -NoNewline; Write-Host 'mamba env list' -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------"
    Write-Host "[2] CREATE" -ForegroundColor Cyan
    Write-Host "--------------"
    Write-Host ""
    Write-Host "- New env, from file (preferred):"
    Write-Host "`t" -NoNewline; Write-Host 'mamba env create --file [.yaml]' -ForegroundColor Green
    Write-Host ""
    Write-Host "- New env, from names:"
    Write-Host "`t" -NoNewline; Write-Host 'mamba create -n [envname] [jupyter*] [pkg1] [pkg2] ...' -ForegroundColor Green
    Write-Host ""
    Write-Host "* NOTE: remember to add " -NoNewline; Write-Host "jupyter" -ForegroundColor Green -NoNewline; Write-Host " if using vscode notebooks"
    Write-Host ""
    Write-Host "--------------"
    Write-Host "[3] EXPORT" -ForegroundColor Cyan
    Write-Host "--------------"
    Write-Host ""
    Write-Host "- Export packages + versions to file ('environment.yaml' should be handwritten, never install purely from CLI, be declarative!!!):"
    Write-Host "`t" -NoNewline; Write-Host 'mamba env export -f environment-explicit.yaml' -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------"
    Write-Host "[4] DELETE" -ForegroundColor Cyan
    Write-Host "--------------"
    Write-Host ""
    Write-Host "- Delete:" 
    Write-Host "`t" -NoNewline; Write-Host 'mamba remove -n [envname] --all' -ForegroundColor Green
    Write-Host ""
    Write-Host "- Clean caches (run this periodically):"
    Write-Host "`t" -NoNewline; Write-Host 'mamba clean --all --yes' -ForegroundColor Green
    Write-Host ""
    Write-Host "--------------"
    Write-Host "[5] INSTALL" -ForegroundColor Cyan
    Write-Host "--------------"
    Write-Host ""
    Write-Host "- Install local package as editable (requires pip):" 
    Write-Host "`t" -NoNewline; Write-Host 'pip install -e .' -ForegroundColor Green
    Write-Host ""
    Write-Host ""
}








#-------------------------------------------------------------------------------------------------------------------
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
	
	# Remove prefix (added by default to last line)
	$output = $output | Select-Object -SkipLast 1

	# Concatenate (THIS TOOK ME A FUCKING HOUR FUCK POWERSHELL GARBAGE FUCKING LANGAUGE)
	$output = $comment + ($output | Out-String)
	
	# Save
	$envName = (Get-ChildItem Env:\CONDA_DEFAULT_ENV).Value
    $date = Get-Date -Format "yyMMdd_HHmm"
    $filename = "environment--$date--$envName.yml"
	$output | Out-File -FilePath $filename -Encoding UTF8
	
}




#-------------------------------------------------------------------------------------------------------------------
<#
this is bugged, doesn't get rid of last line with explicit path
function exportenv_nocomment {
    $envName = (Get-ChildItem Env:\CONDA_DEFAULT_ENV).Value
    $date = Get-Date -Format "yyMMdd_HHmm"
    $filename = "environment--$date--$envName.yml"
    mamba env export --from-history > $filename
    Write-Host "Exported Mamba environment to $filename"
}
>#
















#-------------------------------------------------------------------------------------------------------------------
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









# ############################################################################ #
#                                   Shortcuts                                  #
# ############################################################################ #


#-------------------------------------------------------------------------------------------------------------------
<#
chris titus's winutil script
#>
function winutil {
    run_as_admin "irm https://christitus.com/win | iex"
}





#-------------------------------------------------------------------------------------------------------------------
<#
launches monitored interval pomodoro script
#>
function pomo {
    mamba activate pomo1
    cd C:\Users\Eris\Documents\sync_local\04_Personal\software\desktop\interval_pomodoro
    clear
    python interval_pomodoro.py
}







#-------------------------------------------------------------------------------------------------------------------
<#
modifying autohotkey code
#>
function autohotkey {
    cd C:\Users\Eris\Documents\sync_local\00_Local\software\autohotkey\
    explorer .
    code .
}



#-------------------------------------------------------------------------------------------------------------------
<#
zoxide (MUST BE AT END OF PROFILE) — see https://github.com/ajeetdsouza/zoxide
#>
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })

rclone completion powershell | Out-String | Invoke-Expression
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
