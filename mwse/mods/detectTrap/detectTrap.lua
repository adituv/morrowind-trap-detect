local config = require("detectTrap.config");
local strings = require("detectTrap.strings");
local strings_en = require("detectTrap.strings_en");
local utility = require("detectTrap.utility");

local feature_hiddenTraps = 70;

local DetectTrap = {
  eventHandlers = {},
  guiIds = {}
};

DetectTrap.new = function (self, o)
  o = o or {};
  setmetatable(o, self);
  self.__index = self;
  return o;
end;

DetectTrap.init = function (self)
  self.eventHandlers = {
    initialized = function () self:initialized() end,
    uiObjectTooltip = function (e) self:overrideTooltip(e) end,
    cellChanged = function(e) self:clearCachesInCell(e) end,
    trapDisarm = function(e) self:trapDisarmAttempted(e) end
  };
  
  utility.registerAll(self.eventHandlers);
end;

local getCachedData = function (ref)
  if ref.data.DT then
    utility.dbgMsg("    Cached data found.");
  end
  
  return ref.data.DT or nil;
end;

local createCache = function (ref)
  ref.data.DT = {};
  
  return ref.data.DT;
end;

local clearCache = function (ref)
  ref.data.DT = nil;
end

local getFatigueTerm = function (mobileActor)
  local fFatigueMult = tes3.findGMST(tes3.gmst.fFatigueMult).value;
  local fFatigueBase = tes3.findGMST(tes3.gmst.fFatigueBase).value;
  
  return fFatigueMult*mobileActor.fatigue.normalized + fFatigueBase;
end

local getEffectiveSecurity = function (mobileNPC)
  local security = mobileNPC.security.current;
  local intelligence = mobileNPC.security.current;
  local luck = mobileNPC.security.current;
  
  return security + (intelligence / 5) + (luck / 10);
end

local getDetectProbability = function ()
  local effectiveSecurity = getEffectiveSecurity(tes3.mobilePlayer);
  local fatigueTerm = getFatigueTerm(tes3.mobilePlayer);  
  
  local effectiveLevel = fatigueTerm * effectiveSecurity;
  
  local smoother = utility.mkLogistic(0,1,config.smoother.steepness,config.smoother.midpoint);
  return smoother(effectiveLevel);
end

local isLockable = function (ref)
  -- For now, assume something can be locked if it is a door, or if it is a container
  -- that is not organic.
  -- TODO: Whitelist, blacklist for weird organic settings?  Graphic Herbalism
  -- compatibility?
  if not ((ref.object.objectType == tes3.objectType.container)
       or (ref.object.objectType == tes3.objectType.door)) then
    return false
  end
  
  local lockable = true;
  if ref.object.objectType == tes3.objectType.container then
    lockable = not ref.object.organic;
  end
  
  local id = ref.baseObject.id:lower();
  if config.blacklist[id] then lockable = false end;
  if config.whitelist[id] then lockable = true end;
  
  return lockable;
end

DetectTrap.initialized = function (self)
  if (mwse.buildDate == nil) or (mwse.buildDate < 20190828) then
    utility.warn("mwseOutOfDate");
  end
  
  math.randomseed( os.time() );
  
  self.guiIds.parent = tes3ui.registerID("DT_Tooltip_Parent");
  self.guiIds.trapStatus = tes3ui.registerID("DT_Tooltip_Trap");

  if not tes3.hasCodePatchFeature(feature_hiddenTraps) then
    utility.error("noHiddenTrapError");
    return;
  end
    
  utility.log(string.format(strings_en.initialized, config.version));
end

DetectTrap.overrideTooltip = function (self,e)
  local ref = e.reference;
  
  if not isLockable(ref) then return end
  local trapped = utility.coerceBool(tes3.getTrap({reference = ref}));
  local detected = nil;
  
  utility.dbgMsg("Beginning detection for \"" .. ref.id .. "\"");
  
  local cache = getCachedData(ref);
  
  if cache then
    utility.dbgMsg("    Cached data found.")
    detected = cache.detected;
    
    -- If the player has attempted to disarm the trap, succeed at detection
    if cache.disarmAttempted then
      utility.dbgMsg("    Disarm has been attempted.")
      detected = true;
      cache.detected = true;
      cache.trapped = trapped;
    elseif not detected and getEffectiveSecurity(tes3.mobilePlayer) > cache.playerSkill then
      utility.dbgMsg("    Player's security skill has increased; rerolling.");
      detected = nil;
    end
  end
  
  if detected == nil then
    local rand = math.random()
    local threshold = getDetectProbability();
    detected = rand <= threshold;
    
    utility.dbgMsg("    Detection roll: " .. rand * 1000 .. "/" .. threshold * 1000);
    
    if not cache then
      cache = createCache(ref);
    end
    cache.detected = detected;
    cache.trapped  = trapped;
    cache.playerSkill = getEffectiveSecurity(tes3.mobilePlayer);
  end
  
  local guiIds = self.guiIds;
  local parent = e.tooltip:createBlock({id=guiIds.parent});
  parent.autoHeight = true;
  parent.autoWidth = true;
  
  local trapMessage = strings.unknown;
  if (detected) then
    -- Trap or no trap successfully detected
    if not tes3.getTrap({reference = ref}) then
      trapMessage = strings.untrapped;
    else
      trapMessage = strings.trapped;
    end
  end
  
  parent:createLabel({id=guiIds.trapStatus, text=trapMessage});
  
  utility.dbgMsg("End detection for \"" .. ref.id .. "\"");
end

DetectTrap.clearCachesInCell = function (self, e)
  -- On entering a cell, reset all detect trap cached data
  -- Looking at previousCell might be logically better, but no guarantee the
  -- references are still correctly loaded.
  for ref in e.cell:iterateReferences() do
    if isLockable(ref) then
      local cache = getCachedData(ref);
      if cache then
        utility.dbgMsg("Uncaching object: " .. ref.id)
        clearCache(ref);
      end
    end
  end
end

DetectTrap.trapDisarmAttempted = function (self, e)
  local ref = e.reference;
  
  if not isLockable(ref) then return end;
  
  local cache = getCachedData(ref);
  if not cache then
    cache = createCache(ref);
  end
  
  if not cache.disarmAttempted then
    cache.disarmAttempted = true;
    e.clearTarget = true;
  end
end

return DetectTrap