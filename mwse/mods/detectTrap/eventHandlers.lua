local eventHandlers = {};

local config  = require("detectTrap.config");
local strings = require("detectTrap.strings");
local utility = require("detectTrap.utility");

eventHandlers.initialized = function ()

  if (mwse.buildDate == nil) or (mwse.buildDate < 20190827) then
    utility.warn(strings.mwseOutOfDate);
  end
  
  math.randomseed( os.time() );
  eventHandlers.uiObjectTooltip.guiIds.parent     = tes3ui.registerID("DT_Tooltip_Parent");
  eventHandlers.uiObjectTooltip.guiIds.trapStatus = tes3ui.registerID("DT_Tooltip_Weight");

  local feature_hiddenTraps = 70;

  if not tes3.hasCodePatchFeature(feature_hiddenTraps) then
    utility.error(strings.noHiddenTrapError);
    utility.unregisterAll(eventHandlers);
  end
  
  utility.log(string.format(strings.initialized, config.version));
end;

eventHandlers.uiObjectTooltip = {
  handler = (function(e)
    local ref = e.reference;
    
    if not utility.isLockable(ref) then return end
    
    local trapped = tes3.getTrap({reference = ref}) and true or false;
    local detected = nil;
    
    utility.dbgMsg("Beginning detection for \"" .. ref.id .. "\"");
    
        
    if ref.data.DT then
      utility.dbgMsg("    Cached data found.")
      detected = ref.data.DT.detected;
      
      -- If the player has attempted to disarm the trap, succeed at detection
      if ref.data.DT.disarmAttempted then
        utility.dbgMsg("    Disarm has been attempted.")
        detected = true;
        ref.data.DT.detected = true;
        ref.data.DT.trapped = trapped;
      elseif not detected and tes3.mobilePlayer.security.current > ref.data.DT.playerSkill then
        utility.dbgMsg("    Player's security skill has increased; rerolling.");
        detected = nil;
      end
    end
    
    if detected == nil then
      local rand = math.random()
      local threshold = utility.getDetectProbability();
      detected = rand <= threshold;
      
      utility.dbgMsg("    Detection roll: " .. rand * 1000 .. "/" .. threshold * 1000);
      
      if not ref.data.DT then
        ref.data.DT = {}
      end
      ref.data.DT.detected = detected;
      ref.data.DT.trapped  = trapped;
      ref.data.DT.playerSkill = tes3.mobilePlayer.security.current;
    end
    
    local guiIds = eventHandlers.uiObjectTooltip.guiIds;
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
  end),
  params = { priority=150 },
  guiIds = {}
};

eventHandlers.cellChanged = function (e)
  -- On entering a cell, reset all detect trap cached data
  -- Looking at previousCell might be logically better, but no guarantee the
  -- references are still correctly loaded.
  for ref in e.cell:iterateReferences() do
    if utility.isLockable(ref) then
      if ref.data.DT then
        utility.dbgMsg("Uncaching object: " .. ref.id)
        ref.data.DT = nil
      end
    end
  end
end

eventHandlers.trapDisarm = function (e)
  if not utility.isLockable(e.reference) then return end
  
  if not e.reference.data.DT then
    e.reference.data.DT = {}
  end
  
  if not e.reference.data.DT.disarmAttempted then
    e.reference.data.DT.disarmAttempted = true;
    e.clearTarget = true;
  end
  
end

return eventHandlers;