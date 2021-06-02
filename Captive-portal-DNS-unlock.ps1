
# ~AUTHOR~
# @e-t-l https://github.com/e-t-l/DNSCrypt-CaptivePortal-Pause
# Version 1.0
#
# ~INSTALLATION~~
# Create a Scheduled Task on Network Connect. Run this script with admin privileges (fails otherwise).
#
# ~ACKNOWLEDGMENTS~
# Christian Hermann (@bitbeans) https://github.com/bitbeans/SimpleDnsCrypt
# Den Delimarsky(@dend) https://gist.github.com/dend/5ae8a70678e3a35d02ecd39c12f99110
# @lifenjoiner https://github.com/DNSCrypt/dnscrypt-proxy/discussions/1727
# Dyne.org (@dyne) https://github.com/dyne/dnscrypt-proxy/blob/master/README-WINDOWS.markdown
# Mattias Fors (@DeployWindowsCom) https://deploywindows.com/2018/01/15/want-to-become-a-windows-10-toast-balloon-expert-with-or-without-microsoft-intune/
#
# ~KEY~
# #Comments like this (i.e. no whitespace) are descriptions
# # 		Comments like this (i.e. with whitespace) are broken/deprecated code

#Check connectivity and messagebox response to run script
Start-Sleep -Seconds 2
If (!(Test-NetConnection -ComputerName www.example.com -InformationLevel "Quiet")) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	$result = [System.Windows.Forms.MessageBox]::Show("It looks like you're trying to access a captive portal. Switch to default DNS?" , "Info" , 4)
	If ($result -eq 'Yes') {
		#Create function to show Windows toast notifications
		function Show-Notification {
			[cmdletbinding()]
			Param (
				[string]
				$ToastTitle,
				[string]
				[parameter(ValueFromPipeline)]
				$ToastText,
				[string]
				$ButtonTitle,
				[ScriptBlock]
				$ButtonAction,
				[String]
				$ToastDuration
			)
			[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
			$Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
			$RawXml = [xml] $Template.GetXml()
			($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
			($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null
			If (($ToastDuration -eq "Long") -or ([int]$ToastDuration > 15)) {
				$RawXml.toast.SetAttribute(“duration”, $ToastDuration)
			}
			$SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
#			If (($ButtonTitle -ne $null) -and ($ButtonAction -ne $null)) {
#				$SerializedXml.ToastContent.ButtonTitle = $ButtonTitle
#				$SerializedXml.ToastContent.ButtonAction = $ButtonAction
#			}	
			$SerializedXml.LoadXml($RawXml.OuterXml)
			$Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
			$Toast.Tag = "Powershell"
			$Toast.Group = "PowerShell"
			$Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)
#			$Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
			$Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("DNSCrypt-proxy")
			$Notifier.Show($Toast);
		}		#		Stop-Service -Name "DNSCrypt-proxy"#		Start-Sleep -Seconds 1
		Set-DnsClientServerAddress -InterfaceIndex $NetIndex -ResetServerAddresses
		ipconfig /flushdns
		(get-netconnectionProfile).Name
		& "C:\Program Files\Mozilla Firefox\firefox.exe" -private-window
		$currentSSID = (netsh wlan show interfaces | select-string SSID)
		netsh wlan disconnect
		netsh wlan connect ssid=$currentSSID
		$NetIndex = ([string](get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2" | select InterfaceIndex)).substring(17,1)
		$i = 0
		#Wait 5 minutes while user attempts login
		:RestartLoop1 While (!(Test-NetConnection -ComputerName www.example.com -InformationLevel "Quiet") -and ($currentSSID -eq (netsh wlan show interfaces | select-string SSID))) {
			Start-Sleep -Seconds 4
			#After 5 minutes, offer to unpause DNSCrypt-proxy
			If ($i -eq 75) {
				#Defines toast button to unpause
				$ClickAction = {#					Start-Service -Name "DNSCrypt-proxy"
					Set-DnsClientServerAddress -InterfaceIndex $NetIndex -ServerAddresses ("127.0.0.1")#					$x = 0
					#After button click, try to restart DNSCrypt-proxy#					While (((get-service DNSCrypt-proxy | select status) | out-string).substring(20).trim() -ne "Running") {#						Start-Service -Name "DNSCrypt-proxy"#						Start-Sleep -Seconds 1#						#Break if service doesn't restart after 1 minute#						If ($x -eq 60) {#							Show-Notification("DNSCrypt-proxy failed to restart :(")#							$i = $null#							$x = $null#							Break RestartLoop1#						}#						$x+=1#					}
					Show-Notification("DNSCrypt-proxy has resumed.")
					$i = $null#					$x = $null
					Break RestartLoop1
				}#				Show-Notification("DNS reset timed out :(") "DNSCrypt-proxy remains disabled" -toastduration "long" -ButtonTitle "Unpause DNSCrypt-proxy" -ButtonAction $ClickAction
				Show-Notification("DNS reset timed out :(") "DNSCrypt-proxy remains paused" -toastduration "long"
				Start-Sleep -Seconds 20
				$i = $null#				$x = $null
				Break RestartLoop1
			}
			$i+=1
		}
		#When connected to internet, unpause DNSCrypt-proxy
		If (Test-NetConnection -ComputerName www.example.com -InformationLevel "Quiet") {#			Start-Service -Name "DNSCrypt-proxy"
			Set-DnsClientServerAddress -InterfaceIndex $NetIndex -ServerAddresses ("127.0.0.1")#			$y = 0#			Start-Sleep -Seconds 1#			#If first restart attempt fails, try again for 1 minute#			:RestartLoop2 While (((get-service DNSCrypt-proxy | select status) | out-string).substring(20).trim() -ne "Running") {#				Start-Sleep -Seconds 1#				#Break if service doesn't restart after 1 minute#				If ($y -eq 60) {#					Show-Notification("DNSCrypt-proxy failed to restart :(")#					$y = $null#					Break RestartLoop2#				}#				$y+=1					#			}
			Show-Notification("You're connect :)") "DNSCrypt-proxy resumed successfully."
		}
	} Else { Exit }
} Else { 
#	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") #Uncomment these two lines to test whether the script runs as expected
#	[System.Windows.Forms.MessageBox]::Show("You're good to go!" , "Info" , 3)
	Exit
}
