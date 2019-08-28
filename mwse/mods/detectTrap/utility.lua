local utility = {};
local config = require("detectTrap.config");
local strings = require("detectTrap.strings");
local strings_en = require("detectTrap.strings_en");

utility.coerceBool = function (x)
  return x and true or false;
end

-- Returns a logistic function with the given parameters:
--  minV: the y-coordinate of the lower asymptote
--  maxV: the y-coordinate of the upper asymptote
--  steepness: the steepness of the curve
--  midpoint: the x-coordinate of the curve's midpoint
utility.mkLogistic = function (minV, maxV, steepness, midpoint)
  return (function (x)
    return minV + (maxV - minV) / (1 + math.exp(-1 * steepness * (x - midpoint)));
  end);
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
  utility.log(string.format("ERROR: " .. strings_en[message], ...));
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
    else
      utility.error("invalidHandlerRegistering", k)
    end
  end
end

utility.unregisterAll = function (handlers)
  for k,v in pairs(handlers) do
    if type(v) == "function" then
      event.unregister(k,v)
    else
      utility.warn("invalidHandlerUnregistering", k)
    end
  end
end

return utility;