local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginAdiBags = ItemLock:NewModule("PluginAdiBags")

function PluginAdiBags:Init()
  local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
  local AdiBagsItemButton = AdiBags:GetClass("ItemButton")
  local AdiBagsItemButtonPrototype = AdiBagsItemButton.prototype

  hooksecurefunc(AdiBagsItemButtonPrototype, "Update", function(self)
    ItemLock:UpdateSlot(self.bag, self)
  end)
end

function PluginAdiBags:GetSlotFrame(bagID, slotIndex)
  local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
  local AdiBagsContainer = _G["AdiBagsContainer1"]
  if not AdiBagsContainer or not AdiBagsContainer.sections then return end

  for _k, section in pairs(AdiBagsContainer.sections) do
    for button, adiBagsSlotID in pairs(section.buttons) do
      local bagID = AdiBags.GetBagSlotFromId(adiBagsSlotID)
      ItemLock:UpdateSlot(bagID, button)
    end
  end
end
