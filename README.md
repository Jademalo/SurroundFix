# SurroundFix
[CurseForge](https://www.curseforge.com/wow/addons/surroundfix)  
[Wago](https://addons.wago.io/addons/surroundfix)  
[WoW Interface](https://www.wowinterface.com/downloads/info25251-SurroundFix.html)  
[WoW Interface (Vanilla)](https://www.wowinterface.com/downloads/info25252-SurroundFixVanilla.html)  
[WoW Interface (TBC)](https://www.wowinterface.com/downloads/info25949-SurroundFixTBC.html)  

SurroundFix is a simple and lightweight AddOn that fixes the problems associated with running WoW at Surround/Eyefinity/Triplewide resolutions!

# Features
- Constrains the UI to the middle display
- Automatic vertical resolution detection
- Automatic middle display aspect ratio detection
- Extremely lightweight and simple, every Blizzard UI element acts as if you're just using a single display
- Almost every addon also works, so long as their frame handling is done properly!
- Will do nothing if using a single display, no need to disable it!
- Ability to set a manual aspect ratio for the UI - Want 16:9 on your 21:9 monitor? No problem!

Configure various options with /sfix or /surroundfix. You can change the aspect with "/sfix aspect x:y", or set it back to automatic mode with "/sfix aspect auto". Just type the command and any arguments for more help!


![Before](Other%20Files/Images/SFix%20Default.jpg)
![After](Other%20Files/Images/SFix%20Fixed.jpg)


For the curious, the mod essentially resizes the UIParent frame to the resolution of your middle monitor. This means that every UI element and AddOn sees a normal sized display rather than a crazy wide one, so they perfectly orient themselves on the middle display.

This is a much better solution than manually positioning every UI element, and also means that if you switch back to a single display your UI won't break! In fact, it can handle switching between Triplewide and single on the fly!


# Known Bugs  
- Certain AddOns will not be positioned correctly, and moving them will be strange. Unfortunately there isn't much I can do about this, since it's an issue with how the AddOn causing issues handles it's frames. Any AddOn that is designed to properly use UIParent should have no issues.

- If you for some reason have a 21:9 display with two side 4:3 displays, the UI will be 16:9. It's either this or potentially have issues with bezel correction.

- If the aspect is set to a compact aspect such as 4:3, after a reload the main bar will be anchored to the bottom left of the screen instead of the centre to prevent overlap with the menu bar. If you then change to a wider aspect such as 16:9, the bottom bar will be offset to the left. This is fixed after a `/reload`, and is behaviour of the default Blizzard UI.
