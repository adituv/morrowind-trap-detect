local utility = {};
local config = require("detectTrap.config");
local strings = require("detectTrap.strings");
local strings_en = require("detectTrap.strings_en");


-- Returns a logistic function with the given parameters:
--  minV: the y-coordinate of the lower asymptote
--  maxV: the y-coordinate of the upper asymptote
--  steepness: the steepness of the curve
--  midpoint: the x-coordinate of the curve's midpoint
local function mkLogistic(minV, maxV, steepness, midpoint)
  return (function (x)
    return minV + (maxV - minV) / (1 + math.exp(-1 * steepness * (x - midpoint)));
  end);
end

utility.getDetectProbability = function ()
  local player = tes3.mobilePlayer;
  local security = player.security.current;
  local intelligence = player.intelligence.current;
  local luck = player.luck.current;
  local fatigueMod = 0.25*player.fatigue.normalized + 0.75;
  
  local effectiveLevel = fatigueMod * (security + (intelligence / 5) + (luck / 10));
  return mkLogistic(0, 1, 0.05, 70)(effectiveLevel);
end

utility.isLockable = function (ref)
  -- For now, assume something can be locked if it is a door, or if it is a container
  -- that is not organic.
  -- TODO: Whitelist, blacklist for weird organic settings?  Graphic Herbalism
  -- compatibility?
  
  return ref
    and ((ref.object.objectType == tes3.objectType.container and not ref.object.organic)
      or (ref.object.objectType == tes3.objectType.door));
end

-- NB. Debug messages aren't localized as they are intended for the developer
utility.dbgMsg = function (message, ...)
  if config.debugEnabled == true then
    utility.log(string.format(message, ...));
  end
end

utility.log = function (message, ...)
  mwse.log("[Detect Trap] " .. string.format(message, ...));
end

utility.error = function (message, ...)
  
  utility.log(string.format("ERROR: " .. strings_en.errors[message], ...));
  tes3.messageBox({
    message = string.format("[Detect Trap] %s:\n%s", strings.errorOccurred, string.format(strings[message], ...)),
    buttons = strings.ok
  });
end

utility.warn = function (message, ...)
  utility.log(string.format("WARN: " .. strings_en[message], ...));
  tes3.messageBox(string.format("[Detect Trap] %s: %s", strings.warning, string.format(strings[message], ...)));
end

utility.registerAll = function (handlers)
  for k,v in pairs(handlers) do
    if type(v) == "function" then
      event.register(k, v);
    elseif type(v) == "table" and type(v.handler) == "function" then
      event.register(k, v.handler, v.params);
    else
      utility.error("invalidHandlerRegistering", k)
    end
  end
end

utility.unregisterAll = function (handlers)
  for k,v in pairs(handlers) do
    if type(v) == "function" then
      event.unregister(k,v)
    elseif type(v) == "table" and type(v.handler) == "function" then
      event.unregister(k, v.handler)
    else
      utility.warn("invalidHandlerUnregistering", k)
    end
  end
end

return utility;