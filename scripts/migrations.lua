local mod_gui = require("__core__.lualib.mod-gui")

local mouseover = require("scripts.mouseover")

local version_migrations = {
  ["2.0.1"] = function()
    for _, player in pairs(game.players) do
      local window = mod_gui.get_frame_flow(player).pv_window
      if window then
        window.destroy()
      end
    end
  end,
  ["2.2.0"] = function()
    mouseover.on_init()
  end,
}

-- flib's `migration` module was dropped from flib 2.1, so reimplement the small
-- subset this mod used: run every version-keyed migration newer than the
-- previously installed version of this mod, in ascending version order.
local function format_version(version)
  if not version then
    return nil
  end
  local parts = {}
  for part in string.gmatch(version, "%d+") do
    parts[#parts + 1] = string.format("%05d", tonumber(part))
  end
  return table.concat(parts, ".")
end

local migrations = {}

migrations.on_configuration_changed = function(e)
  local changes = e.mod_changes and e.mod_changes[script.mod_name]
  if not changes or not changes.old_version then
    return
  end
  local old_version = format_version(changes.old_version)

  local versions = {}
  for version in pairs(version_migrations) do
    versions[#versions + 1] = version
  end
  table.sort(versions, function(a, b)
    return format_version(a) < format_version(b)
  end)

  for _, version in ipairs(versions) do
    if old_version < format_version(version) then
      version_migrations[version]()
    end
  end
end

return migrations
