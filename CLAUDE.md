# May there bee flowers — Claude Guide

## Project Overview

- **Engine:** Godot 4.6
- **Platform:** Mobile-first
- **Genre:** Tactical / deck-building game with a plants & flowers theme
- **Base Resolution:** 320×180 (scaled up to 2560×1440), pixel-art style

## Project Structure

```
/
├── autoloads/          # Global singletons (autoloaded by Godot)
│   └── database/       # Specialized game databases (plants, combat, weather, etc.)
├── scenes/
│   ├── GUI/            # User interface components
│   ├── effects/        # Visual effects
│   ├── main/           # Main game entry point
│   ├── main_game/      # Core gameplay scenes
│   ├── state_machine/  # State management
│   └── utils/          # Shared utility components
├── scripts/            # Standalone GDScript files
├── resources/          # Game resources (sprites, audio, localization)
├── data/               # Game data files
├── tests/
│   ├── gut_tests/      # Automated GUT tests (data/, gameplay/, utils/)
│   ├── fixtures/       # Test fixtures and shared test data
│   ├── deprecated/     # Old tests kept for reference
│   └── template.gd     # Template for new tests
├── addons/             # Godot plugins (GUT, AsepriteWizard, PaletteTools, etc.)
└── .github/workflows/  # CI/CD pipelines
```

## Running Tests

Tests use the [GUT](https://github.com/bitwes/Gut) (Godot Unit Test) framework.

**Headless (CI / command line):**
```bash
godot --headless -s addons/gut/gut_cmdln.gd
```

Test files live in `tests/gut_tests/` and must match the pattern `test_*.gd`.
The `.gutconfig.json` at the repo root holds the full GUT configuration.

**In-editor:** Open the GUT panel in Godot and click "Run All".

## Key Systems

| Autoload | File | Purpose |
|---|---|---|
| `Constants` | `autoloads/constants.gd` | Shared game constants |
| `Events` | `autoloads/events.gd` | Central event bus (signal hub) |
| `MainDatabase` | `autoloads/database/main_database.gd` | Aggregates all sub-databases |
| `Save` | `autoloads/save.gd` | Save / load game state |
| `PlayerSettings` | `autoloads/player_settings.gd` | Player configuration |
| `Stats` | `autoloads/stats.gd` | Game statistics tracking |
| `TrashBin` | `autoloads/trash_bin.gd` | Deferred node cleanup |
| `GlobalSoundManager` | `autoloads/global_sound_manager.gd` | Audio management |
| `PauseManager` | `autoloads/pause_manager.gd` | Pause state control |
| `Cursors` | `autoloads/cursors.gd` | Cursor management |

### Databases (`autoloads/database/`)
Specialized databases exist for: plants, combat, bosses, events, event options, field status, plant abilities, player status, player trinkets, tools, and weather.

### Render Layers (2D)
1. World, 2. Player, 3. Mob, 4. Loot, 5. Camera

### Physics Layers (2D)
1. field, 2. water_body, 3. water_droplet

## CI/CD

| Workflow | Trigger | Purpose |
|---|---|---|
| `gut_tests.yml` | PRs + pushes to `main` | Runs GUT tests, publishes results |
| `claude.yml` | Issue/PR comments | Claude Code auto-fix integration |
| `branch_protection.yml` | Changes to `gut_tests.yml` | Enforces GUT tests must pass before merge |

## Development Notes

- **Art:** Pixel art created with Aseprite; the AsepriteWizard addon handles imports.
- **Localization:** English translation at `resources/localization/localization.en.translation`.
- **Physics:** Gravity is effectively zero (this is not a physics-simulation game).
- **New tests:** Copy `tests/template.gd` as a starting point; name files `test_*.gd`.
