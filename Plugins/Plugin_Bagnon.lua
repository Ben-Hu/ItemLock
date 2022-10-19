local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginBagnon = ItemLock:NewModule("PluginBagnon")

function PluginBagnon:Init()
  hooksecurefunc(Bagnon.Item, "Update", function(slotFrame)
    local bagID = slotFrame:GetBag()
    ItemLock:UpdateSlot(bagID, slotFrame)
  end)
end

function PluginBagnon:GetSlotFrame(bagID, slotIndex)
  local containerFrameIndex = bagID + 1
  local itemIndex = GetContainerNumSlots(bagID) - (slotIndex - 1)

  -- bagnon splits container frames into fixed 36 slot chunks
  -- rather than the container capacity
  local slotOffset = slotIndex + 1

  for i = bagID - 1, 0, -1 do
    slotOffset = slotOffset + GetContainerNumSlots(i)
  end

  containerFrameIndex = ceil(slotOffset / 36)
  itemIndex = slotOffset - (containerFrameIndex - 1) * 36

  return _G["ContainerFrame" .. containerFrameIndex .. "Item" .. itemIndex]
end
