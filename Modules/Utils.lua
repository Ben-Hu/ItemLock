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

function Utils:GetSlotsByBagID()
  local slotsByBagID = {}

  for bagID = 0, NUM_BAG_SLOTS do
    slotsByBagID[bagID] = {}
    for slotIndex = 1, GetContainerNumSlots(bagID) do
      if GetContainerItemID(bagID, slotIndex) then
        local slotFrame = self:GetSlotFrame(bagID, slotIndex)
        tinsert(slotsByBagID[bagID], slotFrame)
      end
    end
  end

  return slotsByBagID
end

function Utils:GetSlotFrame(bagID, slotIndex)
  if IsAddOnLoaded("Bagnon") then
    return Utils:GetBagnonSlotFrame(bagID, slotIndex)
  elseif IsAddOnLoaded("ElvUI") then
    return Utils:GetElvUISlotFrame(bagID, slotIndex)
  else
    return Utils:GetDefaultSlotframe(bagID, slotIndex)
  end
end

function Utils:GetBagnonSlotFrame(bagID, slotIndex)
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

function Utils:GetElvUISlotFrame(bagID, slotIndex)
  local containerFrameIndex = bagID
  local itemIndex = slotIndex
  local customFrame = _G["ElvUI_ContainerFrameBag" .. containerFrameIndex .. "Slot" .. itemIndex]

  if customFrame then
    return customFrame
  else
    -- return default frame ElvUI's bag module is disabled
    return Utils:GetDefaultSlotframe(bagID, slotIndex)
  end
end

function Utils:GetDefaultSlotframe(bagID, slotIndex)
  local containerFrameIndex = bagID + 1
  local itemIndex = GetContainerNumSlots(bagID) - (slotIndex - 1)

  return _G["ContainerFrame" .. containerFrameIndex .. "Item" .. itemIndex]
end
