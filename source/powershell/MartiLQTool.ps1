
. .\source\powershell\MartiLQ.ps1
. .\source\powershell\MartiLQConfiguration.ps1


function Send-EmailAck {
    param (
        [String] $FileAttachment,
        [String] $Recipient,
        [String] $State,
        [int] $Buffersize = 1024
    )

    $receiver = $Recipient.Substring(5)
    Write-Host "Sending acknowledgment via email to: $receiver " -ForegroundColor Green
  
    $EmailFrom = $env:MARTILQ_EMAIL_FROM
    
    $Subject = "martiLQ acknowledge [$State]"
    $Body = "Simple email ack"

    $password = ConvertTo-SecureString $env:MARTILQ_EMAIL_PASSWORD -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($env:MARTILQ_EMAIL_USERNAME, $password)
    
    Write-Host "SMTP: $($env:MARTILQ_EMAIL_HOST) :: 465 " -ForegroundColor Yellow
    Write-Host "Send with: $FileAttachment :: $Subject  :: $Body " -ForegroundColor Yellow

    $att = new-object Net.Mail.Attachment($FileAttachment)

    #Send mail with attachment
    $from = New-Object System.Net.Mail.MailAddress($EmailFrom)
    $to = New-Object System.Net.Mail.MailAddress($receiver)
    $email = New-Object System.Net.Mail.Mailmessage($from, $to)
    $email.Subject = $Subject
    $email.Body = $Body
    $email.IsBodyHTML = $true
    $email.Attachments.Add($att)
   
    $att.Dispose()

    $smtp = New-Object Net.Mail.SmtpClient($env:MARTILQ_EMAIL_HOST, 465)
    $smtp.EnableSSL = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($env:MARTILQ_EMAIL_USERNAME, $env:MARTILQ_EMAIL_PASSWORD)
    $smtp.Send($email)
 
}

function Get-Resources {
    param (
        [Parameter(Mandatory)][PSCustomObject] $MartiLQ,
        [String] $DataPath,
        [String] $CurrentState,
        [String] $Consumer
    )

    $nextState = "received"
    
    Try {
        foreach ($item in $MartiLQ.resources) {
            if ($item.state -eq $currentState) {

                $item.state = $nextState
            }
        }

        if ($Consumer -ne "") {
            [System.Collections.ArrayList]$lconsumer = @()
            $lconsumer += $Consumer
            $MartiLQ.consumers = $lconsumer
        }

        $today = Get-Date
        $dateToday = $today.Tostring("yyyy-MM-ddTHH:mm:ss")
        $MartiLQ.stateModified = $dateToday
        $MartiLQ.state = $nextState

        # Notification
        $ack = $MartiLQ.acknowledge

        if ($ack.url.startswith("mail:"))
        {
            $fileJson = "./temp/MartiBSBRemote_interim2.json"
            $attachment = Save-MartiLQDefinition -MartiLQ $oMarti -FilePath $fileJson
            Send-EmailAck -FileAttachment $attachment -Recipient $ack.url -State $nextState
        }

    } Catch {
        Write-Host "Error in resource get: $_"
    }

    return $MartiLQ
}


function Test-Resource {
    param (
        [Parameter(Mandatory)][PSCustomObject] $MartiLQ,
        [String] $DataPath,
        [String] $CurrentState,
        [String] $Consumer
    )

    $nextState = "verified"
    
    Try {
        foreach ($item in $MartiLQ.resources) {
            if ($item.state -eq $currentState) {

                $item.state = $nextState
            }
        }

        if ($Consumer -ne "") {
            [System.Collections.ArrayList]$lconsumer = @()
            $lconsumer += $Consumer
            $MartiLQ.consumers = $lconsumer
        }

        $MartiLQ.state = $nextState
    } Catch {
        Write-Host "Error in resource test: $_"
    }

    return $MartiLQ
}

function Invoke-ProcessResource {
    param (
        [Parameter(Mandatory)][PSCustomObject] $MartiLQ,
        [String] $DataPath,
        [String] $CurrentState,
        [String] $Consumer
    )

    $nextState = "processed"
    
    Try {
        foreach ($item in $MartiLQ.resources) {
            if ($item.state -eq $currentState) {

                $item.state = $nextState
            }
        }

        if ($Consumer -ne "") {
            [System.Collections.ArrayList]$lconsumer = @()
            $lconsumer += $Consumer
            $MartiLQ.consumers = $lconsumer
        }

        $MartiLQ.state = $nextState
    } Catch {
        Write-Host "Error in resource process: $_"
    }

    return $MartiLQ
}

$currentState = "expired"
$nextState = "active"
$consumer = "Test-Framework"

$fileJson = "C:\Users\meerkat\source\marti\docs\source\samples\powershell\test\MartiBSBRemote.json"
$oMarti = Restore-MartiLQDefinition -FilePath $fileJson

$oMarti.acknowledge.url = "mail:tp_reklam@villacentrum.com"

$today = Get-Date
$dateToday = $today.Tostring("yyyy-MM-ddTHH:mm:ss")
$oMarti.stateModified = $dateToday
$oMarti.state = $nextState

foreach ($item in $oMarti.resources) {
    if ($item.state -eq $currentState) {
        $item.state = $nextState
    }
}

$oMarti = Get-Resources -MartiLQ $oMarti[0] -DataPath "" -CurrentState "active" -Consumer $consumer

$oMarti = Test-Resource -MartiLQ $oMarti -DataPath "" -CurrentState "received" -Consumer $consumer

$oMarti = Invoke-ProcessResource -MartiLQ $oMarti -DataPath "" -CurrentState "verified" -Consumer $consumer

$fileJson = "C:\Users\meerkat\source\marti\docs\source\samples\powershell\test\MartiBSBRemote_v2.json"
Save-MartiLQDefinition -MartiLQ $oMarti -FilePath $fileJson
