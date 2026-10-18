-- left portrait 1080p monitor
hl.monitor({
  output = "HDMI-A-2",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
  transform = 1,
})

-- right landscape 1440p monitor
hl.monitor({
  output = "DP-6",
  mode = "2560x1440@180",
  position = "1080x240",
  scale = 1,
})
