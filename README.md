## Lua scripts for Mega Man ZX and ZX Advent on emulator
Lua scripts for modding the gameplay in Mega Man ZX. Support for the DS emulators BizHawk, DeSmuME, and DraStic.

### NOTE: The ZXA script currently only supports DeSmuME. ZX script supports all 3 emulators.

### How to use
First, download the lua file matching your game (MMZX or MMZXAdvent).  
Then follow these per-emulator instructions.

#### BizHawk
- Recommended file location: `[Bizhawk]/Lua/NDS/`
1. With the game running, select Tools > Lua Console.
2. Click the `Open Script` icon and select the lua file.
3. It should run automatically; there will be a green triangle next to the file name in the list, and under Output it should print "bizhawk" and then either "jp" or "en" depending on your game version.
4. Double-click the row in the script list at any time to stop or run the script again. 
5. To avoid potential issues, stopping the script is recommended before resetting the game or loading a save or savestate. BizHawk will also automatically reset the script when swapping ROMs, so if you're changing to a different game, make sure to remove the script or close the lua console.

#### DeSmuME
- Recommended file location: `[DeSmuME]/Lua/`
1. Download `lua51.dll` from this repository into your DeSmuME folder.
2. In DeSmuME with the game running, navigate to Tools > Lua Scripting > New Lua Script Window.
3. Click `Browse` and select the lua file.
4. Once selected, it should automatically run, printing "desmume" and then either "jp" or "en" depending on your game version.
5. Use the `Stop` or `Run` buttons on the lua console at any time to stop or run the script again.
6. To avoid potential issues, stopping the script is recommended before resetting the game or loading a save or savestate. DeSmuME will automatically stop the script when swapping ROMs.

#### DraStic
1. Using a file manager app, create a new folder in any location.
    - This is where we'll be telling DraStic to store its data, so name it something appropriate like `DraStic`.
2. In DraStic, navigate to Options > General.
3. Toggle the option `Enable Cheats` to on.
4. Click the option `System Directory`. Change it from `Default Internal Folder` to `Scoped Storage Folder`.
5. Select the folder that you created earlier, and DraStic will move its data there.
6. Go back to the file manager app and navigate into your custom DraStic folder; it should be populated with new data.
7. Create a subfolder named `scripts`.
8. Move the lua file into the scripts folder.
9. Rename the file from `MMZX Adjustments by Meta_X.lua` to exactly match the name of your ZX rom, just replacing the extension with `.lua`.
    - For example, my rom is named `0556 - MegaMan ZX (U)(Legacy).nds` so my file inside DraStic/scripts/ is named `0556 - MegaMan ZX (U)(Legacy).lua`.
10. The script should automatically load whenever you play the game. If it's not working, double check that your settings and folder/file names match the above instructions.
- Required lua file path: `[DraStic]/scripts/[ROM_filename].lua`


## TODO
ZXA script:
- Implement WIP features into main stable version
- Refactor to work with other emulators like the ZX script
- Copy any other transferable features and abilities from ZX script
- Add ability to toggle between Grey and Ashe ability variants for models A and F 
