# Android-ADB-Authorization-Tool

Android ADB authorization management tool 

This tool can help you manage android adb authorization, must run as root

Usage: adb_key [-a] [-d] [-d-all] [-r] [-ex] [KEY] [DEVICE]

    -a [KEY]: Authorize your device with a key file "adbkey.pub"
    
    -d [DEVICE]: Unauthorize your device, device name needed
    
    -d-all: Unauthorize all devices
    
    -r: Read list of device name of authorized devices

    -ex: Extract a key of a device to a pub file.
    
