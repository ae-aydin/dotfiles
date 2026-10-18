-- nmtui draws a fixed-size dialog, so give it a small floating window instead of a tile
hl.window_rule({
    name  = "float-nmtui",
    match = { class = "^qs\\.nmtui$" },

    float  = true,
    size   = "760 520",
    center = true,
})
