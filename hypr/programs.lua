local mainMod = "SUPER" -- Sets "Windows" key as main modifier

local programs = {
	terminal = "alacritty",
	terminal2 = "ghostty",
	--fileManager = "nautilus --new-window",
	fileManager = "dolphin",
	menu = "rofi -show combi -combi-modi window,drun,run,fileManage",
	browser2 = "firefox",
	browser = "helium",
	whatsapp = "zapzap",
	yazi = "yazi",
}

hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + o", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + SHIFT + return", hl.dsp.exec_cmd(programs.terminal2))

hl.unbind("SUPER + W")
hl.bind(mainMod .. " + w", hl.dsp.exec_cmd(programs.whatsapp))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(programs.browser2))
