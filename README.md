# DNSCrypt-CaptivePortal-Pause
A lightweight Powershell script to automatically pause DNSCrypt-Proxy when logging into a captive portal.

To install, save the .ps1 somewhere on your device, then create a Scheduled Task to run the script upon network connection (Log: Microsoft-Windows-NetworkProfile/Operational, Event ID: 10000). Run as user SYSTEM. 
