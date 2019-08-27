Skill-based Trap Detection
Version 0.9b
By AdituV

With thanks to Graphic Herbalism, the lua source of which I used as reference while
developing this.

Skill-based Trap Detection is a pure-lua mod to allow the player to have a chance to
successfully detect a trap based on their security skill and relevant attributes, with a
formula similar to the vanilla game.

This beta version has all core functionality implemented, but is missing some bells
and whistles, such as configurable parameters in the MCM, having an MCM entry at all,
and potentially adding spells to interact with traps.


License
=======

All Lua code in this mod is licensed under the 3-Clause BSD License, a copy of which is
found in the file "Skill-based Detect Trap - LICENSE.txt".


Requirements
============

* Morrowind Code Patch - in particular, the "Traps hidden" option under "Game Mechanics"
* MWSE 2.1, after 2019-08-27


Installation
============

Install as normal with a mod manager of your choice, or extract the files directly to
Data Files.  The usual.


Changelog
=========
0.9.0 - Initial beta release

Details
=======

On looking at an object that can be locked (currently defined as a door or a container
that is not organic), your "effective skill level" is calculated, smoothed, and
compared to a randomly generated number.  The result of this is cached until you change
cells or until your Security skill increases - this includes temporary bonuses.

Your "effective skill level" is calculated with this formula:

    effective level = fatigueMod * (security + (agility / 5) + (luck / 10))

Where

    fatigueMod = 0.25 * normalizedFatigue + 0.75

fatigueMod ranges from 0.75 to 1.25; this is likely to be both changed and made an MCM
setting in a future version.

The effective level is smoothed along a sigmoid curve; currently this curve is hardcoded as:

    f(level) = 1 / (1 + e^(-0.05 * (level - 70))

Again, the parameters of this curve will probably be tweaked and exposed via the MCM
in a future version.

The random number generated is uniform between 0 and 1, and if that number is less than
the smoothed effective level, the detection is considered a success.  Depending on
whether the object in question is trapped or not, either "Untrapped" or "Trapped"
will be added to the tooltip.  If detection fails, "???" will be added to the tooltip.


Planned Features
================

* MCM to tweak detection parameters
* Whitelist and blacklist to fine-tune whether something is lockable
* For exteriors, don't clear cache when moving from exterior to exterior
* For exteriors, clear cache on a timer
* Spell to boost detection chance
* Spell to add a visual effect to trapped things (this is a bit of a pipe dream tbh)