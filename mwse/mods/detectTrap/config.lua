return mwse.loadConfig("detectTrap") or {

    version = "0.9.0b";
    debugEnabled = false;

    smoother = {
        steepness = 0.05,
        midpoint = 70
    }
}