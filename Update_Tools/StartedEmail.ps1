#Set Date format for emails
$timestart = (Get-Date -f "T")
 
$emailFrom = "zach.milleson@interpublic.com"
$emailTo = "zach.milleson@interpublic.com"
$subject = "VMTools upgrade has begun"
$body = "Time Started:", $timestart
 
$smtpServer = "omaedcmgw002.interpublic.com"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($emailFrom,$emailTo,$subject,$body)