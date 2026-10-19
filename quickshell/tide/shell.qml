import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: win
    title: "Tide"
    implicitWidth: 860
    implicitHeight: 460
    color: c("background", "#0e1220")

    property var d: null

    // dms (matugen) colours, live-updated from ~/.cache/DankMaterialShell/dms-colors.json
    property var dms: null
    function c(name, fallback) {
        var m = dms && dms.colors
        var set = m ? (m[dms.mode] || m.dark) : null
        return set && set[name] ? set[name] : fallback
    }
    function withAlpha(hex, a) {
        var h = String(hex).replace("#", "")
        if (h.length === 6) h += "ff"
        var n = parseInt(h, 16)
        return "rgba(" + ((n >> 24) & 255) + "," + ((n >> 16) & 255) + "," + ((n >> 8) & 255) + "," + a + ")"
    }

    IpcHandler {
        target: "toggle"
        function toggle(): void { win.visible = !win.visible }
    }
    IpcHandler {
        target: "show"
        function show(): void { win.visible = true }
    }
    IpcHandler {
        target: "hide"
        function hide(): void { win.visible = false }
    }

    IpcHandler {
        target: "dump"
        function dump(): void {
            console.log("TIDEDUMP mode=" + (dms ? dms.mode : "none")
                        + " bg=" + win.c("background", "?")
                        + " primary=" + win.c("primary", "?")
                        + " onSurface=" + win.c("on_surface", "?"))
        }
    }

    property string dmsRaw: ""

    FileView {
        id: dmsColors
        path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/DankMaterialShell/dms-colors.json"
        watchChanges: false
        blockLoading: false
        onFileChanged: { win.loadDms() }
        onLoadFailed: console.log("tide: dms-colors.json missing, using fallback colours")
    }

    // dms rewrites this file whenever matugen regenerates the wallpaper palette;
    // poll it so tide follows theme/light-dark changes live.
    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { dmsColors.reload(); dmsApply.start() }
    }

    Timer {
        id: dmsApply
        interval: 80
        onTriggered: win.loadDms()
    }

    function loadDms() {
        var t = dmsColors.text()
        if (!t || t === dmsRaw) return
        try {
            dmsRaw = t
            dms = JSON.parse(t)
            if (cv) cv.requestPaint()
        } catch (e) { console.log("tide: bad dms colours:", e) }
    }
    property bool rtl: false        // true = time runs right -> left
    property int dayOffset: 0       // 0 = today, -1 = yesterday, +1 = tomorrow...
    property double lastShift: 0

    Process {
        id: proc
        command: ["python3", Quickshell.shellDir + "/tide.py", String(win.dayOffset)]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { win.d = JSON.parse(text) } catch (e) { console.log("tide.py output:", text) }
            }
        }
    }

    // refresh every minute (tide.py caches the API data, so this is cheap)
    Timer { interval: 60000; running: true; repeat: true; onTriggered: proc.running = true }
    // short delay so a restarted process picks up the new dayOffset
    Timer { id: restart; interval: 30; onTriggered: proc.running = true }

    function shift(n) {
        var o = Math.max(0, Math.min(9, dayOffset + n))
        if (o === dayOffset) return
        dayOffset = o
        proc.running = false
        restart.start()
    }

    function today() {
        if (dayOffset === 0) return
        dayOffset = 0
        proc.running = false
        restart.start()
    }

    function next(type) {
        if (!d) return null
        var from = (d.now >= 0 && d.now <= 24) ? d.now : 0
        for (var i = 0; i < d.extrema.length; i++)
            if (d.extrema[i].type === type && d.extrema[i].h > from) return d.extrema[i]
        return null
    }

    function fmt(e) { return e ? e.time + "  " + e.v.toFixed(2) + " m" : "--" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        focus: true

        Keys.onLeftPressed: win.shift(-1)
        Keys.onRightPressed: win.shift(1)
        Keys.onPressed: (e) => { if (e.key === Qt.Key_Home) win.today() }

        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: win.d ? [
                    { k: "STATION", v: win.d.station },
                    { k: "DATE",    v: win.d.label + (win.dayOffset === 0 ? "  · today" : "") },
                    { k: "NOW",     v: win.d.current.toFixed(2) + " m " + (win.d.rising ? "▲" : "▼") },
                    { k: win.dayOffset === 0 ? "NEXT HIGH" : "HIGH", v: win.fmt(win.next("high")) },
                    { k: win.dayOffset === 0 ? "NEXT LOW"  : "LOW",  v: win.fmt(win.next("low")) }
                ] : []
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    Text { text: modelData.k; color: win.c("on_surface_variant", "#7f8bb3"); font.pixelSize: 11; font.letterSpacing: 1.5 }
                    Text { text: modelData.v; color: win.c("on_surface", "#e6ebff"); font.pixelSize: 20; font.bold: true }
                }
            }
        }

        Canvas {
            id: cv
            Layout.fillWidth: true
            Layout.fillHeight: true
            Connections { target: win; function onDChanged() { cv.requestPaint() } }
            Connections { target: win; function onDmsChanged() { cv.requestPaint() } }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            WheelHandler {
                onWheel: (e) => {
                    if (Date.now() - win.lastShift < 120) return   // trackpad throttle
                    win.lastShift = Date.now()
                    win.shift(e.angleDelta.y < 0 ? 1 : -1)         // wheel down = next day
                }
            }
            TapHandler { onDoubleTapped: win.today() }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var D = win.d
                if (!D) return

                var L = 44, R = 12, T = 26, B = 8
                var pw = width - L - R, ph = height - T - B
                var vs = D.points.map(function (p) { return p[1] })
                var lo = Math.min.apply(null, vs) - 0.15
                var hi = Math.max.apply(null, vs) + 0.15
                function X(h) { var f = h / 24; if (win.rtl) f = 1 - f; return L + f * pw }
                function Y(v) { return T + (1 - (v - lo) / (hi - lo)) * ph }

                var colAccent = win.c("primary", "#19b5e6")
                var colOnSurface = win.c("on_surface", "#c8c6ce")
                var colOnSurfaceVar = win.c("on_surface_variant", "#9f9fa9")
                var colSurface = win.c("surface_container", "#121318")
                var tideHeat = ctx.createLinearGradient(0, Y(hi), 0, Y(lo))
                tideHeat.addColorStop(0, "#ef4444")
                tideHeat.addColorStop(0.5, "#facc15")
                tideHeat.addColorStop(1, "#22c55e")

                // day (light) + night (dark)
                ctx.fillStyle = win.c("primary_container", win.withAlpha(colAccent, 0.18))
                ctx.fillRect(L, T, pw, ph)
                ctx.fillStyle = win.withAlpha(colSurface, 0.55)
                D.nights.forEach(function (n) {
                    var a = Math.max(0, Math.min(24, n[0])), b = Math.max(0, Math.min(24, n[1]))
                    if (b <= a) return
                    var x1 = X(a), x2 = X(b)
                    ctx.fillRect(Math.min(x1, x2), T, Math.abs(x2 - x1), ph)
                })

                // hour grid + 24h labels along the top (window runs 06:00 -> 06:00)
                ctx.font = "12px monospace"
                ctx.textAlign = "center"
                ctx.lineWidth = 1
                for (var h = 0; h <= 24; h += 2) {
                    var gx = X(h), hh = h % 24
                    ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.35)
                    ctx.beginPath(); ctx.moveTo(gx, T); ctx.lineTo(gx, T + ph); ctx.stroke()
                    ctx.fillStyle = colOnSurfaceVar
                    ctx.fillText((hh < 10 ? "0" : "") + hh + ":00", gx, T - 8)
                }

                // height gridlines
                ctx.textAlign = "right"
                for (var m = Math.ceil(lo); m <= hi; m++) {
                    ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.25)
                    ctx.beginPath(); ctx.moveTo(L, Y(m)); ctx.lineTo(L + pw, Y(m)); ctx.stroke()
                    ctx.fillStyle = colOnSurfaceVar
                    ctx.fillText(m + " m", L - 6, Y(m) + 4)
                }

                // smooth curve: Catmull-Rom -> cubic bezier
                var pts = D.points.map(function (p) { return { x: X(p[0]), y: Y(p[1]) } })
                function trace() {
                    ctx.moveTo(pts[0].x, pts[0].y)
                    for (var i = 0; i < pts.length - 1; i++) {
                        var p0 = pts[Math.max(i - 1, 0)], p1 = pts[i], p2 = pts[i + 1]
                        var p3 = pts[Math.min(i + 2, pts.length - 1)]
                        ctx.bezierCurveTo(p1.x + (p2.x - p0.x) / 6, p1.y + (p2.y - p0.y) / 6,
                                          p2.x - (p3.x - p1.x) / 6, p2.y - (p3.y - p1.y) / 6,
                                          p2.x, p2.y)
                    }
                }
                ctx.save()
                ctx.beginPath(); ctx.rect(L, T, pw, ph); ctx.clip()
                ctx.beginPath(); trace()
                ctx.lineTo(pts[pts.length - 1].x, T + ph); ctx.lineTo(pts[0].x, T + ph); ctx.closePath()
                ctx.globalAlpha = 0.10; ctx.fillStyle = tideHeat; ctx.fill(); ctx.globalAlpha = 1
                ctx.beginPath(); trace()
                ctx.lineJoin = "round"; ctx.lineCap = "round"
                ctx.strokeStyle = tideHeat; ctx.lineWidth = 3; ctx.stroke()
                ctx.restore()

                // now marker (only when today's window is in view)
                if (D.now >= 0 && D.now <= 24) {
                    var nx = X(D.now), ny = Y(D.current)
                    ctx.strokeStyle = win.withAlpha("#ff2d95", 0.7); ctx.lineWidth = 2
                    ctx.beginPath(); ctx.moveTo(nx, T); ctx.lineTo(nx, T + ph); ctx.stroke()
                    ctx.fillStyle = "#ff2d95"; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 3
                    ctx.beginPath(); ctx.arc(nx, ny, 6, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                }

                // high / low labels
                D.extrema.forEach(function (e) {
                    if (e.h < 0 || e.h > 24) return
                    var ex = X(e.h), ey = Y(e.v)
                    ctx.fillStyle = colAccent
                    ctx.beginPath(); ctx.arc(ex, ey, 4, 0, Math.PI * 2); ctx.fill()
                    var t = (e.type === "high" ? "H " : "L ") + e.time + "  " + e.v.toFixed(2) + "m"
                    ctx.font = "12px monospace"; ctx.textAlign = "center"
                    var w = ctx.measureText(t).width + 12
                    var bx = Math.max(L + w / 2, Math.min(L + pw - w / 2, ex))
                    var by = e.type === "high" ? ey - 30 : ey + 12
                    ctx.fillStyle = win.withAlpha(colSurface, 0.9)
                    ctx.fillRect(bx - w / 2, by, w, 20)
                    ctx.fillStyle = colOnSurface
                    ctx.fillText(t, bx, by + 14)
                })
            }
        }
    }
}
