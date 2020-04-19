-- #region Main

set helpText to "
This script helps you to get the adress - link key pairs of all paired bluetooth devices in a format that Windows can understand.
This is useful if you would like to pair a bluetooth device to both OS X and Windows (in BootCamp).

How it works:
The AppleScript parses the paired bluetooth devices link key/value pairs and prints out the Windows equivalent value.


Follow these steps to get your bluetooth device working.

-  pair device with windows
-  reboot and pair with OS X
-  run this script/app
-  save the link key/s somewhere you can reach from windows
-  boot to windows
-  run regedit with admin rights
-  go to \n\tHKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\\n\tServices\\BTHPORT\\Parameters\\Keys\\BD_ADDR
-  edit the key of the device
-  reboot

Note, this script requires administrator privileges.
Your password is not saved anywhere and only known to you and your OS.
"
display dialog helpText with title "OS X Bluetooth Pairing Value To Windows Value"

global _workingDirectory,shellCommand,awkCommand

-- set the systemversion and check the according file
set _versionString to system version of (system info)
set _workingDirectory to POSIX path of ((path to me as text) & "::")
considering numeric strings
	if _versionString ≤ "10.12" then
		-- read /private/var/root/Library/Preferences/blued.plist
		set shellCommand to "defaults read /private/var/root/Library/Preferences/blued.plist LinkKeys > " & _workingDirectory & "output.txt"
		set awkCommand to _workingDirectory & "old.awk " & _workingDirectory & "output.txt"
	else if (_versionString > "10.12") and (_versionString < "10.15") then
		-- read /private/var/root/Library/Preferences/com.apple.Bluetoothd.plist
		set shellCommand to "defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist LinkKeys > " & _workingDirectory & "output.txt"
		set awkCommand to _workingDirectory & "old.awk " & _workingDirectory & "output.txt"
	else if _versionString ≥ "10.15" then
		-- read /private/var/root/Library/Preferences/com.apple.Bluetoothd.plist but parse it differently
		set shellCommand to "defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist LinkKeys > " & _workingDirectory & "output.txt"
		set awkCommand to _workingDirectory & "new.awk " & _workingDirectory & "output.txt"
	else
		display alert "Congratulations, you've found the edge case"
	end if
end considering

try
	getLinkKeys(helpText)
on error errorMessage
	display dialog "Error: " & errorMessage
end try
-- #endregion Main

on getLinkKeys(helpText)
	do shell script shellCommand with administrator privileges
	set linkKeys to do shell script awkCommand
	do shell script "rm -f "& _workingDirectory & "output.txt" with administrator privileges
	set bluetoothAdapterAddress to word 1 of linkKeys
	set linkKeys to paragraphs 2 thru -1 of linkKeys
	set listSize to count of LinkKeys

	set output to ("Your Bluetooth Adapter Address is: " & bluetoothAdapterAddress & return & return & "Currently there are "& listSize & " devices connected." & return & return)

	set counter to 1

	repeat with currentLinkKeyValues in linkKeys
		set currentLinkList to words of currentLinkKeyValues
		set currentLinkKey to item 1 of currentLinkList
		set currentLinkValue to item 2 of currentLinkList
		set currentLinkValueWin to item 3 of currentLinkList

		set output to output & "Bluetooth device " & counter & ":\n"
		set output to output & "Device address:\t" & currentLinkKey & return
		set output to output & "Device link key:\t" & currentLinkValue & return
		set output to output & "Windows link key:\t" & currentLinkValueWin & return
		set output to output & return

		set counter to counter + 1
	end repeat

	display dialog output
	display dialog "Would you like to have a .reg file exported for easy transfer?" buttons {"No","Yes"} default button "Yes" cancel button "No"
	if button returned of result = "Yes"
		try
			writeRegFile(bluetoothAdapterAddress,linkKeys)
		on error errorMessage
				display dialog "Error: " & errorMessage
		end try
	end if
	display alert "Thank you for using this Tool"

	do shell script "echo " & quoted form of helpText & return & return & quoted form of output

end getLinkKeys

on writeRegFile(bluetoothAdapterAddress,linkKeys)
	try
		set fileName to POSIX file (_workingDirectory & "bluetooth.reg")
		set regFile to open for access file fileName with write permission
		set eof of regFile to 0 --overwrite everything

		set fileContent to "Windows Registry Editor Version 5.00\n\n"
		set fileContent to fileContent & "[HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\BTHPORT\\Parameters\\Keys]\n\n"
		set fileContent to fileContent & "[HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\BTHPORT\\Parameters\\Keys\\" & bluetoothAdapterAddress & "]\n"

		repeat with currentLinkKeyValues in linkKeys
			set currentLinkList to words of currentLinkKeyValues
			set currentLinkKey to item 1 of currentLinkList
			set currentLinkValueWin to item 3 of currentLinkList

			set fileContent to fileContent & "\"" & currentLinkKey & "\"=hex:"
				set counter to 1
				repeat while counter < 31
					set fileContent to fileContent & text item counter of currentLinkValueWin
					set fileContent to fileContent & text item (counter + 1 ) of currentLinkValueWin & ","
					set counter to counter + 2
				end repeat
			set fileContent to fileContent & text item 31 of currentLinkValueWin
			set fileContent to fileContent & text item 32 of currentLinkValueWin
			set fileContent to fileContent & return

		end repeat
		write fileContent to regFile starting at eof
		close access regFile
		return true
	on error
		try
			close access file regFile
		end try
		return false
	end try
end writeRegFile
