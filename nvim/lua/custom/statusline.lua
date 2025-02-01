local Job = require "plenary.job"
local async = require "plenary.async"
local uv = require "luv"
-- https://github.com/wakatime/vim-wakatime/issues/110#issuecomment-1475005367
local get_wakatime_time = function()
  local tx, rx = async.control.channel.oneshot()
  local ok, job = pcall(Job.new, Job, {
    command = os.getenv "HOME" .. "/.wakatime/wakatime-cli",
    args = { "--today" },
    on_exit = function(j, _)
      tx(j:result()[1] or "")
    end,
  })
  if not ok then
    vim.notify("Bad WakaTime call: " .. job, vim.log.levels.WARN)
    return ""
  end

  job:start()
  return rx()
end

local check_time = function(time)
  local hours, minutes, seconds = string.match(time, "(%d+)%s*hr%s*(%d*)%s*min%s*(%d*)%s*sec")
  if not hours then
    hours, minutes = string.match(time, "(%d+)%s*hr%s*(%d*)%s*min")
    if not hours then
      hours = string.match(time, "(%d+)%s*hr")
    end
  end

  local totalHours = tonumber(hours) or 0
  local totalMinutes = tonumber(minutes) or 0
  local totalSeconds = tonumber(seconds) or 0

  local totalTime = (totalHours * 3600) + (totalMinutes * 60) + totalSeconds

  local level = math.min(math.max(math.ceil(totalTime / ((3600 * 8) / 12)), 1), 12)
  return tostring(level)
end
---@diagnostic disable
local state = { comp_wakatime_time = "" }

-- Yield statusline value
local wakatime = function()
  local WAKATIME_UPDATE_INTERVAL = 10000

  if not Wakatime_routine_init then
    local timer = uv.new_timer()
    if timer == nil then
      return ""
    end
    -- Update wakatime every 10s
    uv.timer_start(timer, 500, WAKATIME_UPDATE_INTERVAL, function()
      async.run(get_wakatime_time, function(time)
        state.comp_wakatime_time = time
      end)
    end)
    Wakatime_routine_init = true
  end

  return state.comp_wakatime_time
end

local wk_status = require("lualine.component"):extend()
local highlight = require "lualine.highlight"

function wk_status:init(options)
  wk_status.super.init(self, options)

  self.colors = {}
  -- local start_color = '#ff272a'
  -- local end_color = '#58CD36'
  local color_diff = {
    "#ff272a",
    "#ff6013",
    "#ff8900",
    "#ffae00",
    "#ffd000",
    "#f4dc00",
    "#e6e800",
    "#d6f30a",
    "#b8ea17",
    "#99e123",
    "#7ad72d",
    "#58cd36",
  }
  for i = 1, 12 do
    self.colors[tostring(i)] =
      highlight.create_component_highlight_group({ fg = color_diff[i] }, tostring(i), self.options)
  end
end

function wk_status:update_status()
  local time = wakatime()
  if time ~= "" then
    local trunc_time = ""
    if vim.fn.winwidth(0) < 80 then
      trunc_time = " 󱑆 "
    else
      trunc_time = string.format(" %s %s", " 󱑆 ", time)
    end
    return string.format("%s%s", highlight.component_format_highlight(self.colors[check_time(time)]), trunc_time)
  else
    return ""
  end
end

local exclude_statusline = function()
  local fts = { "startify", "Outline" }
  for _, ft in pairs(fts) do
    if vim.bo.filetype == ft then
      return false
    end
  end
  return true
end

return wk_status
