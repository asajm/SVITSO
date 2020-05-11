



# Import-Module MSOnline

function Get-SVUserAuthMethods {
    param ( $upns )
    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        $user | select UserPrincipalName, DisplayName -ExpandProperty StrongAuthenticationMethods | select UserPrincipalName, DisplayName, IsDefault, MethodType
    }
}

function Add-SVCallAuthMethod {
    param ( $upns )
    $call_method = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
    $call_method.MethodType = "TwoWayVoiceMobile"
    $call_method.IsDefault = $false

    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        if($user.StrongAuthenticationMethods.count -eq 0){
            Write-Host "($upn) has no authentication method!"
            continue
        }
        if($user.StrongAuthenticationMethods.methodtype -contains "TwoWayVoiceMobile"){
            Write-Host "($upn) has already call-me option"
            continue
        }
        if($user.StrongAuthenticationMethods.methodtype -notcontains 'OneWaySMS'){
            Write-Host "($upn) does not have SMS option"
            continue
        }

        $user.StrongAuthenticationMethods.add($call_method)
        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods $user.StrongAuthenticationMethods
    }
}

# Export-ModuleMember -Function Get-SVUserAuthMethods
# Export-ModuleMember -Function Add-SVCallAuthMethod