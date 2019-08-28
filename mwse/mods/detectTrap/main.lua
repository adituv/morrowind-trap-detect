local detectTrap = require("detectTrap.detectTrap");

event.register("modConfigReady", function()
  require("detectTrap.mcm");
end);

detectTrap:init();