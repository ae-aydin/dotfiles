-- main monitor
hl.workspace_rule({ workspace = "1", monitor = "DP-6", persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-6", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-6", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-6", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-6", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "DP-6", persistent = true })

-- secondary monitor
hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-2", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-2", persistent = true, default = true })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-2", persistent = true })
