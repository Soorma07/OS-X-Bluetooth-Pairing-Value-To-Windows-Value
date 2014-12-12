OS-X-Bluetooth-Pairing-Value-To-Windows-Value
=============================================

A useful script to simultaneously pair a bluetooth device to your Mac in OS X and Boot Camp Windows


OS X Bluetooth Pairing Value To Windows Value
A script to get the Windows equivalent bluetooth pairing key/value pair (little endian?)
This is useful if you would like to pair a bluetooth device to both OS X and Windows (in BootCamp).

How it works:
The AppleScript parses the paired bluetooth devices' link key/value pairs and prints out the Windows equivalent value (little endian?).

Thanks to user pacnow (Camoguy) at https://discussions.apple.com/thread/3113227?start=0&tstart=0 
for doing the leg work and figuring out the algorithm

You must follow pacnow's steps to edit the value in Windows.
I have copied and slightly modified his steps here for you.

1. Pair device with Windows, then go back in and pair in OS X.
2. a. After you have completed both pairings in step 1, then execute this script or run the application
2. b. Get the link key from OS X and email it to yourself or put it somewhere you can reach from Windows.
[code]sudo defaults read /private/var/root/Library/Preferences/blued.plist[/code]
3. a. If you don't have psexec, Google for it and download it.
3.  b. Boot Windows, open cmd as admin, [code]psexec -s -i regedit[/code]
4. Navigate to HKLM\System\CurrentControlSet\services\BTHPORT\Parameters\Keys\ (BT ID of Mouse/Keyboard) and begin modify binary data

Here's an example link key, instead of just pluggin that in, what you want to do is break it apart starting from the right, working two digits at a time in pairs.

98542ff9 88e19449 475250e1 3943255b ( What is shown in OS X)
5B254339 E1505247 4994E188 F92F5498 (What you enter in Windows)
 -Help from Camoguy-

Note, this script requires administrator privileges. I am strictly just using your password here within the script to get the bluetooth pairing values. If you are still wary, and prefer not to enter your password into an unknown script, then comment out and edit the password related lines below and just open a terminal window and perform a sudo command before running this script.

- Adnaan Soorma
- Twitter: @Soorma07
