#Set CSV paths
$EduHubCSVPath = '\\tscdc01\eduhub$\ST_8370.csv' #EduHub Students table
$EduPassCSVPath = '.\8370_students.csv' #eduPass: eduSTAR.MC > Access Managemnt > Student Passwords > Export 
$PwdResetCSVPath = '.\8370_pwd_reset_log_yr8.csv' #eduPass: eduSTAR.MC > Access Managemnt > Student Passwords > Reset Password - by year/class 
$NewEduPassCSVPath = '.\8370_pwd_reset_log_yr8_new.csv' #Export CSV

#Import CSVs
$EduPassUsers = Import-Csv -Delimiter "," -Path $EduPassCSVPath
$EduHubUsers = Import-Csv -Delimiter "," -Path $EduHubCSVPath | Where-Object {$_.STATUS -Match 'FUT|ACTV|INAC|LVNG'} 
$PwdResetUsers = Import-Csv -Delimiter "," -Path $PwdResetCSVPath

#Create empty array
$NewEduPassCSV = @()

#PwdReset loop
ForEach ($PwdResetUser In $PwdResetUsers)
    {
    $PwdResetFirstName = $PwdResetUser.'First Name'
    $PwdResetLastName = $PwdResetUser.'Last Name'
    $PwdResetNewPassword = $PwdResetUser.'New Password'
    $PwdResetLogin = $PwdResetUser.'Login'.ToUpper()
    $PwdResetYear = $EduPassUsers | Where-Object {$_.'login' -Eq $PwdResetUser.'Login'} | Select-Object -ExpandProperty 'year' #Match EduPass Year using login as key
    $PwdResetGroup = $EduPassUsers | Where-Object {$_.'login' -Eq $PwdResetUser.'Login'} | Select-Object -ExpandProperty 'student_class' #Match EduPass Group using login as key

    #EduHub loop
    ForEach ($EduHubUser In $EduHubUsers)
        {
        $EduHubFirstName = $EduHubUser.'FIRST_NAME'
        $EduHubLastName = $EduHubUser.'SURNAME'
        $EduHubLogin = $EduHubUser.'STKEY'
        $EduHubYear = $EduHubUser.'SCHOOL_YEAR'
        $EduHubGroup = $EduHubUser.'HOME_GROUP'

        #Match between EduHub and Password Reset Log
        If (($EduHubFirstName -Ieq $PwdResetFirstName) -And ` #FirstName
            ($EduHubLastName -Ieq $PwdResetLastName) -And #LastName
            ($EduHubYear -Eq $PwdResetYear) -And ` #Year Level   
            ($PwdResetNewPassword -NotMatch 'is disabled. Skipped.')) # Disabled
                {
                #Output data to array
                $NewEduPassCSV += New-Object psobject -Property `
                    @{'Login'=$PwdResetLogin;
                    'First Name'=$PwdResetFirstName;
                    'Last Name'=$PwdResetLastName;
                    'New Password'=$PwdResetNewPassword;
                    'STKEY'=$EduHubLogin;
                    'Home Group'=$PwdResetGroup;
                    'Year Level'=$PwdResetYear
                }
            }
        }
    }

#Format objects
$NewEduPassCSV = $NewEduPassCSV | Select-Object -Property 'Login','First Name','Last Name','New Password','STKEY','Home Group','Year Level'

#Write data to screen
$NewEduPassCSV | Format-Table 

#Export array to CSV
$NewEduPassCSV | Export-Csv -Delimiter "," -NoTypeInformation -Path $NewEduPassCSVPath
