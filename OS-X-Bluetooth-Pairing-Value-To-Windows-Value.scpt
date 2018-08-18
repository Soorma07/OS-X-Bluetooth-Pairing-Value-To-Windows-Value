-- ===========================================================
-- OS X Bluetooth Pairing Value To Windows Value
-- A script to get the Windows equivalent bluetooth pairing key/value pair (little endian?)
-- This is useful if you would like to pair a bluetooth device to both OS X and Windows (in BootCamp).

-- How it works:
-- The AppleScript parses the paired bluetooth devices' link key/value pairs
-- and prints out the Windows equivalent value (little endian?).

-- Thanks to user pacnow (Camoguy) at https://discussions.apple.com/thread/3113227?start=0&tstart=0 
-- for doing the leg work and figuring out the algorithm

-- You must follow pacnow's steps to edit the value in Windows.
-- I have copied and slightly modified his steps here for you.

-- 1. Pair device with Windows, then go back in and pair in OS X.
-- 2. a. After you have completed both pairings in step 1, then execute this script or run the application
-- 2. b. Get the link key from OS X and email it to yourself or put it somewhere you can reach from Windows.
-- [code]sudo defaults read /private/var/root/Library/Preferences/blued.plist[/code]
-- 3. a. If you don't have psexec, Google for it and download it.
-- 3.  b. Boot Windows, open cmd as admin, [code]psexec -s -i regedit[/code]
-- 4. Navigate to HKLM\System\CurrentControlSet\services\BTHPORT\Parameters\Keys\ (BT ID of Mouse/Keyboard) and begin modify binary data

-- Here's an example link key, instead of just pluggin that in, what you want to do is break it apart starting from the right, working two digits at a time in pairs.

-- 98542ff9 88e19449 475250e1 3943255b ( What is shown in OS X)
-- 5B254339 E1505247 4994E188 F92F5498 (What you enter in Windows)

-- -Camoguy

-- Note, this script requires administrator privileges. I am strictly just using your password here within
-- the script to get the bluetooth pairing values. If you are still wary, and prefer not to 
-- enter your password into an unknown script, then comment out and edit the password related
-- lines below and just open a terminal window and perform a sudo command before running
-- this script.

-- Adnaan Soorma
-- Twitter: @Soorma07
-- ===========================================================

-- #region Main

set helpText to "OS X Bluetooth Pairing Value To Windows Value
This is a script to get the Windows equivalent bluetooth pairing key/value pair
This is useful if you would like to pair a bluetooth device to your Mac in both OS X and Windows (in BootCamp).

How it works:
The AppleScript parses the paired bluetooth devices link key/value pairs and prints out the Windows equivalent value.

Thanks to user pacnow (Camoguy) at https://discussions.apple.com/thread/3113227?start=0&tstart=0 
for doing the leg work and figuring out the algorithm

You must follow pacnows steps to edit the value in Windows.
I have copied and slightly modified his steps here for you.

1. Pair device with Windows, then go back and pair in OS X.
2. a. After you have completed both pairings in step 1, then execute this script or run the application
2. b. Get the link keys and values from executing this script and email it to yourself or put it somewhere you can reach from Windows.
[code]sudo defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist[/code]
3. a. If you don't have psexec, Google for it and download it.
3. b. Boot Windows, open cmd as admin, [code]psexec -s -i regedit[/code]
4. Navigate to HKLM\\System\\CurrentControlSet\\services\\BTHPORT\\Parameters\\Keys\\ (BT ID of Mouse/Keyboard) and begin modifying the binary data to the Windows pairing value as output by this script.
Note, this script requires administrator privileges and will prompt for your OS X current user password.

-Adnaan Soorma
Twitter: @Soorma07
"
display dialog quoted form of helpText

set userName to do shell script "whoami"
set myPassword to text returned of ¬
	(display dialog "Enter password for " & ¬
		quoted form of userName ¬
		with icon stop ¬
		default answer ¬
		"" with hidden answer)
set linkKeys to do shell script "sudo defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist | awk '/LinkKeys/,/};/'" user name userName password myPassword with administrator privileges
set carriageReturnCharacter to (ASCII character 13) --// CR
set the text item delimiters to carriageReturnCharacter
set listOfDelimitedLinkKeys to text items of linkKeys
set bluetoothAdapterAddressLine to item 2 of listOfDelimitedLinkKeys
set listOfLinkKeys to items 3 thru -2 of listOfDelimitedLinkKeys

set bluetoothAdapterAddressKey to bluetoothAdapterAddressLine
set the text item delimiters to "\""
set bluetoothAdapterAddress to text item 2 of bluetoothAdapterAddressKey

set output to ("Your Bluetooth Adapter Address is: " & bluetoothAdapterAddress)
set output to output & carriageReturnCharacter
set output to output & carriageReturnCharacter

set counter to 1

repeat with currentLinkKeyValuePair in listOfLinkKeys
	set the text item delimiters to "\""
	set currentLinkKey to text item 2 of currentLinkKeyValuePair
	
	set the text item delimiters to "<"
	set currentLinkValue to text item 2 of currentLinkKeyValuePair
	set the text item delimiters to ">"
	set currentLinkValue to text item 1 of currentLinkValue
	
	set output to output & ("Bluetooth device " & counter & " pairing key                                            : " & currentLinkKey)
	set output to output & carriageReturnCharacter
	
	set output to output & ("Bluetooth device " & counter & " pairing current value in OS X                  : " & currentLinkValue)
	set output to output & carriageReturnCharacter
	
	-- Need to manipulate currentLinkValue here to Windows format
	
	set currentLinkValue to removeSpaces(currentLinkValue)
	set currentLinkValue to reverseEndian(currentLinkValue)
	
	set output to output & ("Bluetooth device " & counter & " pairing value in Windows should be set to: " & currentLinkValue)
	set output to output & carriageReturnCharacter
	
	set output to output & carriageReturnCharacter
	
	set counter to counter + 1
end repeat

display dialog quoted form of output
do shell script "echo " & quoted form of helpText & carriageReturnCharacter & carriageReturnCharacter & quoted form of output

-- #endregion Main

on removeSpaces(toRemoveSpaces)
	set toRemoveSpacesOriginal to toRemoveSpaces
	set toRemoveSpaces to ""
	set the text item delimiters to " "
	set toRemoveSpacesOriginalLength to (get count of text items in toRemoveSpacesOriginal)
	set counter to 1
	repeat while counter ≤ toRemoveSpacesOriginalLength
		set toRemoveSpaces to toRemoveSpaces & (text item counter of toRemoveSpacesOriginal)
		set counter to counter + 1
	end repeat
	return toRemoveSpaces
end removeSpaces

on reverseEndian(toReverseEndian)
	set returnValue to ""
	-- Endian conversion
	-- Starting at the end, take two characters and put them in the front
	set stringCharacterCount to (get count of characters in toReverseEndian)
	set counter to stringCharacterCount
	repeat while counter > 0
		set currentFirstCharacter to character counter in toReverseEndian
		set counter to counter - 1
		set currentSecondCharacter to character counter in toReverseEndian
		set counter to counter - 1
		set returnValue to returnValue & currentSecondCharacter & currentFirstCharacter
		if counter mod 8 is equal to 0 then
			set returnValue to returnValue & " "
		end if
	end repeat
	return returnValue
end reverseEndian
