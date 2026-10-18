-- qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
-- "qt5ct" is also answered by Fedora's qt6ct plugin, so Qt5 and Qt6 apps both get the qt6ct palette
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")

-- cursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "breeze_cursors")
