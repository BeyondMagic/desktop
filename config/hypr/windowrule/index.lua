---@diagnostic disable: undefined-global

-- --------------------------------------------------------------------------
-- Window rules
-- --------------------------------------------------------------------------
local function no_blur_rule(name, klass)
	hl.window_rule({
		name = "perf-no-blur-" .. name,
		match = { class = klass },
		no_blur = true,
	})
end

no_blur_rule("foot", "^(foot)(.*)$")
no_blur_rule("firefox", "^(firefox)(.*)$")
no_blur_rule("rnote", "^(rnote)(.*)$")
no_blur_rule("telegram", "^(telegram)(.*)$")
no_blur_rule("gimp", "^(gimp)(.*)$")
no_blur_rule("pavucontrol", "^(pavucontrol)(.*)$")
no_blur_rule("thunar", "^(thunar)(.*)$")
no_blur_rule("torrent", "^(torrent)(.*)$")
no_blur_rule("songrec", "^(SongRec)(.*)$")
no_blur_rule("thunderbird", "^(Thunderbird)(.*)$")
no_blur_rule("lxappearance", "^(Lxappearance)(.*)$")
no_blur_rule("qalculate", "^(Qalculate)(.*)$")

hl.window_rule({
	name = "perf-no-blur-mpv",
	match = { class = "^(mpv)(.*)$" },
	no_blur = true,
	content = "video",
	sync_fullscreen = true,
})

hl.window_rule({
	name = "anki-no-fullscreen",
	match = { class = ".*anki.*" },
	suppress_event = "maximize fullscreen",
})

hl.window_rule({
	name = "thunderbird-reminders",
	match = { class = "org.mozilla.Thunderbird", title = ".*Reminder.*" },
	float = true,
	size = "681 314",
	center = true,
})

hl.window_rule({
	name = "firefox-close-popup",
	match = { class = "^(firefox)(.*)$", title = "^(Close Firefox)$" },
	float = true,
	size = "(monitor_w/4) (monitor_h/8)",
	center = true,
})

hl.window_rule({
	name = "inkscape-import-dialog",
	match = { title = "^(png bitmap image import)" },
	float = true,
	center = true,
	size = "386 324",
})

hl.window_rule({
	name = "generic-dialogs",
	match = {
		title =
		"^(Media viewer|Export Image|Exportar imagem|Salvar imagem|Editando Conexao|Abrir arquivo|Import File|Select a File|Choose wallpaper|Open Folder|Save Document As|Save Image|Save As|Library|File Upload|Enter name of file|Enter name of file to save to|Save File|Open File)(.*)$",
	},
	float = true,
	size = "850 525",
	center = true,
})

hl.window_rule({
	name = "preferences-dialog",
	match = { title = "^(Preferences)(.*)$" },
	float = true,
	size = "900 700",
	center = true,
})

hl.window_rule({
	name = "olive-dialog",
	match = { title = "^(org\\.olivevideoeditor\\.Olive)(.*)$" },
	float = true,
})

hl.window_rule({
	name = "blob-dialog",
	match = { title = "^(blob:)(.*)$" },
	float = true,
})

hl.window_rule({
	name = "portal-dialog",
	match = { class = "xdg-desktop-portal-gtk" },
	float = true,
})

hl.window_rule({
	name = "file-save-extra",
	match = { title = "^(Save As|Abrir arquivo)(.*)$" },
	float = true,
	center = true,
})

hl.window_rule({
	name = "foot-floating-overlay",
	match = { title = "foot floating" },
	float = true,
	size = "550 425",
	center = true,
})

hl.window_rule({
	name = "xwayland-video-bridge",
	match = { class = "^(xwaylandvideobridge)$" },
	opacity = "0.0 override 0.0 override",
	no_anim = true,
	no_initial_focus = true,
	max_size = "1 1",
	no_blur = true,
})

hl.window_rule({
	name = "telegram-stay-focused",
	match = { class = "^(telegram)(.*)$" },
	stay_focused = true,
})
