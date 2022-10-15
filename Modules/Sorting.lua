local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Sorting = ItemLock:NewModule("Sorting")

function Sorting:Init(repo, config)
  if IsAddOnLoaded("Bagnon") then
    self:OverloadBagnonSorting(repo, config)

    if _G.SortBags then
      self:OverloadGlobalSortBags(config)
    end
  end
end

function Sorting:OverloadBagnonSorting(repo, config)
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
end

function Sorting:OverloadGlobalSortBags(config)
  local sortBags = _G.SortBags

  function _G.SortBags()
    if config:IsSortLockEnabled() then
      Bagnon.Sorting:Start(UnitName('player'), Bagnon.InventoryFrame.Bags)
    else
      sortBags()
    end
  end
end
