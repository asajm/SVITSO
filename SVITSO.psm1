



# Import-Module MSOnline

function Get-SVUserAuthMethods {
    param ( $upns )
    $index = 1
    $total = $upns.count
    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        $user | select UserPrincipalName, DisplayName -ExpandProperty StrongAuthenticationMethods | select UserPrincipalName, DisplayName, IsDefault, MethodType
        
        $progress = [math]::Round(100 * $index / $total, 2)
        Write-Progress -Activity "gathering users authentication methods" -Status "$progress% Complete:" -PercentComplete $progress
        $index++
    }
}

function Add-SVCallAuthMethod {
    param ( 
        [Parameter(Mandatory = $true)]
        $upns
    )

    $call_method = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
    $call_method.MethodType = "TwoWayVoiceMobile"
    $call_method.IsDefault = $false

    $index = 1
    $total = $upns.count
    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        if ($user.StrongAuthenticationMethods.count -eq 0) {
            Write-Host "[$upn] has no authentication method!"
            continue
        }
        if ($user.StrongAuthenticationMethods.methodtype -contains "TwoWayVoiceMobile") {
            Write-Host "[$upn] has already call-me option"
            continue
        }
        if ($user.StrongAuthenticationMethods.methodtype -notcontains 'OneWaySMS') {
            Write-Host "[$upn] does not have SMS option"
            continue
        }

        $user.StrongAuthenticationMethods.add($call_method)
        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods $user.StrongAuthenticationMethods

        $progress = [math]::Round(100 * $index / $total, 2)
        Write-Progress -Activity "updating users authentication methods" -Status "$progress% Complete:" -PercentComplete $progress
        $index++
    }
}

function Add-SVSMSAuthMethod {
    param ( 
        [Parameter(Mandatory = $true)]
        $upns
    )
    
    $sms_method = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
    $sms_method.MethodType = "OneWaySMS"
    $sms_method.IsDefault = $false

    $index = 1
    $total = $upns.count
    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        if ($user.StrongAuthenticationMethods.count -eq 0) {
            Write-Host "[$upn] has no authentication method!"
            continue
        }
        if ($user.StrongAuthenticationMethods.methodtype -contains "OneWaySMS") {
            Write-Host "[$upn] has already SMS option"
            continue
        }

        $user.StrongAuthenticationMethods.add($sms_method)
        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods $user.StrongAuthenticationMethods

        $progress = [math]::Round(100 * $index / $total, 2)
        Write-Progress -Activity "updating users authentication methods" -Status "$progress% Complete:" -PercentComplete $progress
        $index++
    }
}

function Update-SVDefaultAuthMethod {
    param ( 
        [Parameter(Mandatory = $true)]
        $upns,

        [Parameter(Mandatory = $true)]
        [ValidateSet("OneWaySMS", "TwoWayVoiceMobile", "PhoneAppNotification", "PhoneAppOTP")]
        [String]
        $method = $false
    )
    
    $sms_method = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
    $sms_method.MethodType = "OneWaySMS"
    $sms_method.IsDefault = $false

    $index = 1
    $total = $upns.count
    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        if ($user.StrongAuthenticationMethods.count -eq 0) {
            Write-Host "[$upn] has no authentication method!"
            continue
        }

        if ($user.StrongAuthenticationMethods.MethodType -notcontains $method) {
            Write-Host "[$upn] has no `"$method`" method to make it the default!"
            continue
        }
        
        foreach ($_method in $user.StrongAuthenticationMethods) {
            $_method.isdefault = $false
            if ($_method.MethodType -eq $method) {
                $_method.IsDefault = $true
            }
        }

        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods $user.StrongAuthenticationMethods

        $progress = [math]::Round(100 * $index / $total, 2)
        Write-Progress -Activity "updating users authentication methods" -Status "$progress% Complete:" -PercentComplete $progress
        $index++
    }
}
