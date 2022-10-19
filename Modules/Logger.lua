local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Logger = ItemLock:NewModule("Logger")

function Logger:Init(config)
  self.config = config
end

function Logger:Debug(...)
  if self.config:IsVerboseEnabled() then
    ItemLock:Print(...)
  end
end

function Logger:Info(...)
  if self.config:IsVerboseEnabled() then
    ItemLock:Print(...)
  end
end

function Logger:Warn(...)
  ItemLock:Print(...)
end

function Logger:Error(...)
  ItemLock:Print(...)
end

function Logger:Puts(...)
  ItemLock:Print(...)
end
