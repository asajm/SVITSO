# these functions to manage MFA methods of Azure AD users

# this function to get MFA methods of one or a list of users (UPNs)
function Get-UserAuthMethods {
    param ( $upns )
    foreach ($upn in $upns) {
        $user = Get-MsolUser -UserPrincipalName $upn
        $user | select UserPrincipalName, DisplayName -ExpandProperty StrongAuthenticationMethods | select UserPrincipalName, DisplayName, IsDefault, MethodType
    }
}

#thsi function to set call-me option into one or a list of users (UPNs)
function Add-CallAuthMethod {
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