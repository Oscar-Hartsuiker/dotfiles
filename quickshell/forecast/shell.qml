import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: win
    title: "Forecast"
    implicitWidth: 1600
    implicitHeight: 960
    color: c("background", "#0e1220")

    property var dWind: null
    property var dSwell: null
    property var dTide: null

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
    function graphDayBg() {
        var dark = !dms || dms.mode !== "light"
        return c(dark ? "surface_container_low" : "surface_container_lowest", dark ? "#1a1c20" : "#ffffff")
    }
    function graphNightBg() {
        var dark = !dms || dms.mode !== "light"
        return c(dark ? "surface_container_lowest" : "surface_container_high", dark ? "#0c0e13" : "#ededf4")
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
        onLoadFailed: console.log("forecast: dms-colors.json missing, using fallback colours")
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
        } catch (e) { console.log("forecast: bad dms colours:", e) }
    }

    property bool rtl: false
    property int dayOffset: 0
    property double lastShift: 0
    property double lastG: 0
    property bool overview: false
    property var moonNow: new Date()
    property bool tooltipOn: false
    property int tooltipGraph: 0
    property real tooltipHour: 12
    property bool helpVisible: false
    function updatedTime() {
        var D = mainData()
        if (!D || !D.updated) return null
        var d = new Date(D.updated)
        return isNaN(d.getTime()) ? null : d
    }
    property string updatedText: updatedTime()
        ? "UPDATED " + Qt.formatDateTime(updatedTime(), "dd MMM HH:mm")
        : "UPDATED --"

    Process {
        id: windProc
        command: ["python3", Quickshell.shellDir + "/wind.py", win.overview ? "all" : String(win.dayOffset)]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { win.dWind = JSON.parse(text) } catch (e) { console.log("wind.py output:", text) }
            }
        }
    }
    Process {
        id: swellProc
        command: ["python3", Quickshell.shellDir + "/swell.py", win.overview ? "all" : String(win.dayOffset)]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { win.dSwell = JSON.parse(text) } catch (e) { console.log("swell.py output:", text) }
            }
        }
    }
    Process {
        id: tideProc
        command: ["python3", Quickshell.shellDir + "/tide.py", win.overview ? "all" : String(win.dayOffset)]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { win.dTide = JSON.parse(text) } catch (e) { console.log("tide.py output:", text) }
            }
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: {
            windProc.running = true; swellProc.running = true; tideProc.running = true
            win.moonNow = new Date()
        }
    }
    Timer {
        id: restart; interval: 30
        onTriggered: { windProc.running = true; swellProc.running = true; tideProc.running = true }
    }

    function refresh() {
        windProc.running = false
        swellProc.running = false
        tideProc.running = false
        restart.start()
    }
    function shift(n) {
        if (overview) return
        var o = Math.max(0, Math.min(9, dayOffset + n))
        if (o === dayOffset) return
        dayOffset = o
        refresh()
    }
    function today() {
        if (overview || dayOffset === 0) return
        dayOffset = 0
        refresh()
    }
    function toggleOverview() {
        overview = !overview
        refresh()
    }
    function gotoDay(i) {
        var o = Math.max(0, Math.min(9, i))
        if (!overview && o === dayOffset) return
        overview = false
        dayOffset = o
        refresh()
    }
    function handleWheel(e) {
        var ax = e.angleDelta.x, ay = e.angleDelta.y
        var dx = ax !== 0 ? ax : e.pixelDelta.x
        var dy = ay !== 0 ? ay : e.pixelDelta.y
        if (!dx && !dy) return
        var horizontal = Math.abs(dx) > Math.abs(dy)
        if (Date.now() - lastShift < (horizontal ? 333 : 120)) return
        lastShift = Date.now()
        if (horizontal) shift(dx > 0 ? -1 : 1)
        else shift(dy < 0 ? 1 : -1)
    }

    readonly property var compass: ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
    function compassOf(deg) { return compass[Math.round(deg / 22.5) % 16] }

    readonly property var shortDays: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    function dayShort(off) {
        var d = new Date()
        d.setDate(d.getDate() + off)
        return shortDays[d.getDay()] + " " + d.getDate()
    }
    function dayAt(x, w) {
        return Math.max(0, Math.min(9, Math.floor(x / w * 10)))
    }

    function mainData() {
        return dWind || dSwell || dTide
    }

    function idxNow(D) {
        if (!D || !D.dirs.length) return -1
        var h = (D.now >= 0 && D.now <= 24) ? Math.round(D.now) : 12
        var best = 0
        for (var i = 0; i < D.dirs.length; i++)
            if (Math.abs(D.dirs[i][0] - h) < Math.abs(D.dirs[best][0] - h)) best = i
        return best
    }
    function dirText(D) {
        var i = idxNow(D)
        if (i < 0) return "--"
        var deg = D.dirs[i][1]
        return compassOf(deg) + "  " + deg + "°"
    }
    function periodText(D) {
        var i = idxNow(D)
        if (i < 0) return "--"
        var p = (win.dayOffset === 0 && D.period) ? D.period : D.periods[i][1]
        return p.toFixed(0) + " s"
    }

    function nextTide(D, type) {
        if (!D) return null
        var from = (D.now >= 0 && D.now <= 24) ? D.now : 0
        for (var i = 0; i < D.extrema.length; i++)
            if (D.extrema[i].type === type && D.extrema[i].h > from) return D.extrema[i]
        return null
    }
    function fmtTide(e) { return e ? e.time + "  " + e.v.toFixed(2) + " m" : "--" }

    function paintTimeGrid(ctx, X, T, ph, span, days, labelColor, lineColor) {
        ctx.font = "12px monospace"
        ctx.textAlign = "center"
        ctx.lineWidth = 1
        if (days && span > 24) {
            for (var i = 0; i < days.length; i++) {
                var gx = X(days[i].h)
                ctx.strokeStyle = win.withAlpha(lineColor, 0.35)
                ctx.beginPath(); ctx.moveTo(gx, T); ctx.lineTo(gx, T + ph); ctx.stroke()
                ctx.strokeStyle = win.withAlpha(lineColor, 0.18)
                var gm = X(days[i].h + 12)
                ctx.beginPath(); ctx.moveTo(gm, T); ctx.lineTo(gm, T + ph); ctx.stroke()
                ctx.fillStyle = labelColor
                ctx.fillText(days[i].short || days[i].label, gx, T - 8)
            }
            var gxEnd = X(span)
            ctx.strokeStyle = win.withAlpha(lineColor, 0.35)
            ctx.beginPath(); ctx.moveTo(gxEnd, T); ctx.lineTo(gxEnd, T + ph); ctx.stroke()
        } else {
            for (var h = 0; h <= 24; h += 2) {
                var gx2 = X(h), hh = h % 24
                ctx.strokeStyle = win.withAlpha(lineColor, 0.35)
                ctx.beginPath(); ctx.moveTo(gx2, T); ctx.lineTo(gx2, T + ph); ctx.stroke()
                ctx.fillStyle = labelColor
                ctx.fillText((hh < 10 ? "0" : "") + hh + ":00", gx2, T - 8)
            }
        }
    }

    function nearestIdx(arr, h) {
        if (!arr || !arr.length) return -1
        var lo = 0, hi = arr.length - 1
        while (lo < hi) {
            var mid = Math.floor((lo + hi) / 2)
            if (arr[mid][0] < h) lo = mid + 1
            else hi = mid
        }
        if (lo > 0 && Math.abs(arr[lo - 1][0] - h) <= Math.abs(arr[lo][0] - h)) lo--
        return lo
    }

    function hoverTimeText(D, h) {
        var label = D && D.label ? D.label : ""
        var local = h
        if (win.overview && D && D.days && D.days.length) {
            var dayIdx = Math.max(0, Math.min(D.days.length - 1, Math.floor(h / 24)))
            local = h - dayIdx * 24
            label = D.days[dayIdx].label || label
        }
        var hh = Math.floor(local + 1e-6)
        var mm = Math.round((local - hh) * 60)
        if (mm >= 60) { hh += 1; mm -= 60 }
        return label + " · " + (hh < 10 ? "0" : "") + hh + ":" + (mm < 10 ? "0" : "") + mm
    }

    function paintHoverTooltip(ctx, mx, title, rows, L, T, pw, ph) {
        var colSurface = win.c("surface_container", "#121318")
        var colOnSurface = win.c("on_surface", "#e6ebff")
        var colOnSurfaceVar = win.c("on_surface_variant", "#9f9fa9")
        var colAccent = win.c("primary", "#19b5e6")

        ctx.save()
        ctx.font = "bold 13px monospace"
        var contentW = ctx.measureText(title).width
        ctx.font = "13px monospace"
        for (var i = 0; i < rows.length; i++)
            contentW = Math.max(contentW, ctx.measureText(rows[i]).width)

        var padX = 9, padY = 8, lineH = 14
        var bw = Math.ceil(contentW) + padX * 2 + 5
        var bh = padY * 2 + 15 + rows.length * lineH
        var bx = mx + 14
        if (bx + bw > L + pw - 4) bx = mx - bw - 14
        bx = Math.max(L + 4, Math.min(L + pw - bw - 4, bx))
        var by = T + ph - bh - 4

        ctx.fillStyle = win.withAlpha(colSurface, 0.7)
        ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.3)
        ctx.lineWidth = 1
        ctx.beginPath(); ctx.rect(bx, by, bw, bh); ctx.fill(); ctx.stroke()
        ctx.fillStyle = colAccent
        ctx.fillRect(bx, by, 2, bh)

        ctx.textAlign = "left"
        ctx.font = "bold 13px monospace"
        ctx.fillStyle = colOnSurface
        ctx.fillText(title, bx + padX + 4, by + padY + 10)
        ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.18)
        ctx.beginPath(); ctx.moveTo(bx + padX + 4, by + padY + 15); ctx.lineTo(bx + bw - padX, by + padY + 15); ctx.stroke()
        ctx.font = "13px monospace"
        ctx.fillStyle = colOnSurfaceVar
        for (var j = 0; j < rows.length; j++)
            ctx.fillText(rows[j], bx + padX + 4, by + padY + 31 + j * lineH)
        ctx.restore()
    }

    function moonPhaseAt(t) {
        var synodic = 29.530588853
        var epoch = Date.UTC(2000, 0, 6, 18, 14)
        var days = (t.getTime() - epoch) / 86400000
        return (((days / synodic) % 1) + 1) % 1
    }
    function moonIllumAt(p) {
        return (1 - Math.cos(2 * Math.PI * p)) / 2
    }
    function moonNameAt(p) {
        var names = ["NEW MOON", "WAXING CRESCENT", "FIRST QUARTER", "WAXING GIBBOUS",
                     "FULL MOON", "WANING GIBBOUS", "LAST QUARTER", "WANING CRESCENT"]
        return names[Math.round(p * 8) % 8]
    }

    function tooltipGraphData(i) {
        return i === 0 ? dWind : (i === 1 ? dSwell : dTide)
    }
    function tooltipSpanFor(D) {
        return (overview && D && D.span) ? D.span : 24
    }
    function toggleTooltip() {
        if (tooltipOn) {
            tooltipOn = false
            return
        }
        var D = tooltipGraphData(tooltipGraph)
        tooltipHour = Math.max(0, Math.min(tooltipSpanFor(D), tooltipHour))
        tooltipOn = true
    }
    function hideTooltip() {
        tooltipOn = false
    }
    function showTooltipAt(graph, x, w) {
        tooltipGraph = graph
        var D = tooltipGraphData(graph)
        var span = tooltipSpanFor(D)
        var f = (x - 8) / Math.max(1, w - 16)
        if (rtl) f = 1 - f
        tooltipHour = Math.max(0, Math.min(span, f * span))
        tooltipOn = true
    }
    function moveTooltip(dx) {
        if (!tooltipOn) return
        var D = tooltipGraphData(tooltipGraph)
        tooltipHour = Math.max(0, Math.min(tooltipSpanFor(D), tooltipHour + dx))
    }
    function moveTooltipGraph(dy) {
        if (!tooltipOn) return
        tooltipGraph = Math.max(0, Math.min(2, tooltipGraph + dy))
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        focus: true

        Keys.onLeftPressed: if (!win.helpVisible) win.shift(-1)
        Keys.onRightPressed: if (!win.helpVisible) win.shift(1)
        Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Slash || e.key === Qt.Key_Question) {
                win.helpVisible = !win.helpVisible
                return
            }
            if (win.helpVisible) {
                if (e.key === Qt.Key_Escape) win.helpVisible = false
                return
            }
            if (e.key === Qt.Key_G) {
                if (e.modifiers & Qt.ShiftModifier) {
                    win.lastG = 0
                    win.gotoDay(9)
                } else {
                    var now = Date.now()
                    if (now - win.lastG < 700) {
                        win.lastG = 0
                        win.gotoDay(0)
                    } else {
                        win.lastG = now
                    }
                }
            } else if (e.key === Qt.Key_Home) win.today()
            else if (e.key === Qt.Key_Space) win.toggleOverview()
            else if (e.key === Qt.Key_R) win.refresh()
            else if (e.key === Qt.Key_Q) Qt.quit()
            else if (e.key === Qt.Key_I) win.toggleTooltip()
            else if (e.key === Qt.Key_H) win.moveTooltip(-1)
            else if (e.key === Qt.Key_L) win.moveTooltip(1)
            else if (e.key === Qt.Key_J) win.moveTooltipGraph(1)
            else if (e.key === Qt.Key_K) win.moveTooltipGraph(-1)
            else if (e.key === Qt.Key_N) win.shift((e.modifiers & Qt.ShiftModifier) ? -1 : 1)
            else if (e.key >= Qt.Key_1 && e.key <= Qt.Key_9) win.gotoDay(e.key - Qt.Key_1)
            else if (e.key === Qt.Key_0) win.gotoDay(9)
        }
        WheelHandler {
            orientation: Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (e) => win.handleWheel(e)
        }
        WheelHandler {
            orientation: Qt.Vertical
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (e) => win.handleWheel(e)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 36

            ColumnLayout {
                spacing: 0
                Text {
                    text: "FORECAST"; color: win.c("primary", "#19b5e6")
                    font.pixelSize: 12; font.letterSpacing: 2; font.bold: true
                }
                Text {
                    text: win.mainData() ? win.mainData().station : "--"
                    color: win.c("on_surface", "#e6ebff"); font.pixelSize: 18; font.bold: true
                }
            }
            ColumnLayout {
                spacing: 0
                Text {
                    text: "DATE"; color: win.c("on_surface_variant", "#7f8bb3")
                    font.pixelSize: 12; font.letterSpacing: 1.5
                }
                Text {
                    text: win.mainData()
                        ? (win.overview ? win.mainData().label
                                        : win.mainData().label + (win.dayOffset === 0 ? "  · today" : ""))
                        : "--"
                    color: win.c("on_surface", "#e6ebff"); font.pixelSize: 18; font.bold: true
                }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                spacing: 0
                Text {
                    Layout.alignment: Qt.AlignRight
                    text: win.updatedText
                    color: win.c("on_surface_variant", "#7f8bb3")
                    font.pixelSize: 12; font.letterSpacing: 1
                }
                Text {
                    Layout.alignment: Qt.AlignRight
                    text: "← → / scroll  ·  Home = today  ·  " + (win.overview ? "Space = single day" : "Space = 10-day") + "  ·  / = keys"
                    color: win.c("on_surface_variant", "#7f8bb3")
                    font.pixelSize: 12
                }
            }
        }

        // ── wind ──────────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                Text {
                    text: "WIND"; Layout.preferredWidth: 76
                    color: win.c("primary", "#19b5e6")
                    font.pixelSize: 22; font.letterSpacing: 2; font.bold: true
                }
                Repeater {
                    model: win.dWind ? (win.overview ? [
                        { k: "MAX WIND",
                          v: Math.max.apply(null, win.dWind.points.map(function (p) { return p[1] })).toFixed(1) + " kn" },
                        { k: "MAX GUST", v: win.dWind.max_gust.v.toFixed(1) + " kn" },
                        { k: "GUST PEAK", v: win.dWind.max_gust.time }
                    ] : [
                        { k: win.dayOffset === 0 ? "NOW" : "AVG",
                          v: (win.dayOffset === 0 ? win.dWind.current.toFixed(1)
                              : (win.dWind.points.reduce(function (a, p) { return a + p[1] }, 0) / win.dWind.points.length).toFixed(1))
                             + " kn" + (win.dayOffset === 0 ? (win.dWind.rising ? " ▲" : " ▼") : "") },
                        { k: "FROM", v: win.dirText(win.dWind) },
                        { k: "MAX GUST", v: win.dWind.max_gust.time + "  " + win.dWind.max_gust.v.toFixed(1) + " kn" }
                    ]) : []
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.k; color: win.c("on_surface_variant", "#7f8bb3"); font.pixelSize: 12; font.letterSpacing: 1.5 }
                        Text { text: modelData.v; color: win.c("on_surface", "#e6ebff"); font.pixelSize: 16; font.bold: true }
                    }
                }
            }

            Canvas {
                id: windCv
                Layout.fillWidth: true
                Layout.fillHeight: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) win.hideTooltip()
                        else win.showTooltipAt(0, mouse.x, width)
                    }
                    onDoubleClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            win.hideTooltip()
                            win.today()
                        }
                    }
                }
                Connections { target: win; function onDWindChanged() { windCv.requestPaint() } }
                Connections { target: win; function onDmsChanged() { windCv.requestPaint() } }
                Connections {
                    target: win
                    function onTooltipOnChanged() { windCv.requestPaint() }
                    function onTooltipGraphChanged() { windCv.requestPaint() }
                    function onTooltipHourChanged() { windCv.requestPaint() }
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var D = win.dWind
                    if (!D) return

                    var L = 8, R = 8, T = 26, B = 8
                    var pw = width - L - R, ph = height - T - B
                    var span = (win.overview && D.span) ? D.span : 24
                    var maxV = Math.max.apply(null, D.gusts.map(function (p) { return p[1] }))
                    var lo = 0
                    var hi = Math.max(40, Math.ceil(maxV / 5) * 5)
                    function X(h) { var f = h / span; if (win.rtl) f = 1 - f; return L + f * pw }
                    function Y(v) { return T + (1 - (v - lo) / (hi - lo)) * ph }

                    var colAccent = win.c("primary", "#19b5e6")
                    var colOnSurface = win.c("on_surface", "#c8c6ce")
                    var colOnSurfaceVar = win.c("on_surface_variant", "#9f9fa9")
                    var colSurface = win.c("surface_container", "#121318")
                    var windStops = [[30, "#ef4444"], [20, "#facc15"], [10, "#22c55e"]]
                    var windTop = Math.max(hi, 30)
                    var windHeat = win.heatGradient(ctx, Y(windTop), Y(0), windTop, windStops)

                    ctx.fillStyle = win.graphDayBg()
                    ctx.fillRect(L, T, pw, ph)
                    ctx.fillStyle = win.graphNightBg()
                    D.nights.forEach(function (n) {
                        var a = Math.max(0, Math.min(span, n[0])), b = Math.max(0, Math.min(span, n[1]))
                        if (b <= a) return
                        var x1 = X(a), x2 = X(b)
                        ctx.fillRect(Math.min(x1, x2), T, Math.abs(x2 - x1), ph)
                    })

                    win.paintTimeGrid(ctx, X, T, ph, span, win.overview ? D.days : null, colOnSurfaceVar, colOnSurfaceVar)

                    for (var k = 0; k <= hi; k += 5) {
                        ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.25)
                        ctx.beginPath(); ctx.moveTo(L, Y(k)); ctx.lineTo(L + pw, Y(k)); ctx.stroke()
                    }

                    function mkPts(arr) { return arr.map(function (p) { return { x: X(p[0]), y: Y(p[1]) } }) }
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
                    var sp = mkPts(D.points), gp = mkPts(D.gusts)

                    ctx.save()
                    ctx.beginPath(); ctx.rect(L, T, pw, ph); ctx.clip()

                    ctx.beginPath(); trace(gp)
                    ctx.setLineDash([6, 5])
                    ctx.lineJoin = "round"; ctx.lineCap = "round"
                    ctx.strokeStyle = windHeat; ctx.lineWidth = 2; ctx.stroke()
                    ctx.setLineDash([])

                    ctx.beginPath(); trace(sp)
                    ctx.lineTo(sp[sp.length - 1].x, T + ph); ctx.lineTo(sp[0].x, T + ph); ctx.closePath()
                    ctx.globalAlpha = 0; ctx.fillStyle = windHeat; ctx.fill(); ctx.globalAlpha = 1
                    ctx.beginPath(); trace(sp)
                    ctx.strokeStyle = windHeat; ctx.lineWidth = 3; ctx.stroke()
                    ctx.restore()

                    D.dirs.forEach(function (e, i) {
                        if (win.overview ? (e[0] % 6 !== 0) : (e[0] % 2 !== 0 || e[0] > 24)) return
                        var p = sp[i]
                        if (!p) return
                        ctx.save()
                        ctx.translate(p.x, p.y)
                        ctx.rotate((e[1] + 180) * Math.PI / 180)
                        ctx.beginPath()
                        ctx.moveTo(0, -10); ctx.lineTo(6, 6); ctx.lineTo(0, 3); ctx.lineTo(-6, 6); ctx.closePath()
                        ctx.fillStyle = colOnSurface
                        ctx.strokeStyle = win.withAlpha(colSurface, 0.9); ctx.lineWidth = 2
                        ctx.stroke(); ctx.fill()
                        ctx.restore()
                    })

                    if (D.now >= 0 && D.now <= 24) {
                        var nx = X(D.now), ny = Y(D.current)
                        ctx.strokeStyle = win.withAlpha("#ff2d95", 0.7); ctx.lineWidth = 2
                        ctx.beginPath(); ctx.moveTo(nx, T); ctx.lineTo(nx, T + ph); ctx.stroke()
                        ctx.fillStyle = "#ff2d95"; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 3
                        ctx.beginPath(); ctx.arc(nx, ny, 6, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                    }

                    ctx.font = "12px monospace"; ctx.textAlign = "left"
                    for (var kk = 0; kk <= hi; kk += 5) {
                        var ly = Math.max(T + 12, Math.min(T + ph - 4, Y(kk) + 4))
                        var label = kk + " kn"
                        var tw = ctx.measureText(label).width
                        ctx.fillStyle = win.withAlpha(colSurface, 0.78)
                        ctx.fillRect(L + 2, ly - 11, tw + 6, 14)
                        ctx.fillStyle = colOnSurfaceVar
                        ctx.fillText(label, L + 5, ly)
                    }

                    ctx.textAlign = "right"
                    ctx.fillStyle = colOnSurfaceVar; ctx.fillText("— wind", L + pw - 70, T + 14)
                    ctx.fillStyle = colOnSurfaceVar; ctx.fillText("- - gust", L + pw - 6, T + 14)

                    if (win.tooltipOn && win.tooltipGraph === 0) {
                        var hour = Math.max(0, Math.min(span, win.tooltipHour))
                        var di = win.nearestIdx(D.points, hour)
                        if (di >= 0) {
                            var ph0 = D.points[di][0]
                            var gx = X(ph0)
                            var tipX = gx
                            var speed = D.points[di][1]
                            var gust = D.gusts[di] ? D.gusts[di][1] : speed
                            var deg = D.dirs[di] ? D.dirs[di][1] : 0

                            ctx.save()
                            ctx.strokeStyle = win.withAlpha(colOnSurface, 0.35); ctx.lineWidth = 1
                            ctx.setLineDash([4, 4])
                            ctx.beginPath(); ctx.moveTo(gx, T); ctx.lineTo(gx, T + ph); ctx.stroke()
                            ctx.setLineDash([])
                            ctx.fillStyle = colAccent; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 2
                            ctx.beginPath(); ctx.arc(gx, Y(speed), 4, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                            ctx.beginPath(); ctx.arc(gx, Y(gust), 4, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                            ctx.restore()

                            win.paintHoverTooltip(ctx, tipX,
                                win.hoverTimeText(D, ph0),
                                ["WIND   " + speed.toFixed(1) + " kn",
                                 "GUST   " + gust.toFixed(1) + " kn",
                                 "FROM   " + win.compassOf(deg) + " " + Math.round(deg) + "°"],
                                L, T, pw, ph)
                        }
                    }
                }
            }
        }

        // ── swell ─────────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                Text {
                    text: "SWELL"; Layout.preferredWidth: 76
                    color: win.c("primary", "#19b5e6")
                    font.pixelSize: 22; font.letterSpacing: 2; font.bold: true
                }
                Repeater {
                    model: win.dSwell ? (win.overview ? [
                        { k: "MAX HEIGHT",
                          v: Math.max.apply(null, win.dSwell.points.map(function (p) { return p[1] })).toFixed(2) + " m" },
                        { k: "PEAK PERIOD",
                          v: Math.max.apply(null, win.dSwell.periods.map(function (p) { return p[1] })).toFixed(0) + " s" },
                        { k: "PEAK", v: win.dSwell.peak.time }
                    ] : [
                        { k: win.dayOffset === 0 ? "NOW" : "AVG",
                          v: (win.dayOffset === 0 ? win.dSwell.current.toFixed(2)
                              : (win.dSwell.points.reduce(function (a, p) { return a + p[1] }, 0) / win.dSwell.points.length).toFixed(2))
                             + " m" + (win.dayOffset === 0 ? (win.dSwell.rising ? " ▲" : " ▼") : "") },
                        { k: "PERIOD", v: win.periodText(win.dSwell) },
                        { k: "FROM", v: win.dirText(win.dSwell) },
                        { k: "PEAK", v: win.dSwell.peak.time + "  " + win.dSwell.peak.v.toFixed(2) + " m" }
                    ]) : []
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.k; color: win.c("on_surface_variant", "#7f8bb3"); font.pixelSize: 12; font.letterSpacing: 1.5 }
                        Text { text: modelData.v; color: win.c("on_surface", "#e6ebff"); font.pixelSize: 16; font.bold: true }
                    }
                }
            }

            Canvas {
                id: swellCv
                Layout.fillWidth: true
                Layout.fillHeight: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) win.hideTooltip()
                        else win.showTooltipAt(1, mouse.x, width)
                    }
                    onDoubleClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            win.hideTooltip()
                            win.today()
                        }
                    }
                }
                Connections { target: win; function onDSwellChanged() { swellCv.requestPaint() } }
                Connections { target: win; function onDmsChanged() { swellCv.requestPaint() } }
                Connections {
                    target: win
                    function onTooltipOnChanged() { swellCv.requestPaint() }
                    function onTooltipGraphChanged() { swellCv.requestPaint() }
                    function onTooltipHourChanged() { swellCv.requestPaint() }
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var D = win.dSwell
                    if (!D) return

                    var L = 8, R = 8, T = 26, B = 8
                    var pw = width - L - R, ph = height - T - B
                    var span = (win.overview && D.span) ? D.span : 24

                    var maxV = Math.max.apply(null, D.points.map(function (p) { return p[1] }))
                    var step = 1
                    var lo = 0
                    var hi = Math.max(6, Math.ceil(maxV / step) * step)

                    var pv = D.periods.map(function (p) { return p[1] })
                    var pLo = Math.max(0, Math.floor((Math.min.apply(null, pv) - 2) / 2) * 2)
                    var pHi = Math.ceil((Math.max.apply(null, pv) + 2) / 2) * 2

                    function X(h) { var f = h / span; if (win.rtl) f = 1 - f; return L + f * pw }
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

                    ctx.fillStyle = win.graphDayBg()
                    ctx.fillRect(L, T, pw, ph)
                    ctx.fillStyle = win.graphNightBg()
                    D.nights.forEach(function (n) {
                        var a = Math.max(0, Math.min(span, n[0])), b = Math.max(0, Math.min(span, n[1]))
                        if (b <= a) return
                        var x1 = X(a), x2 = X(b)
                        ctx.fillRect(Math.min(x1, x2), T, Math.abs(x2 - x1), ph)
                    })

                    win.paintTimeGrid(ctx, X, T, ph, span, win.overview ? D.days : null, colOnSurfaceVar, colOnSurfaceVar)

                    for (var k = 0; k <= hi + 0.001; k += step) {
                        ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.25)
                        ctx.beginPath(); ctx.moveTo(L, Y(k)); ctx.lineTo(L + pw, Y(k)); ctx.stroke()
                    }

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

                    ctx.beginPath(); trace(sp)
                    ctx.lineTo(sp[sp.length - 1].x, T + ph); ctx.lineTo(sp[0].x, T + ph); ctx.closePath()
                    ctx.globalAlpha = 0; ctx.fillStyle = swellHeat; ctx.fill(); ctx.globalAlpha = 1
                    ctx.beginPath(); trace(sp)
                    ctx.lineJoin = "round"; ctx.lineCap = "round"
                    ctx.strokeStyle = swellHeat; ctx.lineWidth = 3; ctx.stroke()

                    ctx.beginPath(); trace(pp)
                    ctx.setLineDash([6, 5])
                    ctx.strokeStyle = colPeriod; ctx.lineWidth = 2; ctx.stroke()
                    ctx.setLineDash([])
                    ctx.restore()

                    ctx.font = "bold 12px monospace"; ctx.textAlign = "center"
                    D.periods.forEach(function (e, i) {
                        if (e[0] === 0 || (win.overview ? (e[0] % 24 !== 12) : (e[0] % 2 !== 0))) return
                        if (!pp[i]) return
                        ctx.fillStyle = colPeriod
                        ctx.fillText(e[1].toFixed(0) + "s", pp[i].x, Math.max(T + 12, pp[i].y - 8))
                    })

                    D.dirs.forEach(function (e, i) {
                        if (win.overview ? (e[0] % 6 !== 0) : (e[0] % 2 !== 0)) return
                        if (!sp[i]) return
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

                    if (D.now >= 0 && D.now <= 24) {
                        var nx = X(D.now), ny = Y(D.current)
                        ctx.strokeStyle = win.withAlpha("#ff2d95", 0.7); ctx.lineWidth = 2
                        ctx.beginPath(); ctx.moveTo(nx, T); ctx.lineTo(nx, T + ph); ctx.stroke()
                        ctx.fillStyle = "#ff2d95"; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 3
                        ctx.beginPath(); ctx.arc(nx, ny, 6, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                    }

                    ctx.font = "12px monospace"; ctx.textAlign = "left"
                    for (var kk = 0; kk <= hi + 0.001; kk += step) {
                        var ly = Math.max(T + 12, Math.min(T + ph - 4, Y(kk) + 4))
                        var label = kk.toFixed(step < 1 ? 1 : 0) + " m"
                        var tw = ctx.measureText(label).width
                        ctx.fillStyle = win.withAlpha(colSurface, 0.78)
                        ctx.fillRect(L + 2, ly - 11, tw + 6, 14)
                        ctx.fillStyle = colOnSurfaceVar
                        ctx.fillText(label, L + 5, ly)
                    }

                    ctx.textAlign = "right"
                    ctx.fillStyle = colOnSurfaceVar; ctx.fillText("— height", L + pw - 76, T + 14)
                    ctx.fillStyle = colPeriod; ctx.fillText("- - period", L + pw - 6, T + 14)

                    if (win.tooltipOn && win.tooltipGraph === 1) {
                        var hour = Math.max(0, Math.min(span, win.tooltipHour))
                        var di = win.nearestIdx(D.points, hour)
                        if (di >= 0) {
                            var ph0 = D.points[di][0]
                            var gx = X(ph0)
                            var tipX = gx
                            var waveH = D.points[di][1]
                            var period = D.periods[di] ? D.periods[di][1] : 0
                            var deg = D.dirs[di] ? D.dirs[di][1] : 0

                            ctx.save()
                            ctx.strokeStyle = win.withAlpha(colOnSurface, 0.35); ctx.lineWidth = 1
                            ctx.setLineDash([4, 4])
                            ctx.beginPath(); ctx.moveTo(gx, T); ctx.lineTo(gx, T + ph); ctx.stroke()
                            ctx.setLineDash([])
                            ctx.fillStyle = colAccent; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 2
                            ctx.beginPath(); ctx.arc(gx, Y(waveH), 4, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                            ctx.fillStyle = colPeriod
                            ctx.beginPath(); ctx.arc(gx, Yp(period), 4, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                            ctx.restore()

                            win.paintHoverTooltip(ctx, tipX,
                                win.hoverTimeText(D, ph0),
                                ["HEIGHT " + waveH.toFixed(2) + " m",
                                 "PERIOD " + period.toFixed(0) + " s",
                                 "FROM   " + win.compassOf(deg) + " " + Math.round(deg) + "°"],
                                L, T, pw, ph)
                        }
                    }
                }
            }
        }

        // ── tide ──────────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                Text {
                    text: "TIDE"; Layout.preferredWidth: 76
                    color: win.c("primary", "#19b5e6")
                    font.pixelSize: 22; font.letterSpacing: 2; font.bold: true
                }
                Repeater {
                    model: win.dTide ? (win.overview ? [
                        { k: "10-DAY HIGH",
                          v: Math.max.apply(null, win.dTide.points.map(function (p) { return p[1] })).toFixed(2) + " m" },
                        { k: "10-DAY LOW",
                          v: Math.min.apply(null, win.dTide.points.map(function (p) { return p[1] })).toFixed(2) + " m" },
                        { k: "RANGE",
                          v: (Math.max.apply(null, win.dTide.points.map(function (p) { return p[1] }))
                              - Math.min.apply(null, win.dTide.points.map(function (p) { return p[1] }))).toFixed(2) + " m" }
                    ] : [
                        { k: "NOW",
                          v: win.dTide.current.toFixed(2) + " m " + (win.dTide.rising ? "▲" : "▼") },
                        { k: win.dayOffset === 0 ? "NEXT HIGH" : "HIGH", v: win.fmtTide(win.nextTide(win.dTide, "high")) },
                        { k: win.dayOffset === 0 ? "NEXT LOW"  : "LOW",  v: win.fmtTide(win.nextTide(win.dTide, "low")) }
                    ]) : []
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.k; color: win.c("on_surface_variant", "#7f8bb3"); font.pixelSize: 12; font.letterSpacing: 1.5 }
                        Text { text: modelData.v; color: win.c("on_surface", "#e6ebff"); font.pixelSize: 16; font.bold: true }
                    }
                }
                Item { Layout.fillWidth: true }
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: 9
                    Canvas {
                        id: moonCv
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        Connections { target: win; function onMoonNowChanged() { moonCv.requestPaint() } }
                        Connections { target: win; function onDmsChanged() { moonCv.requestPaint() } }
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var r = Math.min(width, height) / 2 - 1
                            var cx = width / 2, cy = height / 2
                            var p = win.moonPhaseAt(win.moonNow)
                            var illum = win.moonIllumAt(p)
                            var off = 2 * r * illum
                            var waxing = p < 0.5
                            var southern = true

                            ctx.save()
                            ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.clip()
                            ctx.fillStyle = win.c("surface_container", "#121318")
                            ctx.fillRect(0, 0, width, height)
                            ctx.fillStyle = win.c("on_surface", "#e6ebff")
                            ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.fill()
                            ctx.fillStyle = win.c("surface_container", "#121318")
                            ctx.beginPath()
                            ctx.arc(cx + ((waxing === southern) ? off : -off), cy, r, 0, Math.PI * 2)
                            ctx.fill()
                            ctx.restore()

                            ctx.strokeStyle = win.withAlpha(win.c("on_surface_variant", "#9f9fa9"), 0.5)
                            ctx.lineWidth = 1
                            ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.stroke()
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: "MOON · " + Math.round(win.moonIllumAt(win.moonPhaseAt(win.moonNow)) * 100) + "% LIT"
                            color: win.c("on_surface_variant", "#7f8bb3")
                            font.pixelSize: 12; font.letterSpacing: 1
                        }
                        Text {
                            text: win.moonNameAt(win.moonPhaseAt(win.moonNow))
                            color: win.c("on_surface", "#e6ebff")
                            font.pixelSize: 16; font.bold: true
                        }
                    }
                }
            }

            Canvas {
                id: tideCv
                Layout.fillWidth: true
                Layout.fillHeight: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) win.hideTooltip()
                        else win.showTooltipAt(2, mouse.x, width)
                    }
                    onDoubleClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            win.hideTooltip()
                            win.today()
                        }
                    }
                }
                Connections { target: win; function onDTideChanged() { tideCv.requestPaint() } }
                Connections { target: win; function onDmsChanged() { tideCv.requestPaint() } }
                Connections {
                    target: win
                    function onTooltipOnChanged() { tideCv.requestPaint() }
                    function onTooltipGraphChanged() { tideCv.requestPaint() }
                    function onTooltipHourChanged() { tideCv.requestPaint() }
                }
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var D = win.dTide
                    if (!D) return

                    var L = 8, R = 8, T = 26, B = 8
                    var pw = width - L - R, ph = height - T - B
                    var span = (win.overview && D.span) ? D.span : 24
                    var vs = D.points.map(function (p) { return p[1] })
                    var dataLo = Math.min.apply(null, vs)
                    var dataHi = Math.max.apply(null, vs)
                    var lo = (D.yearLo === undefined || D.yearLo === null) ? dataLo - 0.15 : D.yearLo
                    var hi = (D.yearHi === undefined || D.yearHi === null) ? dataHi + 0.15 : D.yearHi
                    lo = Math.min(lo, dataLo - 0.05)
                    hi = Math.max(hi, dataHi + 0.05)
                    function X(h) { var f = h / span; if (win.rtl) f = 1 - f; return L + f * pw }
                    function Y(v) { return T + (1 - (v - lo) / (hi - lo)) * ph }

                    var colAccent = win.c("primary", "#19b5e6")
                    var colOnSurface = win.c("on_surface", "#c8c6ce")
                    var colOnSurfaceVar = win.c("on_surface_variant", "#9f9fa9")
                    var colSurface = win.c("surface_container", "#121318")
                    var tideHeat = ctx.createLinearGradient(0, Y(hi), 0, Y(lo))
                    tideHeat.addColorStop(0, "#ef4444")
                    tideHeat.addColorStop(0.5, "#facc15")
                    tideHeat.addColorStop(1, "#22c55e")

                    ctx.fillStyle = win.graphDayBg()
                    ctx.fillRect(L, T, pw, ph)
                    ctx.fillStyle = win.graphNightBg()
                    D.nights.forEach(function (n) {
                        var a = Math.max(0, Math.min(span, n[0])), b = Math.max(0, Math.min(span, n[1]))
                        if (b <= a) return
                        var x1 = X(a), x2 = X(b)
                        ctx.fillRect(Math.min(x1, x2), T, Math.abs(x2 - x1), ph)
                    })

                    win.paintTimeGrid(ctx, X, T, ph, span, win.overview ? D.days : null, colOnSurfaceVar, colOnSurfaceVar)

                    for (var m = Math.ceil(lo); m <= hi; m++) {
                        ctx.strokeStyle = win.withAlpha(colOnSurfaceVar, 0.25)
                        ctx.beginPath(); ctx.moveTo(L, Y(m)); ctx.lineTo(L + pw, Y(m)); ctx.stroke()
                    }

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
                    ctx.globalAlpha = 0; ctx.fillStyle = tideHeat; ctx.fill(); ctx.globalAlpha = 1
                    ctx.beginPath(); trace()
                    ctx.lineJoin = "round"; ctx.lineCap = "round"
                    ctx.strokeStyle = tideHeat; ctx.lineWidth = 3; ctx.stroke()
                    ctx.restore()

                    ctx.font = "12px monospace"; ctx.textAlign = "left"
                    for (var mm = Math.ceil(lo); mm <= hi; mm++) {
                        var ly = Math.max(T + 12, Math.min(T + ph - 4, Y(mm) + 4))
                        var label = mm + " m"
                        var tw = ctx.measureText(label).width
                        ctx.fillStyle = win.withAlpha(colSurface, 0.78)
                        ctx.fillRect(L + 2, ly - 11, tw + 6, 14)
                        ctx.fillStyle = colOnSurfaceVar
                        ctx.fillText(label, L + 5, ly)
                    }

                    if (D.now >= 0 && D.now <= 24) {
                        var nx = X(D.now), ny = Y(D.current)
                        ctx.strokeStyle = win.withAlpha("#ff2d95", 0.7); ctx.lineWidth = 2
                        ctx.beginPath(); ctx.moveTo(nx, T); ctx.lineTo(nx, T + ph); ctx.stroke()
                        ctx.fillStyle = "#ff2d95"; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 3
                        ctx.beginPath(); ctx.arc(nx, ny, 6, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                    }

                    D.extrema.forEach(function (e) {
                        if (e.h < 0 || e.h > span) return
                        var ex = X(e.h), ey = Y(e.v)
                        ctx.fillStyle = colAccent
                        ctx.beginPath(); ctx.arc(ex, ey, 4, 0, Math.PI * 2); ctx.fill()
                        if (win.overview) return
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

                    if (win.tooltipOn && win.tooltipGraph === 2) {
                        var hour = Math.max(0, Math.min(span, win.tooltipHour))
                        var di = win.nearestIdx(D.points, hour)
                        if (di >= 0) {
                            var ph0 = D.points[di][0]
                            var gx = X(ph0)
                            var tipX = gx
                            var val = D.points[di][1]
                            var prev = D.points[Math.max(0, di - 1)][1]
                            var next = D.points[Math.min(D.points.length - 1, di + 1)][1]
                            var trend = next >= prev ? "RISING" : "FALLING"

                            ctx.save()
                            ctx.strokeStyle = win.withAlpha(colOnSurface, 0.35); ctx.lineWidth = 1
                            ctx.setLineDash([4, 4])
                            ctx.beginPath(); ctx.moveTo(gx, T); ctx.lineTo(gx, T + ph); ctx.stroke()
                            ctx.setLineDash([])
                            ctx.fillStyle = colAccent; ctx.strokeStyle = colOnSurface; ctx.lineWidth = 2
                            ctx.beginPath(); ctx.arc(gx, Y(val), 4, 0, Math.PI * 2); ctx.fill(); ctx.stroke()
                            ctx.restore()

                            win.paintHoverTooltip(ctx, tipX,
                                win.hoverTimeText(D, ph0),
                                ["HEIGHT " + val.toFixed(2) + " m",
                                 "TREND  " + trend],
                                L, T, pw, ph)
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.leftMargin: 8
            Layout.rightMargin: 8

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: 10
                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            anchors.fill: parent
                            radius: 0
                            color: win.overview
                                ? win.withAlpha(win.c("primary", "#19b5e6"), 0.28)
                                : (index === win.dayOffset
                                    ? win.c("primary", "#19b5e6")
                                    : win.withAlpha(win.c("on_surface_variant", "#9f9fa9"), 0.16))
                        }
                        Text {
                            anchors.centerIn: parent
                            text: win.dayShort(index)
                            color: (!win.overview && index === win.dayOffset)
                                ? win.c("on_primary", "#0e1220")
                                : win.c("on_surface_variant", "#9f9fa9")
                            font.pixelSize: 18
                            font.letterSpacing: 0.3
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                property real pressX: 0
                property bool dragging: false
                onPressed: (mouse) => { pressX = mouse.x; dragging = false }
                onPositionChanged: (mouse) => {
                    if (!pressed) return
                    if (!dragging && Math.abs(mouse.x - pressX) > 4) dragging = true
                    if (dragging) win.gotoDay(win.dayAt(mouse.x, width))
                }
                onReleased: (mouse) => {
                    if (!dragging) {
                        var d = win.dayAt(mouse.x, width)
                        if (!win.overview && d === win.dayOffset) win.toggleOverview()
                        else win.gotoDay(d)
                    }
                    dragging = false
                }
                onWheel: (wheel) => { win.handleWheel(wheel); wheel.accepted = true }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: win.helpVisible
        color: win.withAlpha(win.c("background", "#0e1220"), 0.9)
        z: 100

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: win.helpVisible = false
        }

        Rectangle {
            id: helpPanel
            anchors.centerIn: parent
            width: Math.min(520, win.width - 32)
            height: helpCol.implicitHeight + 48
            radius: 8
            color: win.c("surface_container", "#121318")
            border.width: 1
            border.color: win.withAlpha(win.c("on_surface_variant", "#9f9fa9"), 0.3)

            ColumnLayout {
                id: helpCol
                anchors.fill: parent
                anchors.margins: 24
                spacing: 10

                Text {
                    text: "KEYBINDS"
                    color: win.c("primary", "#19b5e6")
                    font.pixelSize: 14; font.letterSpacing: 2; font.bold: true
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: win.withAlpha(win.c("on_surface_variant", "#9f9fa9"), 0.2)
                }
                Repeater {
                    model: [
                        { k: "← / → / scroll", d: "previous / next day" },
                        { k: "n / N", d: "next / previous day" },
                        { k: "gg / G", d: "first / last day" },
                        { k: "Home", d: "jump to today" },
                        { k: "Space", d: "toggle 10-day overview" },
                        { k: "1–9 / 0", d: "jump to day 1–9 / day 10" },
                        { k: "left click", d: "show tooltip at cursor" },
                        { k: "right click", d: "hide tooltip" },
                        { k: "i", d: "toggle tooltip" },
                        { k: "h / l", d: "move tooltip left / right" },
                        { k: "j / k", d: "move tooltip down / up a graph" },
                        { k: "r", d: "refresh data" },
                        { k: "/ or ?", d: "show / hide keybinds" },
                        { k: "Esc", d: "close keybinds" },
                        { k: "q", d: "quit" }
                    ]
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 18
                        Text {
                            text: modelData.k
                            Layout.preferredWidth: 150
                            color: win.c("on_surface", "#e6ebff")
                            font.pixelSize: 14; font.bold: true
                        }
                        Text {
                            text: modelData.d
                            Layout.fillWidth: true
                            color: win.c("on_surface_variant", "#9f9fa9")
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
}
