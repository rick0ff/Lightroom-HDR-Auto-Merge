# Lightroom HDR Auto Merge
Since Lightroom does not offer an easy way to merge a large amount of HDRs, this tool based on AutoHotKey automates the necessary commands for you.
## How does it work?
This script runs with [AutoHotkey](https://www.autohotkey.com/), a software that allows to script manual commands to automate them. 
So basically this script commands your keyboard to selects every single photo of an HDR in Lightroom, e.g. 3 photos with EV -3, 0, +3. Then it simulates the Ctrl+Shift+H command that queues the HDR merge process in Lightroom.
When the queue is filled you can wait for your computer to process the jobs lined up in the background while you do something else.

## Requirements
* **Lightroom CC or Lightroom 6** (if your version allows queuing of HDRs it should work, let me know if that applies to older versions as well)
* **Windows** (due to AutoHotKey only being available for Windows)

## Organizing the pictures to merge in Lightroom
For the script to work properly you have to 
* put all the pictures to be merged in a separate collection
* tag them with a color (press "6" (green) to "0" (xx) in Lightroom)
**Note: Per batch run the HDRs must have the same amount of single pictures.** If you mix HDRs based on different amount of files (e.g. 3 and 5) the software won't be able to differentiate.

## Two options to use the script
There are two ways to use this script:
a. Easy: Run the script as an .exe (self-executable), if you're not willing to modify the script this is the easiest way. Download the latest file x.exe from the "exe" folder and run it. No need to install AutoHotkey.
b. Advanced: Download and install [AutoHotkey](https://www.autohotkey.com/) and download the script from the "script" folder. Import it to AutoHotkey and run it from there. This gives you the ability to modify the script to your needs.

## Instructions for easy use
1. Download the script from the "exe" folder 
1. Prepare Lightroom
   1. Create a smart collection for an unused color, e.g. red <screen>
   1. Select the first bundle of bracketed images and press Ctrl+H to tell Lightroom with what parameters the HDRs should be merged
1. Load the downloaded .exe by double-clicking it
1. Press Hotkey (Ctrl+Shift+Alt+J) to start the tool
1. Set the parameters for the batch job and click OK <screen>
1. Run
1. Wait for the script to fill your queue. If you want to exit press "ESC". Then wait until the queue is fully processed. 

## Options of the script [defaults]
The script covers the following options to fit your individual HDR needs:
* Amount of Pictures per bracket (usually 3, 5 or 7) that results in one generated HDR
* Amount of HDRs to generate
* Time for pauses. This setting lets you set the length of pauses between each the queuing of each HDR. On a less powerful system it is recommended to increase the amount. If your rig is powerful you can decrease it.
* End action...

## Further development
For now the script fits my needs. Let me know if you're having problems or futher ideas.
