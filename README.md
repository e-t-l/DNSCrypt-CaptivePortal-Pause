# DNSCrypt-CaptivePortal-Pause
A lightweight Powershell script to automatically pause DNSCrypt-Proxy when logging into a captive portal.

To install, download the ZIP of all files somewhere on your Windows device. Unpack the ZIP, then then create a Scheduled Task to run program" "wscript" with argument "RunHelper1.vbs" upon network connection (Log: Microsoft-Windows-NetworkProfile/Operational, Event ID: 10000). Set the task to run as current user.
