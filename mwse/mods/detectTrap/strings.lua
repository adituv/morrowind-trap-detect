local strings = {}

strings.trapped = "Trapped";
strings.untrapped = "Untrapped";
strings.unknown = "???";

strings.noHiddenTrapError = "MCP's \"Hidden traps\" option is not enabled";
strings.errorOccurred = "An error has occurred"
strings.warning = "Warning"

strings.ok = "OK"

strings.initialized = "Initialized Version %s"
strings.mwseOutOfDate = "Your MWSE is out of date! You will need to update to a more recent version to use this mod."

strings.invalidHandlerRegistering = "Invalid handler when registering event \"%s\""
strings.invalidHandlerUnregistering = "Invalid handler when unregistering event \"%s\""

strings.mcm = {
  modName = "Skill-based Trap Detection",
  debugMode = "Debug Mode",
  debugModeDesc = "Enable extra log messages in MWSE.log",
  settings  = "Settings",
  difficulty = "Difficulty",
  midpoint = "Midpoint",
  midpointDesc = "The effective skill level required to have a 50% chance of detecting a trap.\n"
    .. "Your effective skill level is: Security + (Intelligence / 5) + (Luck / 10).\n"
    .. "Default: 70",
  steepness = "Steepness",
  steepnessDesc = "Steepness affects the shape of the probability curve.\n\n"
    .. "High steepness makes the probability increase faster around the midpoint, and increase slower "
    .. "further from the midpoint, and vice versa.  Default: 5."
}

return strings;