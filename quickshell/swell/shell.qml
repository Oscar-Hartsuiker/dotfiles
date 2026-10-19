import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: win
    title: "Waves"
    implicitWidth: 860
    implicitHeight: 460
    color: c("background", "#0e1220")

    property var d: null

    property var dms: null
    property string dmsRaw: ""
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
    function heatGradient(ctx, yTop, yBottom, topValue, stops) {
        var g = ctx.createLinearGradient(0, yTop, 0, yBottom)
        g.addColorStop(0, stops[0][1])
        for (var i = 0; i < stops.length; i++) {
            var o = (topValue - stops[i][0]) / topValue
            g.addColorStop(Math.max(0, Math.min(1, o)), stops[i][1])
        }
        g.addColorStop(1, stops[stops.length - 1][1])
        return g
    }

    IpcHandler { target: "toggle"; function toggle(): void { win.visible = !win.visible } }
    IpcHandler { target: "show";   function show(): void { win.visible = true } }
    IpcHandler { target: "hide";   function hide(): void { win.visible = false } }

    FileView {
        id: dmsColors
        path: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/DankMaterialShell/dms-colors.json"
        watchChanges: false
        blockLoading: false
        onFileChanged: win.loadDms()
        onLoadFailed: console.log("waves: dms-colors.json missing, using fallback colours")
    }
    Timer {
        interval: 1500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { dmsColors.reload(); dmsApply.start() }
    }
    Timer { id: dmsApply; interval: 80; onTriggered: win.loadDms() }

    function loadDms() {
        var t = dmsColors.text()
        if (!t || t === dmsRaw) return
        try {
            dmsRaw = t
            dms = JSON.parse(t)
            if (cv) cv.requestPaint()
        } catch (e) { console.log("waves: bad dms colours:", e) }
    }

    property bool rtl: false
    property int dayOffset: 0
    property double lastShift: 0

    Process {
        id: proc
        command: ["python3", Quickshell.shellDir + "/swell.py", String(win.dayOffset)]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { win.d = JSON.parse(text) } catch (e) { console.log("swell.py output:", text) }
            }
        }
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: proc.running = true }
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

    readonly property var compass: ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
    function compassOf(deg) { return compass[Math.round(deg / 22.5) % 16] }

    function idxNow() {
        if (!d || !d.dirs.length) return -1
        var h = (d.now >= 0 && d.now <= 24) ? Math.round(d.now) : 12
        var best = 0
        for (var i = 0; i < d.dirs.length; i++)
            if (Math.abs(d.dirs[i][0] - h) < Math.abs(d.dirs[best][0] - h)) best = i
        return best
    }
    function dirText() {
        var i = idxNow()
        if (i < 0) return "--"
        var deg = d.dirs[i][1]
        return compassOf(deg) + "  " + deg + "°"
    }
    function periodText() {
        var i = idxNow()
        if (i < 0) return "--"
        var p = (win.dayOffset === 0 && d.period) ? d.period : d.periods[i][1]
        return p.toFixed(0) + " s"
    }

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
                    { k: win.dayOffset === 0 ? "NOW" : "AVG",
                      v: (win.dayOffset === 0 ? win.d.current.toFixed(2)
                          : (win.d.points.reduce(function (a, p) { return a + p[1] }, 0) / win.d.points.length).toFixed(2))
                         + " m" + (win.dayOffset === 0 ? (win.d.rising ? " ▲" : " ▼") : "") },
                    { k: "PERIOD", v: win.periodText() },
                    { k: "FROM",   v: win.dirText() },
                    { k: "PEAK",   v: win.d.peak.time + "  " + win.d.peak.v.toFixed(2) + " m" }
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
                    if (Date.now() - win.lastShift < 120) return
                    win.lastShift = Date.now()
                    win.shift(e.angleDelta.y < 0 ? 1 : -1)
                }
            }
            TapHandler { onDoubleTapped: win.today() }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var D = win.d
                if (!D) return

                var L = 44, R = 44, T = 26, B = 8
                var pw = width - L - R, ph = height - T - B

                // left axis: wave height (m)
                var maxV = Math.max.apply(null, D.points.map(function (p) { return p[1] }))
                var step = maxV > 3 ? 1 : 0.5
                var lo = 0
                var hi = Math.max(1, Math.ceil((maxV + 0.3) / step) * step)

                // right axis: period (s)
                var pv = D.periods.map(function (p) { return p[1] })
                var pLo = Math.max(0, Math.floor((Math.min.apply(null, pv) - 2) / 2) * 2)
                var pHi = Math.ceil((Math.max.apply(null, pv) + 2) / 2) * 2

                function X(h) { var f = h / 24; if (win.rtl) f = 1 - f; return L + f * pw }
                function Y(v) { return T + (1 - (v - lo) / (hi - lo)) * ph }
                function Yp(v) { return T + (1 - (v - pLo) / (pHi - pLo)) * ph }

                var colAccent = win.c("primary", "#19b5e6")
                var colPeriod = win.c("tertiary", "#e6a419")
                var colOnSurface = win.c("on_surface", "#c8c6ce")
                var colOnSurfaceVar = win.c("on_surface_variant", "#9f9fa9")
                var colSurface = win.c("surface_container", "#121318")
                var swellStops = [[6, "#ef4444"], [3, "#facc15"], [2, "#22c55e"]]
                var swellTop = Math.max(hi, 6)
                var swellHeat = win.heatGradient(ctx, Y(swellTop), Y(0), swellTop, swellStops)

                // day + night
                ctx.fillStyle = win.c("primary_container", win.withAlpha(colAccent, 0.18))
                ctx.fillRect(L, T, pw, ph)
                ctx.fillStyle = win.withAlpha(colSurface, 0.55)
                D.nights.forEach(function (n) {
                    var a = Math.max(0, Math.min(24, n[0])), b = Math.max(0, Math.min(24, n[1]))
                    if (b <= a) return
                    var x1 = X(a), x2 = X(b)
                    ctx.fillRect(Math.min(x1, x2), T, Math.abs(x2 - x1), ph)
                })

                // hour grid + labels
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

                // height gridlines + left labels
                ctx.textAlign = "right"
                for (var k = 0; k <= hi + 0.001; k += step) {
                    ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.25)
                    ctx.beginPath(); ctx.moveTo(L, Y(k)); ctx.lineTo(L + pw, Y(k)); ctx.stroke()
                    ctx.fillStyle = colOnSurfaceVar
                    ctx.fillText(k.toFixed(step < 1 ? 1 : 0) + " m", L - 6, Y(k) + 4)
                }

                // period labels on the right axis (no gridlines)
                ctx.textAlign = "left"
                ctx.fillStyle = colPeriod
                for (var s = pLo; s <= pHi; s += 2)
                    ctx.fillText(s + " s", L + pw + 6, Yp(s) + 4)

                function mk(arr, fy) { return arr.map(function (p) { return { x: X(p[0]), y: fy(p[1]) } }) }
                function trace(pts) {
                    ctx.moveTo(pts[0].x, pts[0].y)
                    for (var i = 0; i < pts.length - 1; i++) {
                        var p0 = pts[Math.max(i - 1, 0)], p1 = pts[i], p2 = pts[i + 1]
                        var p3 = pts[Math.min(i + 2, pts.length - 1)]
                        ctx.bezierCurveTo(p1.x + (p2.x - p0.x) / 6, p1.y + (p2.y - p0.y) / 6,
                                          p2.x - (p3.x - p1.x) / 6, p2.y - (p3.y - p1.y) / 6,
                                          p2.x, p2.y)
                    }
                }
                var sp = mk(D.points, Y)
                var pp = mk(D.periods, Yp)

                ctx.save()
                ctx.beginPath(); ctx.rect(L, T, pw, ph); ctx.clip()

                // height curve + fill
                ctx.beginPath(); trace(sp)
                ctx.lineTo(sp[sp.length - 1].x, T + ph); ctx.lineTo(sp[0].x, T + ph); ctx.closePath()
                ctx.globalAlpha = 0.18; ctx.fillStyle = swellHeat; ctx.fill(); ctx.globalAlpha = 1
                ctx.beginPath(); trace(sp)
                ctx.lineJoin = "round"; ctx.lineCap = "round"
                ctx.strokeStyle = swellHeat; ctx.lineWidth = 3; ctx.stroke()

                // period curve (dashed)
                ctx.beginPath(); trace(pp)
                ctx.setLineDash([6, 5])
                ctx.strokeStyle = colPeriod; ctx.lineWidth = 2; ctx.stroke()
                ctx.setLineDash([])
                ctx.restore()

                // period numbers every 2 h on the dashed line
                ctx.font = "bold 11px monospace"; ctx.textAlign = "center"
                D.periods.forEach(function (e, i) {
                    if (e[0] % 2 !== 0 || !pp[i]) return
                    ctx.fillStyle = colPeriod
                    ctx.fillText(e[1].toFixed(0) + "s", pp[i].x, Math.max(T + 12, pp[i].y - 8))
                })

                // direction arrows every 2 h on the height line (point where the waves travel)
                D.dirs.forEach(function (e, i) {
                    if (e[0] % 2 !== 0 || !sp[i]) return
                    ctx.save()
                    ctx.translate(sp[i].x, sp[i].y)
                    ctx.rotate((e[1] + 180) * Math.PI / 180)
                    ctx.beginPath()
                    ctx.moveTo(0, -10); ctx.lineTo(6, 6); ctx.lineTo(0, 3); ctx.lineTo(-6, 6); ctx.closePath()
                    ctx.fillStyle = colOnSurface
                    ctx.strokeStyle = win.withAlpha(colSurface, 0.9); ctx.lineWidth = 2
                    ctx.stroke(); ctx.fill()
                    ctx.restore()
                })

                // now marker
                if (D.now >= 0 && D.now <= 24) {
                    var nx = X(D.now), ny = Y(D.current)
                    ctx.strokeStyle = win.withAlpha(colOnSurface, 0.7); ctx.lineWidth = 1
                    ctx.beginPath(); ctx.moveTo(nx, T); ctx.lineTo(nx, T + ph); ctx.stroke()
                    ctx.fillStyle = colAccent; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 3
                    ctx.beginPath(); ctx.arc(nx, ny, 6, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                }

                // legend
                ctx.font = "11px monospace"; ctx.textAlign = "right"
                ctx.fillStyle = colOnSurfaceVar; ctx.fillText("— height", L + pw - 76, T + 14)
                ctx.fillStyle = colPeriod; ctx.fillText("- - period", L + pw - 6, T + 14)
            }
        }
    }
}
