local EasyMCM = require("easyMCM.EasyMCM");
local config  = require("detectTrap.config");
local strings = require("detectTrap.strings");
local utility = require("detectTrap.utility");


local template = EasyMCM.createTemplate(strings.mcm.modName);
template:saveOnClose("detectTrap", config);
template:register();

local page = template:createSideBarPage({
  label = strings.mcm.settings,
});
local settings = page:createCategory(strings.mcm.settings);
settings:createOnOffButton({
  label = strings.mcm.debugMode,
  description = strings.mcm.debugModeDesc,
  variable = EasyMCM.createTableVariable {
    id = "debugEnabled",
    table = config
  }
});

local difficulty = page:createCategory(strings.mcm.difficulty);
difficulty:createSlider({
  label = strings.mcm.midpoint,
  max = 130,
  description = strings.mcm.midpointDesc,
  variable = EasyMCM.createTableVariable {
    id = "midpoint",
    table = config.smoother
  }
});

difficulty:createSlider({
  label = strings.mcm.steepness,
  description = strings.mcm.steepnessDesc,
  min = 0,
  max = 100,
  step = 1,
  jump = 20,
  variable = EasyMCM.createVariable {
    get = function (self)
      return 100 * config.smoother.steepness;
    end,
    set = function (self, value)
      config.smoother.steepness = value / 100;
    end
  }
});

local getContainersAndDoors = function()
  local list = {}
  for obj in tes3.iterateObjects(tes3.objectType.container) do
    list[#list+1] = (obj.baseObject or obj).id:lower()
  end
  for obj in tes3.iterateObjects(tes3.objectType.door) do
    list[#list+1] = (obj.baseObject or obj).id:lower()
  end
  table.sort(list)
  
  return list
end

template:createExclusionsPage({
  label = strings.mcm.blacklist,
  description = strings.mcm.blacklistDesc,
  leftListLabel = strings.mcm.blacklist,
  rightListLabel = strings.mcm.objects,
  
  variable = EasyMCM:createTableVariable({
    id = "blacklist",
    table = config
  });
  
  filters = {
    { callback = getContainersAndDoors }
  }
});

template:createExclusionsPage({
  label = strings.mcm.whitelist,
  description = strings.mcm.whitelistDesc,
  leftListLabel = strings.mcm.whitelist,
  rightListLabel = strings.mcm.objects,
  
  variable = EasyMCM:createTableVariable({
    id = "whitelist",
    table = config
  });
  
  filters = {
    { callback = getContainersAndDoors }
  }
});