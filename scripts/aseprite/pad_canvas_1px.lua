-- Pads the active sprite's canvas by 1px on each side, keeping existing cels in place
-- so original art ends up centered. Saves in place (same path & format).
local spr = app.activeSprite
if spr == nil then
    return print("No active sprite")
end

app.command.CanvasSize{
    ui = false,
    left = 1, right = 1, top = 1, bottom = 1,
    trimOutside = false,
}

spr:saveAs(spr.filename)
