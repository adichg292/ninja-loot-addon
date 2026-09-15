# NinjaLoot

> A Master Looter assistant for World of Warcraft raids.

**Author:** Pastah
**Version:** 0.1.0
**Current loot system implementation:** Round Robin
**Supported loot system types:** EPGP, DKP, Round Robin, Loot Council, GDKP

---

## Overview

**NinjaLoot** is a raid loot-management addon designed to assist the Master Looter with organizing, distributing, and recording raid loot.

The addon is built around a **loot session**.

The UI is only a view into that session. Closing the addon window does not destroy or reset the session. When the addon is opened again, it resumes from the current state.

NinjaLoot is intended to:

* Detect when the player becomes Master Looter.
* Initialize a loot session for the current raid.
* Allow the ML to select the loot system used for the raid.
* Track raid members and raid information.
* Detect and record boss loot.
* Run timed loot distributions.
* Allow players to Need or Pass on individual items.
* Record `/roll` results from players who do not have NinjaLoot.
* Give the Master Looter complete control over the final recipient.
* Maintain detailed loot and distribution history.
* Preserve session state when the UI is closed.
* Allow a new Master Looter to continue an existing session.

---

# Loot Systems

NinjaLoot will support multiple types of loot systems.

These are **loot-system choices for individual raid sessions**, not permanent addon settings.

Available systems:

| Loot System  | Status                     |
| ------------ | -------------------------- |
| EPGP         | Planned                    |
| DKP          | Planned                    |
| Round Robin  | **Initial implementation** |
| Loot Council | Planned                    |
| GDKP         | Planned                    |

When a new loot session is initialized, the Master Looter chooses the loot system for that session.

Once the session has started, the selected loot system is locked for that session.

---

# Session Lifecycle

The central concept in NinjaLoot is the **Loot Session**.

```text
NOT INITIALIZED
       │
       ▼
INITIALIZATION
       │
       ▼
SETUP / LOBBY
       │
       ▼
SESSION ACTIVE
```

The session exists independently from the addon windows.

Closing the UI does **not** end the session.

Reopening NinjaLoot restores the appropriate view of the current session.

---

# 1. Session Initialization

When the player is:

* Master Looter
* In a raid party
* Not already running an active NinjaLoot session

NinjaLoot displays an initialization prompt.

The Master Looter can choose the loot system:

```text
┌─────────────────────────────┐
│      Initialize NinjaLoot   │
│                             │
│  Select Loot System         │
│                             │
│  [ EPGP ]                   │
│  [ DKP ]                    │
│  [ Round Robin ]            │
│  [ Loot Council ]           │
│  [ GDKP ]                   │
└─────────────────────────────┘
```

Selecting a system moves the addon into the **Setup / Lobby** state.

---

# 2. Setup / Lobby

After selecting the loot system, the main NinjaLoot window changes to the raid setup view.

The window contains information such as:

### Raid Information

* Raid/instance name
* Difficulty
* Group size
* Session start information
* Current boss
* Other relevant raid information

### Raid Players

The addon displays the players currently detected in the raid.

The player list is used as the starting roster for the session.

If not all expected players are present, the ML can refresh the roster.

```text
[ Refresh Players ]
```

The session can be started even if some players are missing.

NinjaLoot may warn the ML before starting when the detected roster does not match the expected raid group.

---

# 3. Setup Controls

The setup window provides:

### Cancel

Returns to loot-system selection without starting the actual loot session.

### Refresh Players

Refreshes the currently detected raid members.

Useful when players join the raid after NinjaLoot was initialized.

### Start

Starts the actual loot session using:

* The selected loot system
* The current raid information
* The currently detected raid members

After pressing Start, the session becomes active.

---

# 4. Active Loot Session

Once started, the session becomes persistent.

The main window changes to the active-session view.

The session records:

* Loot system
* Master Looter
* Raid information
* Players
* Bosses
* Items
* Loot distributions
* Player responses
* Rolls
* Winners
* Distribution history
* Relevant timestamps
* System-specific information

The selected loot system cannot simply be changed while the session is active.

---

# 5. Master Looter Changes

The session does not belong exclusively to the original Master Looter.

If the Master Looter changes during an active session, the new ML should be able to continue the same NinjaLoot session.

The new ML should receive:

* Existing raid information
* Existing player information
* Selected loot system
* Previous boss information
* Previous loot distributions
* Player responses
* Rolls
* Winners
* Other session history

The goal is:

```text
Master Looter A
      │
      │ Active session
      ▼
Master Looter changes
      │
      ▼
Master Looter B
      │
      ▼
Continues the same session
```

The session therefore needs to be synchronized between participating NinjaLoot clients rather than existing only on one player's computer.

---

# 6. Boss Loot Window

When the Master Looter opens the actual in-game WoW loot window for a boss, NinjaLoot detects the loot window.

NinjaLoot then displays its own **smaller boss-loot control window** for the ML.

The addon window represents the loot currently available from that boss.

Example:

```text
┌───────────────────────────────────────┐
│ Ragnaros Loot                         │
│                                       │
│ [Item]  [Item]  [Item]  [Item]       │
│                                       │
│ Selected: Sulfuras                    │
│                                       │
│ [ Start Distribution ]                │
│                                       │
│ [ Restart Distribution ]              │
│ [ Post Loot ]                         │
│ [ Register Loot ]                     │
└───────────────────────────────────────┘
```

The ML still has the actual WoW loot window available as well.

---

# 7. Boss Loot Controls

## Start Distribution

The ML selects an item and starts its loot distribution.

Only one item is distributed at a time.

The distribution lasts:

**30 seconds**

During this period, participating players can respond.

---

## Restart Distribution

If an item is still available and has not been awarded, the ML can restart its distribution.

NinjaLoot should verify that the item still exists before allowing it to be distributed again.

The addon should check the actual game state, including the loot window and, where appropriate, the ML's inventory.

Restarting should not erase the previous attempt from history.

Example:

```text
Sulfuras

Distribution Attempt #1
    Bob      Need  94
    Steve    Need  87
    Result: Restarted

Distribution Attempt #2
    Bob      Need  91
    Steve    Pass
    Result: Awarded to Bob
```

---

# 8. Post Loot

The ML can post the items that dropped from the boss into chat.

NinjaLoot obtains the items from the actual loot window.

The loot list can only be posted **once for that boss**.

After the loot has been posted, NinjaLoot records that the boss loot was already announced.

Example:

```text
Ragnaros Loot:
• Sulfuras
• Eye of Ragnaros
• Bindings of the Windseeker
```

The exact chat formatting will be determined during implementation.

---

# 9. Register Loot

The ML can register the current boss loot for later distribution.

Registering loot records:

* Boss
* Loot items
* Relevant loot-window information
* Items transferred into or already present in the ML's bag where applicable

This allows the ML to postpone distribution and return to the registered loot later.

The registered loot belongs to the specific boss and session.

---

# 10. Player Loot Window

Every player who:

* Has NinjaLoot installed
* Is part of the active NinjaLoot session
* Is currently in the raid party

receives a small loot-distribution window when an item is being distributed.

The Master Looter receives this window too.

The ML is a normal participant in the loot distribution.

Example:

```text
┌─────────────────────────┐
│ NinjaLoot               │
│                         │
│ [ Item Icon ]           │
│ Sulfuras                │
│                         │
│ [ NEED ]   [ PASS ]     │
│                         │
│ Time remaining: 24s     │
└─────────────────────────┘
```

---

# 11. Need

When a player selects **Need**, NinjaLoot records their response.

The response becomes part of the current distribution.

Relevant information can include:

* Player
* Response
* Time
* Roll
* Response source

The player is not automatically declared the winner.

The Master Looter makes the final decision.

---

# 12. Pass

When a player selects **Pass**, their response is recorded.

The player's loot window is minimized.

The player can reopen the window while the 30-second distribution timer is still active.

They can then change their response between:

```text
Need
Pass
```

Once the timer expires, the distribution is closed and player responses can no longer be changed.

---

# 13. Distribution Timer

Every item distribution has a 30-second timer.

```text
ITEM SELECTED
      │
      ▼
DISTRIBUTION STARTED
      │
      │ 30 seconds
      ▼
DISTRIBUTION CLOSED
      │
      ▼
WAITING FOR ML DECISION
```

The timer belongs to the distribution itself, not to an individual UI window.

Closing or minimizing a player's window does not stop the timer.

---

# 14. Players Without NinjaLoot

NinjaLoot should still support players who do not have the addon.

If a player uses the normal WoW `/roll` command during an active distribution, NinjaLoot records the roll.

The roll is treated as a **Need response**.

Example:

```text
Player: Steve
Response: Need
Roll: 87
Source: Chat /roll
```

This allows players without NinjaLoot to participate in the same distribution.

The roll must be associated with the correct active distribution.

Late or unrelated `/roll` messages must not accidentally become part of a distribution.

---

# 15. Round Robin Distribution Rules

The initial implemented loot system is **Round Robin**.

The current rules are:

### Everyone can Need or Pass on everything

There is no automatic restriction based on:

* Class
* Spec
* Role
* Item type
* Previous rolls

The player chooses:

```text
Need
Pass
```

---

# 16. The ML Decides the Winner

NinjaLoot does **not automatically award the item to the highest roll**.

After the 30-second timer expires, the Master Looter receives the list of players who selected Need.

Example:

```text
┌──────────────────────────────────────┐
│ Sulfuras Distribution                │
│                                      │
│ Player        Roll       Source      │
│ ------------------------------------ │
│ Bob            94       NinjaLoot    │
│ Steve          87       /roll        │
│ Mike           71       NinjaLoot    │
│                                      │
│ Select player to receive item:       │
│                                      │
│ [ Bob ]                              │
│ [ Steve ]                            │
│ [ Mike ]                             │
└──────────────────────────────────────┘
```

The ML chooses the recipient.

The addon provides information to assist the decision, but **the addon does not decide who wins**.

---

# 17. Winner Confirmation

After the ML selects a player, NinjaLoot displays a confirmation prompt.

Example:

```text
┌──────────────────────────────────┐
│ Are you sure?                    │
│                                  │
│ Give Sulfuras to Steve?          │
│                                  │
│       [ YES ]     [ CANCEL ]     │
└──────────────────────────────────┘
```

### Cancel

Returns to the player selection.

### Yes

Confirms the ML's decision.

NinjaLoot then records the selected player as the recipient.

The actual item award is performed by the Master Looter through the game's loot system.

---

# 18. Distribution History

Every distribution should preserve its history.

A distribution records information such as:

```text
Distribution
├── Boss
├── Item
├── Start time
├── End time
├── Eligible players
├── Player responses
├── Rolls
├── Response sources
├── Winner
├── Winning roll
├── Result
└── Distribution attempts
```

Example:

```text
Ragnaros
└── Sulfuras
    │
    ├── Bob       Need   94
    ├── Steve     Need   87
    ├── Mike      Pass
    ├── Alex      Need   71
    │
    └── Winner
        └── Steve
```

The history should remain available after the distribution is finished.

---

# 19. ML Information vs Player Information

Not every piece of session information needs to be visible to every player.

### Master Looter

The ML can see the complete distribution information, including:

* Players who selected Need
* Rolls
* Roll sources
* Previous item wins
* Distribution history
* Current session state
* Loot controls
* Winner selection
* Boss loot information

### Normal Player

The player sees the information needed to participate in the current distribution.

At minimum:

* Current item
* Need
* Pass
* Remaining time
* Their current response

Information about other players' previous wins can remain hidden from normal players.

This is a **UI visibility rule**, not a limitation on what NinjaLoot records internally.

---

# 20. Session State Persistence

The NinjaLoot UI can be closed at any time without destroying the active session.

For example:

```text
Session Active
      │
      ▼
Player closes NinjaLoot window
      │
      ▼
Session continues
      │
      ▼
Player opens NinjaLoot again
      │
      ▼
Current session restored
```

The addon should restore the appropriate interface based on the current session state.

If a distribution is currently active, the state of that distribution must also remain consistent.

---

# 21. Raid and Player State

The session keeps track of the raid roster.

At session start, the current raid roster is recorded.

If players are missing when the session starts, the ML can refresh the roster before starting.

Players joining or leaving after the session begins will require additional rules governing their participation.

Those rules are intentionally not finalized yet.

---

# 22. Current Session Model

Conceptually, the session contains:

```text
LootSession
├── Session ID
├── Raid Info
├── Loot System
├── Master Looter
├── Start Time
├── Players
├── Bosses
├── Loot
└── Distributions
```

Raid information is kept separately:

```text
RaidInfo
├── Instance
├── Difficulty
├── Group Size
├── Start Time
└── Current Boss
```

---

# 23. Current Item State

An item can move through several states:

```text
AVAILABLE
    │
    ▼
IN DISTRIBUTION
    │
    ▼
WAITING FOR ML
    │
    ▼
AWARDED
```

A distribution may also be restarted:

```text
IN DISTRIBUTION
       │
       ▼
CANCELLED / RESTARTED
       │
       ▼
AVAILABLE
```

Registered loot can exist before distribution begins.

---

# 24. Communication and Synchronization

Because a session must survive a Master Looter change, NinjaLoot cannot rely exclusively on local state on the original ML's computer.

Relevant session information must eventually be synchronized between NinjaLoot users in the raid.

Conceptually:

```text
                 NinjaLoot Session
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
       Player A      Player B      Player C
          │             │             │
          └─────────────┼─────────────┘
                        │
                  Shared state
```

This allows a new Master Looter to continue an existing session with the information already collected.

The exact WoW communication API will be determined during implementation based on the API available in the target client.

---

# 25. Current Scope

### Implemented first

The initial implementation will focus on:

* NinjaLoot session lifecycle
* Raid/player tracking
* Session persistence
* Round Robin loot distribution
* Need / Pass
* 30-second distribution timer
* `/roll` detection
* ML winner selection
* Winner confirmation
* Loot history
* Boss loot detection
* ML loot controls
* Restarting distributions
* Posting boss loot
* Registering boss loot
* Session synchronization
* Master Looter handoff

### Planned later

The following loot systems will be added after the initial Round Robin implementation:

* EPGP
* DKP
* Loot Council
* GDKP

Each system will eventually have its own distribution rules while using the same underlying session infrastructure.

---

# 26. Design Principles

NinjaLoot follows several important principles.

### The session is the source of truth

The UI displays the session. The UI does not own it.

### The ML remains the final authority

NinjaLoot provides information and workflow assistance.

It does not automatically decide who deserves an item.

### Record events, don't overwrite history

Responses, rolls, restarts, and awards should remain traceable.

### UI visibility is separate from stored data

The addon may know information that should not be displayed to ordinary players.

### Game state remains authoritative

NinjaLoot should verify important actions against the actual WoW game state where possible.

### Loot systems are pluggable

The session infrastructure should not be tightly coupled to Round Robin.

Future systems should be able to use the same session, player, loot, and history infrastructure.

---

# 27. Future Round Robin Rules

The current Round Robin rules are intentionally not completely finalized.

Additional rules still to be established include:

* Players joining after session start
* Players leaving during a session
* Players reconnecting
* Players changing raid groups
* Late `/roll` messages
* Multiple `/roll` messages
* Roll timing
* Tie handling
* Rerolls
* What happens when nobody selects Need
* ML cancellation
* Distribution cancellation
* Item disappearing from the loot window
* What happens if the selected recipient cannot receive the item
* Whether a winner must confirm receipt
* Additional Round Robin priority rules
* How previous item wins affect later distributions

These should be defined before the corresponding implementation is built.

---

# 28. High-Level User Flow

The complete intended flow is:

```text
                MASTER LOOTER
                     │
                     ▼
             Initialize NinjaLoot
                     │
                     ▼
             Select Loot System
                     │
                     ▼
                Setup / Lobby
                     │
        ┌────────────┼────────────┐
        │            │            │
      Cancel      Refresh       Start
        │          Players        │
        │                         ▼
        └───────────────►  ACTIVE SESSION
                                  │
                                  ▼
                         ML opens WoW loot
                                  │
                                  ▼
                       NinjaLoot detects boss
                                  │
                                  ▼
                          Boss Loot Window
                                  │
                 ┌────────────────┼───────────────┐
                 │                │               │
             Post Loot      Register Loot     Select Item
                                                   │
                                                   ▼
                                          Start Distribution
                                                   │
                                                   ▼
                                               30 seconds
                                                   │
                                  ┌────────────────┴──────────────┐
                                  │                               │
                             Addon player                    /roll player
                                  │                               │
                              Need / Pass                    Need + Roll
                                  │                               │
                                  └──────────────┬────────────────┘
                                                 ▼
                                           Timer expires
                                                 │
                                                 ▼
                                          ML sees results
                                                 │
                                                 ▼
                                       ML selects recipient
                                                 │
                                                 ▼
                                           Confirmation
                                                 │
                                          ┌──────┴──────┐
                                          │             │
                                        Cancel         Yes
                                          │             │
                                          ▼             ▼
                                     Selection      Item awarded
                                                       │
                                                       ▼
                                                Result recorded
                                                       │
                                                       ▼
                                                 Session History
```

---

# 29. The Big Picture

NinjaLoot is not intended to replace the Master Looter.

It is intended to give the Master Looter a structured system for:

**seeing the raid → recording the loot → collecting responses → tracking rolls → making the decision → recording the result.**

The actual authority remains with the Master Looter and the WoW loot system.

The addon provides the organization, timing, communication, and history around that process.
