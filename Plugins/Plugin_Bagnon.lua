local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local PluginBagnon = ItemLock:NewModule("PluginBagnon")

function PluginBagnon:Init(repo, config)
  hooksecurefunc(Bagnon.Item, "Update", function(slotFrame)
    local bagID = slotFrame:GetBag()
    ItemLock:UpdateSlot(bagID, slotFrame)
  end)

  self:CustomSort(repo, config)
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

function PluginBagnon:CustomSort(repo, config)
  local GetOrder = Bagnon.Sorting.GetOrder

  function Bagnon.Sorting:GetOrder(spaces, family)
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

  -- overload global sort to use Bagnon's custom sorting if the sort lock feature is enabled.
  if _G.SortBags then
    local sortBags = _G.SortBags

    function _G.SortBags()
      if config:IsSortLockEnabled() then
        Bagnon.Sorting:Start(UnitName('player'), Bagnon.InventoryFrame.Bags)
      else
        sortBags()
      end
    end
  end
end
