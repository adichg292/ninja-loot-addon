local addonName, addon = ...

addon.name = addonName

addon.mainFrame = addon.UI.CreateMainWindow()

print(addonName .. " loaded!")
