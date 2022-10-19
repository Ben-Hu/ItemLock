local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Utils = ItemLock:NewModule("Utils")

function Utils:GetTooltipItemID()
  local _itemName, itemLink = GameTooltip:GetItem()
  return self:ItemLinkToItemID(itemLink)
end

function Utils:ItemLinkToItemID(itemLink)
  if itemLink == nil then return nil end
  return tonumber(strmatch(itemLink, "item:(%d+):"))
end

function Utils:GetEquipmentSetItemIDs()
  local equipmentSetItemIds = {}

  for setID = 0, C_EquipmentSet.GetNumEquipmentSets() do
    local itemArray = C_EquipmentSet.GetItemIDs(setID)
    for itemIndex = 1, 19 do
      if itemArray and itemArray[itemIndex] then
        equipmentSetItemIds[itemArray[itemIndex]] = true
      end
    end
  end

  return equipmentSetItemIds
end

function Utils:GetSlotsByBagID(plugin)
  local slotsByBagID = {}

  for bagID = 0, NUM_BAG_SLOTS do
    slotsByBagID[bagID] = {}
    for slotIndex = 1, GetContainerNumSlots(bagID) do
      if GetContainerItemID(bagID, slotIndex) then
        local slotFrame = plugin:GetSlotFrame(bagID, slotIndex)
        tinsert(slotsByBagID[bagID], slotFrame)
      end
    end
  end

  return slotsByBagID
end
