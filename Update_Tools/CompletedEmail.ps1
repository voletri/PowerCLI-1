#Set Date format for emails
$timecomplete = (Get-Date -f "T")
 
$emailFrom = "zach.milleson@interpublic.com"
$emailTo = "zach.milleson@interpublic.com"
$subject = "VMTools Upgrade has finished"
$body = "Time Completed:", $timecomplete

$smtpServer = "omaedcmgw002.interpublic.com"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($emailFrom,$emailTo,$subject,$body)