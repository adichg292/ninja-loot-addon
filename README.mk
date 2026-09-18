NinjaLoot

Master Looter assistant for World of Warcraft raids.

Author: Pastah
Version: 0.1.0
Initial system: Round Robin
Planned: EPGP, DKP, Loot Council, GDKP

Purpose

NinjaLoot helps the Master Looter manage raid loot from boss kill to final award.

It handles:

Raid and player tracking
Boss loot
Loot distribution
Need / Pass
/roll players without NinjaLoot
Winner selection
Award and trade tracking
Loot history
Session persistence
Master Looter handoff
Session

A NinjaLoot session represents the current raid.

It survives closing the UI and can continue if the Master Looter changes.

The ML chooses the loot system when starting the session.

Loot Flow
Raid
 ↓
Boss Loot
 ↓
Select Item
 ↓
Distribute
 ↓
Need / Pass / /roll
 ↓
ML selects recipient
 ↓
Confirm
 ↓
Award / Trade
 ↓
History
Round Robin
Everyone can Need or Pass.
NEED starts a WoW /roll.
Normal /roll is also supported.
Roll period: 20 seconds
/roll grace period: 1 second
Highest Need roll is suggested.
ML makes the final decision.
No automatic awarding.
Restarts

A distribution can be restarted.

Previous attempts are preserved in history.

Restart voting requires up to 4 participants, depending on group size.

Loot History

NinjaLoot records what happened to each item:

loot → responses → rolls → winner → award → restarts → final result

Future

After Round Robin is complete:

EPGP → DKP → Loot Council → GDKP