-- DMS Window Rules — managed by DankMaterialShell
-- Do not edit manually; changes may be overwritten

-- DMS-RULE: id=dms-floating-windows, name=DMS Floating Windows
hl.window_rule({ match = { class = "^com.danklinux.dms$" }, float = true })

-- DMS-RULE: id=wr_1791326569703710680, name=Ardour-8.12.0~ds
hl.window_rule({ match = { class = "^Ardour-8.12.0~ds$", title = "^Audio Connection Manager$" }, move = { 100, 200 } })

-- DMS-RULE: id=wr_1791326630844791061, name=Ardour-8.12.0~ds
hl.window_rule({ match = { class = "^Ardour-8.12.0~ds$", title = "^* input$" }, move = { 100, 200 } })

-- DMS-RULE: id=wr_1791746799455448377, name=xdg-desktop-portal-gtk
hl.window_rule({ match = { class = "^xdg-desktop-portal-gtk*" }, size = { 800, 600 } })
