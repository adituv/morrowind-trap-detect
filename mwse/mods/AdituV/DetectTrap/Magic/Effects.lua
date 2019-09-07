local Config = require("AdituV.DetectTrap.Config");
local LockData = require("AdituV.DetectTrap.LockData");
local Strings = require("AdituV.DetectTrap.Strings");
local Utility = require("AdituV.DetectTrap.Utility");

local ME = include("OperatorJack.MagickaExpanded.MagickaExpanded");

local Effects = {};

tes3.claimSpellEffectId("adv_dt_untrap", Config["adv_dt_untrap"].numId);

local createUntrapEffect = function()
  ME.effects.alteration.createBasicEffect({
    id = "adv_dt_untrap",
    name = Strings.effects.untrap,
    description = Strings.effects.untrapDescription,
    
    baseCost = Config.effects["adv_dt_untrap"].baseCost,
    speed = Config.effects["adv_dt_untrap"].speed,
    
    allowEnchanting = true,
    allowSpellmaking = true,
    canCastTarget = true,
    canCastTouch = true,
    
    hasNoDuration = true,
    hasNoMagnitude = true,
    unreflectable = true,
    
    lighting = Config.effects["adv_dt_untrap"].lighting,
    
    onTick = function(e) 
      if not e:trigger() then
        return
      end
      
      local ld = LockData.getForReference(e.target);
      if ld then
        ld:setTrapDetected(true);
        
        event.trigger("trapDisarm", {
          reference = e.target,
          lockData = e.target.attachments.lock,
          disarmer = e.caster,
          
          -- Pretend we're using the SecretMaster's Probe to try
          -- to maintain compatibility with other mods using trapDisarm
          tool = {
            id = "probe_secretmaster",
          },
          toolItemData = {
            charge = 0,
            condition = 25,
            data = {}
          },
          chance = 100,
          trapPresent = true
        });
        
        if ld.trapped then
          tes3.playSound({
            sound = "Disarm Trap",
            reference = e.target
          });
          tes3.setTrap({reference = e.target, spell = nil});
          
          tes3.messageBox(Strings.effects.untrapSuccess);
        end
      end
      
      e.effectInstance.state = tes3.spellState.retired;
    end
  })
end

Effects.registerEffects = function()
  createUntrapEffect();
end

return Effects;