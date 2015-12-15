#Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File C:\pswd.txt
#

 

#$username = 'ipgna\robert.estes'

#$password = #cat C:\pswd.txt | ConvertTo-SecureString

#$cred = New-Object -typename System.Management.Automation.PSCredential -ArgumentList $username, $password
$cred = Get-Credential

$param = @{

    SmtpServer = 'relay-mail.interpublic.com'

#    Port = 587

#    UseSsl = $true

    Credential  = $cred

    From = 'andru.estes@interpublic.com'

    To = 'andru.estes@interpublic.com'

    Subject = 'Testing'

    Body = "A sample email"

#    Attachments = 'C:\Temp\whatever.txt'

}



Send-MailMessage @param
