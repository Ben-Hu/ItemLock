local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginBagnonCombuctor = ItemLock:NewModule("PluginBagnonCombuctor")

local GetContainerNumSlots
if C_Container then
  GetContainerNumSlots = C_Container.GetContainerNumSlots
else
  GetContainerNumSlots = _G.GetContainerNumSlots
end

local function maybeOverrideSortBags(addon)
  local customSort = function()
    addon.Sorting:Start(addon.Inventory)
  end

  if C_Container and C_Container.SortBags then
    C_Container.SortBags = customSort
  elseif _G.SortBags then
    _G.SortBags = customSort
  end
end

local function setupCustomSort(addon, repo, config)
  local GetOrder = addon.Sorting.GetOrder

  function addon.Sorting:GetOrder(spaces, family)
    if config:IsSortLockEnabled() then
      local newSpaces = {}

      for _, space in pairs(spaces) do
        if space.item == nil or not repo:IsItemLocked(space.item.id, config) then
          table.insert(newSpaces, space)
        else
          space.item.sorted = true
        end
      end

      return GetOrder(self, newSpaces, family)
    else
      return GetOrder(self, spaces, family)
    end
  end

  maybeOverrideSortBags(addon)
end

function PluginBagnonCombuctor:Init(repo, config)
  local addon = Bagnon or Combuctor

  hooksecurefunc(addon.Item, "Update", function(slotFrame)
    local bagID = slotFrame:GetBag()
    ItemLock:UpdateSlot(bagID, slotFrame)
  end)

  setupCustomSort(addon, repo, config)
end

function PluginBagnonCombuctor:GetSlotFrame(bagID, slotIndex)
  local bagIndex = bagID - 1
  local slotOffset = slotIndex

  -- Bagnon no longer separates frames by a container frame index
  -- Slot indexes are contiguous and based on underlying container capacity
  for containerIndex = 0, bagIndex, 1 do
    slotOffset = slotOffset + GetContainerNumSlots(containerIndex)
  end

  return _G["BagnonContainerItem" .. slotOffset]
end
