OS-X-Bluetooth-Pairing-Value-To-Windows-Value
=============================================

A useful script to simultaneously pair a bluetooth device to your Mac in OS X and Boot Camp Windows

OS X Bluetooth Pairing Value To Windows Value

A script to get the Windows equivalent bluetooth adress/link key pair (little endian?)

This is useful if you would like to pair a bluetooth device to both OS X and Windows (in BootCamp).

Thanks to user pacnow (Camoguy) at [discussions.apple.com](https://discussions.apple.com/thread/3113227) for doing the leg work and figuring out the algorithm

Follow these steps to get your bluetooth device working.

-  pair device with windows
-  reboot and pair with OS X
-  run this script/app
-  save the link key/s somewhere you can reach from windows
-  boot to windows
-  run regedit with admin rights
-  go to HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\BD_ADDR
-  edit the key of the device
-  reboot

### What this script does

- read the link keys
```
up to Sierra:
sudo defaults read /private/var/root/Library/Preferences/blued.plist LinkKeys
High Sierra and onwards:
sudo defaults read /private/var/root/Library/Preferences/com.apple.bluetoothd.plist LinkKeys
````
- parse the data with awk
- display it in a window
- export a bluetooth.reg file with all paired link keys, if desired

Here's an example link key. Instead of just typing that in you want to break it apart starting from the right, taking a pair of two characters at a time.

`98 54 2f f9 88 e1 94 49 47 52 50 e1 39 43 25 5b` (What is shown in OS X)

`5B 25 43 39 E1 50 52 47 49 94 E1 88 F9 2F 54 98` (What you enter in Windows)

 -Help from Camoguy-

Note, this script requires administrator privileges.

Your password is not saved anywhere and only known to you and your OS.

- Adnaan Soorma
- Twitter: @Soorma07

- broeckelmaier
- Twitter: @broeckelmaier

## Possible Issues:
### Windows /keys in registry is empty #8

shivangswain commented on Aug 23, 2020

You can fix that by setting the permissions of the /Keys folder/key. 
So,

- right click on it
- click "Permissions..."
- click on "Add"
- input your Windows username in the large text box
- click on "Check Names"
- once the text box changes into the / form press OK
- select the "Full Control" checkbox
- press OK
- Now you'll be able to add and see the keys. Remember to reboot before testing.
