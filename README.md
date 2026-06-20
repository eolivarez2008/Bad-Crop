<div align="center">

# Bad Crop

An arena-survival 2D top-down game built with Godot Engine 4, featuring wave-based combat, automated targeting systems, and persistent player statistics tracking.

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Godot](https://img.shields.io/badge/Godot_Engine-4.6.2-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Language](https://img.shields.io/badge/Language-GDScript-478CBF?logo=godotengine&logoColor=white)](https://docs.godotengine.org/)

</div>

---

## Project Status: In Progress

This is my first game developed with the Godot Engine. The core gameplay loop is currently being built and refined. This project explores game development fundamentals through practical implementation.

---

## Table of Contents

- [Overview](#overview)
- [Core Gameplay Mechanics](#core-gameplay-mechanics)
- [Technical Implementation](#technical-implementation)
- [Art & Assets Style](#art--assets-style)
- [Getting Started](#getting-started)
- [Credits](#credits)
- [License](#license)

---

## Overview

**Bad Crop** is an action arena-survival game where you play as a peasant trapped in a forest clearing. The goal is simple: survive increasingly difficult waves of chibi-style monsters (skeletons, zombies, golems, minotaurs, and orcs). Between each wave, players access an in-game shop to purchase stat upgrades, weapons, and skills to scale up their power.

---

## Core Gameplay Mechanics

- **Weapon Selection** — Choose two independent weapons from a starting roster before launching a match.
- **Auto-Targeting Combat** — Weapons are attached to the player node but operate autonomously, automatically targeting and firing at the nearest enemy.
- **The Shop Loop** — Spend resources earned from waves to upgrade weapons, increase base character stats, and unlock new survival skills.
- **Progressive Difficulty** — Face endless waves of increasingly tough enemies.

---

## Technical Implementation

The game logic is built entirely using native Godot nodes and procedural GDScript automation:

- **Spawning System** - Automated enemy wave distribution handled through a central manager script using standard Godot `Timer` nodes.
- **Targeting Logic** - Asynchronous vector calculations within the weapon scripts to dynamically fetch and track the closest enemy coordinates in real-time.
- **State & Animation** - Grid-based movement animations (Idle, Walk, Run) driven by event scripts synced with physics processing.
- **Persistence & Progression** - A local save routine tracks player statistics.

---

## Art & Assets Style

The visual identity is based on a consistent, cartoon-style aesthetic:

- **Environment** - An isolated clearing surrounded by forests
- **Entities** - Discreet chibi-style designs for the main character and monsters.

---

## Getting Started

### Prerequisites

- For players: None (standalone executable).
- For developers: [Godot Engine 4.6.2 (Standard Version)](https://godotengine.org/download).

### Option A: Play the Game (For Players)

If you just want to play the latest build:

1. Go to the **[Releases](https://github.com/eolivarez2008/Bad-Crop/releases)** section on the right side of this GitHub repository.
2. Download the latest installer executable (`.exe`).
3. Run the installer to install and launch the game on your computer.

### Option B: Local Development (For Developers)

If you want to view, test, or modify the source code:

1. Clone the repository:

```bash
git clone [https://github.com/eolivarez2008/Bad-Crop.git](https://github.com/eolivarez2008/Bad-Crop.git)
cd Bad-Crop
```

2. Launch the **Godot Project Manager**.
3. Select **Import**, navigate to your local cloned directory, and open the `project.godot` file.
4. Press `F5` inside the editor to test and execute the current project build locally.

---

## Credits

All external assets, inspirations, and tutorials used throughout this learning journey are documented in the [CREDITS.md](CREDITS.md) file.

---

## License

Distributed under the **Apache 2.0 License** — see [LICENSE](LICENSE) for details.
