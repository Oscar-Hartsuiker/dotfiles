config.load_autoconfig(True)
import colors

config.bind("J", "tab-prev")
config.bind("K", "tab-next")
colors.setup(c)
# ============================================================
# KEY BINDINGS
# ============================================================
config.bind("<Ctrl+/>", "hint links spawn --detach mpv {hint-url}")
# Open the current page's URL in mpv
# ============================================================
# SETTINGS (your existing non-color config)
# ============================================================
c.changelog_after_upgrade = "never"
c.qt.highdpi = False
c.zoom.default = 150
c.auto_save.session = True
c.content.cookies.accept = "no-3rdparty"
config.set("content.cookies.accept", "all", "chrome-devtools://*")
config.set("content.cookies.accept", "all", "devtools://*")
config.set("content.headers.accept_language", "", "https://matchmaker.krunker.io/*")
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 ({os_info}; rv:149.0) Gecko/20100101 Firefox/149.0",
    "https://accounts.google.com/*",
)
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {qt_key}/{qt_version} {upstream_browser_key}/{upstream_browser_version_short} Safari/{webkit_version}",
    "https://gitlab.gnome.org/*",
)
config.set("content.images", True, "chrome-devtools://*")
config.set("content.images", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome-devtools://*")
config.set("content.javascript.enabled", True, "devtools://*")
config.set("content.javascript.enabled", True, "chrome://*/*")
config.set("content.javascript.enabled", True, "qute://*/*")
config.set(
    "content.local_content_can_access_remote_urls",
    True,
    "file:///home/oscar/.local/share/qutebrowser/userscripts/*",
)
config.set(
    "content.local_content_can_access_file_urls",
    False,
    "file:///home/oscar/.local/share/qutebrowser/userscripts/*",
)
c.editor.command = ["foot", "nvim", "-f", "{file}", "-c", "normal {line}G{column0}l"]
c.fileselect.folder.command = ["foot", "-e", "ranger", "--choosedir={}"]
c.scrolling.smooth = True
c.qt.args += [
    "enable-smooth-scrolling",
    "num-raster-threads=4",
    "enable-accelerated-video-decode",
    "enable-gpu-rasterization",
    "ignore-gpu-blocklist",
]
c.tabs.last_close = "default-page"
c.tabs.padding = {"bottom": 2, "left": 0, "right": 0, "top": 2}
c.tabs.position = "top"
c.tabs.show = "multiple"
c.tabs.title.alignment = "left"
c.url.default_page = "about:blank"
c.url.searchengines = {"DEFAULT": "https://google.com/search?q={}"}
c.url.start_pages = "about:blank"
c.fonts.default_family = ["Roboto"]
c.fonts.default_size = "18pt"
c.fonts.web.size.default = 18
c.fonts.web.size.default_fixed = 18
c.fonts.web.size.minimum_logical = 16

# ============================================================
# INSERT MODE
# ============================================================
c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = False
