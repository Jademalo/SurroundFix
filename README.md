# SurroundFix
https://www.curseforge.com/wow/addons/surroundfix

SurroundFix is a simple and lightweight AddOn that fixes the problems associated with running WoW at Surround/Eyefinity/Triplewide resolutions!

# Features
- Constrains the UI to the middle display
- Automatic vertical resolution detection
- Automatic middle display aspect ratio detection
- Extremely lightweight and simple, every Blizzard UI element acts as if you're just using a single display
- Almost every addon also works, so long as their frame handling is done properly!
- Will do nothing if using a single display, no need to disable it!

**Note** - Certain AddOns will not be positioned correctly, and moving them will be strange. Unfortunately there isn't much I can do about this, since it's an issue with how the AddOn causing issues handles it's frames. Any AddOn that is designed to properly use UIParent should have no issues.


![Before](https://i.imgur.com/Peh2Mb1.jpg)
![After](https://i.imgur.com/S8OwA6U.jpg)


For the curious, the mod essentially resizes the UIParent frame to the resolution of your middle monitor. This means that every UI element and AddOn sees a normal sized display rather than a crazy wide one, so they perfectly orient themselves on the middle display.

This is a much better solution than manually positioning every UI element, and also means that if you switch back to a single display your UI won't break! In fact, it can handle switching between Triplewide and single on the fly!


# Known Bugs  
- If you're a crazy person who has a 21:9 display with two side 4:3 displays, the UI will be 16:9. It's either this or potentially have issues with bezel correction. =p
