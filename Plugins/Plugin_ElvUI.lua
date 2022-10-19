local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginElvUI = ItemLock:NewModule("PluginElvUI")

function PluginElvUI:Init()
  local E, L, V, P, G = unpack(ElvUI)

  self.logger = ItemLock:GetModule("Logger")

  -- Initialize the default plugin as a fallback if ElvUI's bag module is disabled and
  -- the default bags are used
  self.default = ItemLock:GetModule("PluginDefault")
  self.default:Init()

  hooksecurefunc(E:GetModule("Bags"), "UpdateSlot", function(self, frame, bagID, slotID)
    local bag = frame.Bags[bagID]
    local slot = bag and bag[slotID]
    ItemLock:UpdateSlot(bagID, slot)
  end)
end

function PluginElvUI:GetSlotFrame(bagID, slotIndex)
  local containerFrameIndex

  if ItemLock:GetModule("Utils"):IsClassic() then
    containerFrameIndex = bagID - 1
  else
    containerFrameIndex = bagID
  end

  local itemIndex = slotIndex

  local customFrame = _G["ElvUI_ContainerFrameBag" .. containerFrameIndex .. "Slot" .. itemIndex]

  if customFrame then
    return customFrame
  else
    return self.default:GetSlotFrame(bagID, slotIndex)
  end
end
