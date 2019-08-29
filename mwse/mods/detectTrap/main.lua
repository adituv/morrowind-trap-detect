local detectTrap = require("detectTrap.detectTrap");

event.register("modConfigReady", function()
  require("detectTrap.mcm");
end);

detectTrap:init();

local highlightTraps = function()
  local cell = tes3.mobilePlayer.cell;
  
  for v in cell:iterateReferences(tes3.objectType.container) do
    local oldlight = v:getAttachedDynamicLight();
    if oldLight ~= nil then
      v:detachDynamicLightFromAffectedNodes()
    end
    
    local light = {
      constantAttenuation = 0.0,
      linearAttenuation = 0.0,
      quadraticAttenuation = 3.5,
      ambient = {
        r = 1.0,
        g = 0.0,
        b = 0.0
      }
    };
    
    
    local lightNode = {
      light = light,
      value = 1.0
    };
    
    v:getOrCreateAttachedDynamicLight(lightNode);
  end
end;


event.register("keyDown", highlightTraps, { filter = tes3.scanCode.k });