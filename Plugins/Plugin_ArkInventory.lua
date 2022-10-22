local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginArkInventory = ItemLock:NewModule("PluginArkInventory")

function PluginArkInventory:Init(repo, config)
  hooksecurefunc(ArkInventory.API, "ItemFrameUpdated", function(slotFrame)
    if not slotFrame.ARK_Data then return end
    local bagID = ArkInventory.InternalIdToBlizzardBagId(slotFrame.ARK_Data.loc_id, slotFrame.ARK_Data.bag_id)
    ItemLock:UpdateSlot(bagID, slotFrame)
  end)
end

function PluginArkInventory:GetSlotFrame(bagID, slotIndex)
  local containerFrameIndex = bagID + 1
  local itemIndex = slotIndex
  return _G["ARKINV_Frame1ScrollContainerBag" .. containerFrameIndex .. "Item" .. itemIndex]
end

function PluginArkInventory:CustomSort(repo, config)
  -- noop
end
