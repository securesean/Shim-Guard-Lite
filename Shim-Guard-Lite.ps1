# Shim Guard
#
# Author:		Sean Pierce
# Email:		sdb at securesean com
# Date:		    Augest 1st 2015
# This program will print out currently installed shims, their locations, install times and will register 
# for events relating to the install of a new Shim Database (SDB files). This program will currently only alert you.
# In future versions, it will attempt to block the shim from executing. 
# This is proof-of-concept so don't hate. Be sure to run this withx64 power shell on x64 systems 
# because the VirtualRegistry fix will redirect the look ups if it's running as 32-bit program (aka WOW64 process)

#Requires –version 3.0

Function alertHandlerForCustomRegKey
{
    Write-host "Something changed in Custom SDB Install Registry Key."
}

Function alertHandlerForInstallLocationRegKey
{
    Write-host "Something changed in Custom SDB Install Locations Registry Key."
}


# file locations
$defaultSDBInstallFolder = "C:\Windows\AppPatch\Custom\"
$defaultSDBInstallFolder64 = "C:\Windows\AppPatch\Custom\Custom64\"

# registry locations
# documentation says \\ instead of \ should be used but there don't seem to be a difference
$customKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom"
$installedSDBKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB"

# Useful: http://blogs.technet.com/b/heyscriptingguy/archive/2009/11/05/hey-scripting-guy-november-5-2009.aspx
$customRegKey = "HKLM:\" + $customKeyPath
$installedSDBRegKey = "HKLM:\" + $installedSDBKeyPath


# list current keys. Short: gci, ls
echo "Currently Installed Shims:"
Get-ChildItem $customRegKey
Get-ItemProperty $customRegKey

echo "Currently Installed Shim Database Locations:"
Get-ChildItem $installedSDBRegKey
Get-ItemProperty $installedSDBRegKey

echo "Default SDB Install Locations"
Get-ChildItem -Exclude "Custom64"  $defaultSDBInstallFolder
Get-ChildItem $defaultSDBInstallFolder64

# Later:
# Match the custom properties with the names of the installed shims and file locations


echo "Monitoring Registry Locations"
# WMI query's reqire '\\' instead of a '\'
$customKeyPathForWMI = $customKeyPath.Replace("\","\\")
$customKeyQuery = "Select * from RegistryTreeChangeEvent where Hive='HKEY_LOCAL_MACHINE' AND RootPath='$customKeyPathForWMI'" # in future say AND NOT ValueName='$ValueName'" 

$installedSDBKeyPathForWMI = $installedSDBKeyPath.Replace("\","\\")
$installedSDBKeyQuery = "Select * from RegistryTreeChangeEvent where Hive='HKEY_LOCAL_MACHINE' AND RootPath='$installedSDBKeyPathForWMI'" # in future say AND NOT ValueName='$ValueName'" 

# making the event notifer
# Method 2: Call a function when event triggers
Register-WmiEvent -Query $customKeyQuery -Action { alertHandlerForCustomRegKey  }
Register-WmiEvent -Query $installedSDBKeyQuery -Action { alertHandlerForInstallLocationRegKey  }

# Method 1: Simple Wait
#Register-WmiEvent -Query $query -SourceIdentifier KeyChanged
#Wait-Event -SourceIdentifier KeyChanged
#echo "Something changed!"
