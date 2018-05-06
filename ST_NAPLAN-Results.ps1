<#
.SYNOPSIS
    Convert Compass OnDemand export from a former school to new school.
.DESCRIPTION
   Perform an export on OnDemand data following the Compass guide from a former school.
   The student key in the export from the former school won't match student key of the new school.
   Use this script with the eduHub ST_xxxx.csv files of both schools to convert student cNAPes with matching VSN numbers.
.NOTES
    File Name      : ST_NAPLAN-Results.ps1
    Author         : T Wyatt (wyatt.tyrone.e@edumail.vic.gov.au)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : 2018 - Tyrone Wyatt / Department of Education Victoria
.LINK
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/
.EXAMPLE
    .\ST_NAPLAN-Results.ps1 
.EXAMPLE
    .\ST_NAPLAN-Results.ps1 -oldschoolid 6229 -newschoolid 8370 
.EXAMPLE
    .\ST_NAPLAN-Results.ps1 -oldschoolid 6229 -newschoolid 8370
 #>
Param(
	[String]$OldSchoolID = $(Read-Host 'Enter Old School ID (XXXX)'),
	[String]$NewSchoolID = $(Read-Host 'Enter New School ID (XXXX)'),
	[String]$AppendOutPut = $(Read-Host 'Append Out Put CSV (YES/No)')
	)

$Path = (Resolve-Path .\).Path
$OldSTCSV = $Path + '\ST_' + $OldSchoolID + '.csv'
$NewSTCSV = $Path + '\ST_' + $NewSchoolID + '.csv'
$OldNAPCSV = $Path + '\NAP_' + $OldSchoolID + '_Results.csv'
$NewNAPCSV = $Path + '\NAP_' + $NewSchoolID + '_Results.csv'

If (-Not($OldSTCSV | Test-Path))
	{Write-Error "$OldSTCSV not found"}
ElseIf (-Not($NewSTCSV | Test-Path))
	{Write-Error "$NewSTCSV not found"}
ElseIf (-Not($OldNAPCSV | Test-Path))
	{Write-Error "$OldNAPCSV not found"}
Else
	{
	$OldSTStudents = Import-Csv -Delimiter "," -Path $OldSTCSV | Where-Object {$_.STATUS -Match 'LVNG|LEFT' -And $_.SCHOOL_YEAR -Eq '06' -And $_.VSN -NotMatch 'NEW|UNKNOWN'}
	$NewSTStudents = Import-Csv -Delimiter "," -Path $NewSTCSV | Where-Object {$_.STATUS -Match 'FUT|ACTV' -And $_.SCHOOL_YEAR -Eq '07' -And $_.VSN -NotMatch 'NEW|UNKNOWN'} 
	$OldNAPStudents = Import-Csv -Delimiter "," -Path $OldNAPCSV
	}

If ($AppendOutPut -Match 'False|No|0')
	{Clear-Content -Path $NewNAPCSV}
ElseIf ($AppendOutPut -Match 'True|Yes|1')
	{}
Write-Output 'APS Year,Reporting Test,READING_nb,WRITING_nb,SPELLING_nb,NUMERACY_nb,GRAMMAR & PUNCTUATION_nb,Cases ID' | Out-File -FilePath $NewNAPCSV -Append

	
#Write-Host 'OldSTStudentKey NewSTStudentKey NewSTStudentVSN'
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
				ForEach ($OldNAPStudent In $OldNAPStudents)
					{				
					$OldNAPStudentYear = $OldNAPStudent.'APS Year'
					$OldNAPStudentTest = $OldNAPStudent.'Reporting Test'
					$OldNAPStudentREADING = $OldNAPStudent.'READING_nb'
					$OldNAPStudentWRITING = $OldNAPStudent.'WRITING_nb'
					$OldNAPStudentSPELLING = $OldNAPStudent.'SPELLING_nb'
					$OldNAPStudentNUMERACY = $OldNAPStudent.'NUMERACY_nb'
					$OldNAPStudentGRAMPUNC = $OldNAPStudent.'GRAMMAR & PUNCTUATION_nb'
					$OldNAPStudentCasesID = $OldNAPStudent.'Cases ID'
					If ($OldNAPStudentCasesID -Eq $OldSTStudentKey)
						{
						#Write-Host  $OldNAPStudentYear $OldNAPStudentTest $OldNAPStudentREADING $OldNAPStudentWRITING $OldNAPStudentSPELLING $OldNAPStudentNUMERACY $OldNAPStudentGRAMPUNC $NewSTStudentKey
						Write-Output "$OldNAPStudentYear,$OldNAPStudentTest,$OldNAPStudentREADING,$OldNAPStudentWRITING,$OldNAPStudentSPELLING,$OldNAPStudentNUMERACY,$OldNAPStudentGRAMPUNC,$NewSTStudentKey" | Out-File -FilePath $NewNAPCSV -Append
						}
					}
				}
			}
		}
	}
	
	