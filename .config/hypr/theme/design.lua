hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 6,
        border_size = 1,
        col = {
            active_border = "rgba(878580ee)",
            inactive_border = "rgba(282726aa)",
        },
        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,
        -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before turning this on
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        rounding_power = 2,
        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee100f0f,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- animation settings
hl.curve("bouncy", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("less_bouncy", { type = "bezier", points = { {0.15, 0.85}, {0.25, 1.05} } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "bouncy" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "bouncy", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "bouncy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "less_bouncy", style = "fade" })
hl.animation({ leaf = "border", enabled = true,  speed = 6, bezier = "bouncy" })
hl.animation({ leaf = "borderangle", enabled = true,  speed = 6, bezier = "bouncy" })

-- misc
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    }
})

hl.config({
    cursor = {
        no_hardware_cursors = 0,
    },
})
