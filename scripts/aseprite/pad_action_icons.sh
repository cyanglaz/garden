#!/usr/bin/env bash
set -euo pipefail

ASEPRITE="${ASEPRITE:-/Applications/Aseprite.app/Contents/MacOS/aseprite}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ICON_DIR="$REPO_ROOT/resources/sprites/GUI/icons/resources"
LUA="$SCRIPT_DIR/pad_canvas_1px.lua"

IDS=(
    water light pest fungus recycle draw_card discard_card stun compost
    greenhouse dew energy update_x gain_gold update_hp free_move
    add_card_discard_pile drowned buried move_left move_right loop
)

for id in "${IDS[@]}"; do
    f="$ICON_DIR/icon_${id}.aseprite"
    if [[ ! -f "$f" ]]; then
        echo "SKIP (missing): $f"
        continue
    fi
    echo "PAD: $f"
    "$ASEPRITE" -b "$f" --script "$LUA"
done

echo "Done. Open Godot to let AsepriteWizard re-export PNGs."
