local Config = require("AdituV.DetectTrap.Config");
local LockData = require("AdituV.DetectTrap.LockData");
local Strings = require("AdituV.DetectTrap.Strings");
local Utility = require("AdituV.DetectTrap.Utility");

local defaultEffect = {
  speed = 1,

  allowEnchanting = false,
  allowSpellmaking = false,
  appliesOnce = false,
  canCastSelf = false,
  canCastTarget = false,
  canCastTouch = false,
  casterLinked = false,
  hasContinuousVFX = false,
  hasNoDuration = false,
  hasNoMagnitude = false,
  illegalDaedra = false,
  isHarmful = false,
  nonRecastable = false,
  targetsAttributes = false,
  targetsSkills = false,
  unreflectable = false,
  usesNegativeLighting = false,

  -- Icons and sounds must be set
  -- Lighting must be set
  -- Callbacks must be set
  size = 1,
  sizeCap = 50
}

local Effects = {};
Effects.definitions["adv_dt_untrap"] = {
  id = "adv_dt_untrap",
  name = Strings.effects.untrap,
  description = Strings.effects.untrapDescription,
  school = tes3.magicSchool.alteration;

  baseCost = Config.effects["adv_dt_untrap"].baseCost,
  speed = Config.effects["adv_dt_untrap"].speed,

  allowEnchanting = true,
  allowSpellmaking = true,
  appliesOnce = false,
  canCastTarget = true,
  canCastTouch = true,

  hasNoDuration = true,
  hasNoMagnitude = true,
  unreflectable = true,

  icon = "s/Tx_S_open.tga",
  particleTexture = "vfx_alt_glow.tga",
  castSound = "alteration cast",
  castVFX = "VFX_AlterationCast",
  boltSound = "alteration bolt",
  boltVFX = "VFX_AlterationBolt",
  hitSound = "alteration hit",
  hitVFX = "VFX_AlterationHit",
  areaSound = "alteration area",
  areaVFX = "VFX_AlterationArea",
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
}

for k,v in pairs(Effects.definitions) do
  setmetatable(v,v);
  v.__index = defaultEffect;

  tes3.claimSpellEffectId(k, Config.effects[k].numId);
end

Effects.registerEffects = function()
  for _,v in pairs(Effects.definitions) do
    tes3.addMagicEffect(v);
  end
end

return Effects;