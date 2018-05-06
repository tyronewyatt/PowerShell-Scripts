<#
.SYNOPSIS
    Convert Compass OnDemand export from a former school to new school.
.DESCRIPTION
   Perform an export on OnDemand data following the Compass guide from a former school.
   The student key in the export from the former school won't match student key of the new school.
   Use this script with the eduHub ST_xxxx.csv files of both schools to convert student codes with matching VSN numbers.
.NOTES
    File Name      : ST_OnDemand-Results.ps1
    Author         : T Wyatt (wyatt.tyrone.e@edumail.vic.gov.au)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : 2018 - Tyrone Wyatt / Department of Education Victoria
.LINK
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/
.EXAMPLE
    .\ST_OnDemand-Results.ps1 
.EXAMPLE
    .\ST_OnDemand-Results.ps1 -oldschoolid 6229 -newschoolid 8370 
 #>
Param(
	[String]$OldSchoolID = $(Read-Host 'Enter Old School ID (XXXX)'),
	[String]$NewSchoolID = $(Read-Host 'Enter New School ID (XXXX)'),
	[String]$AppendOutPut = $(Read-Host 'Append Out Put CSV (YES/No)')
	)

$Path = (Resolve-Path .\).Path
$OldSTCSV = $Path + '\ST_' + $OldSchoolID + '.csv'
$NewSTCSV = $Path + '\ST_' + $NewSchoolID + '.csv'
$OldODCSV = $Path + '\OD_' + $OldSchoolID + '_Results.csv'
$NewODCSV = $Path + '\OD_' + $NewSchoolID + '_Results.csv'

If (-Not($OldSTCSV | Test-Path))
	{Write-Error "$OldSTCSV not found"}
ElseIf (-Not($NewSTCSV | Test-Path))
	{Write-Error "$NewSTCSV not found"}
ElseIf (-Not($OldODCSV | Test-Path))
	{Write-Error "$OldODCSV not found"}
Else
	{
	$OldSTStudents = Import-Csv -Delimiter "," -Path $OldSTCSV | Where-Object {$_.STATUS -Match 'LVNG|LEFT' -And $_.SCHOOL_YEAR -Eq '06' -And $_.VSN -NotMatch 'NEW|UNKNOWN'}
	$NewSTStudents = Import-Csv -Delimiter "," -Path $NewSTCSV | Where-Object {$_.STATUS -Match 'FUT|ACTV' -And $_.SCHOOL_YEAR -Eq '07' -And $_.VSN -NotMatch 'NEW|UNKNOWN'} 
	$OldODStudents = Import-Csv -Delimiter "," -Path $OldODCSV -Header 'STDNT_XID', 'TEST_XID', 'TEST_SCORE', 'csf_score', 'TEST_FNSH_DT_TM'
	}

If ($AppendOutPut -Match 'False|No|0')
	{Clear-Content -Path $NewODCSV}
ElseIf ($AppendOutPut -Match 'True|Yes|1')
	{}
	
Write-Host 'OldSTStudentKey NewSTStudentKey NewSTStudentVSN'
ForEach ($NewSTStudent In $NewSTStudents)
    {
	$NewSTStudentKey = $NewSTStudent.'STKEY'
	$NewSTStudentVSN = $NewSTStudent.'VSN'
	If (($OldSTStudents | Where-Object {$_.VSN -Eq $NewSTStudentVSN}) -Ne $Null)
		{
		ForEach ($OldSTStudent In $OldSTStudents)
			{
			$OldSTStudentKey = $OldSTStudent.'STKEY'
			$OldSTStudentVSN = $OldSTStudent.'VSN'
			If (($NewSTStudents | Where-Object {$OldSTStudentVSN -Eq $NewSTStudentVSN}) -Ne $Null)
				{
				Write-Host "$OldSTStudentKey $NewSTStudentKey $NewSTStudentVSN"
				ForEach ($OldODStudent In $OldODStudents)
					{
					$OldODStudentKey = $OldODStudent.'STDNT_XID'
					$OldODStudentTestID = $OldODStudent.'TEST_XID'
					$OldODStudentTestScore = $OldODStudent.'TEST_SCORE'
					$OldODStudentCSFScore = $OldODStudent.'csf_score'
					$OldODStudentDateTime = $OldODStudent.'TEST_FNSH_DT_TM'
					If ($OldODStudentKey -Eq $OldSTStudentKey)
						{
						#Write-Host $NewSTStudentKey $OldODStudentTestID $OldODStudentTestScore $OldODStudentCSFScore $OldODStudentDateTime
						Write-Output "$NewSTStudentKey,$OldODStudentTestID,$OldODStudentTestScore,$OldODStudentCSFScore,$OldODStudentDateTime" | Out-File -FilePath $NewODCSV -Append
						}
					}
				}
			}
		}
	}
	
	