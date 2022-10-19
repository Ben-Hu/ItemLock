local ItemLock = LibStub("AceAddon-3.0"):GetAddon("ItemLock")
local Logger = ItemLock:NewModule("Logger")


local logLevels = {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3
}

function Logger:Init(config)
  self.config = config
end

function Logger:Debug(...)
  self:MaybeLog("DEBUG", ...)
end

function Logger:Info(...)
  self:MaybeLog("INFO", ...)
end

function Logger:Warn(...)
  self:MaybeLog("WARN", ...)
end

function Logger:Error(...)
  self:MaybeLog("ERROR", ...)
end

function Logger:Print(...)
  ItemLock:Print(...)
end

function Logger:MaybeLog(level, ...)
  if logLevels[self.config:GetLogLevel()] <= logLevels[level] then
    ItemLock:Print(...)
  end
end
