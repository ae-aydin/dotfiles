// Flexoki Dark bar: workspaces | clock | updates, bluetooth, vpn, volume, cpu, network
// bg #100F0F, bg+ #1C1B1A, border #282726, fg #CECDC3, muted #878580, accent #DA702C
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Widgets

ShellRoot {
  // ---- Flexoki Dark theme: single source of truth (same file = instant reload) ----
  QtObject {
    id: theme
    property color bg: "#100F0F"
    property color bgHover: "#1C1B1A"
    property color bgPress: "#282726"
    property color border: "#282726"
    property color fg: "#CECDC3"
    property color fgBright: "#E6E4D9"
    property color muted: "#878580"
    property color accent: "#DA702C"
    property int barHeight: 34
    property int btnWidth: 28
    property int sideMargin: 8
    property int wsSpacing: 3
    property int traySpacing: 6
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 15
    property int iconSize: 16
  }

  // ---- hover popup shared by the bar buttons: a title line plus muted detail lines ----
  component BarPopup: PopupWindow {
    id: popup
    required property var t       // theme (inline components can't see outer ids)
    property Item target
    property bool shown
    property string title
    property color titleColor: t.fg
    property var details: []
    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    visible: shown
    color: "transparent"
    implicitWidth: info.implicitWidth + 24
    implicitHeight: info.implicitHeight + 16
    Rectangle {
      anchors.fill: parent
      color: popup.t.bg
      border { width: 1; color: popup.t.border }
      Column {
        id: info
        anchors.centerIn: parent
        spacing: 2
        Text {
          color: popup.titleColor
          font { family: popup.t.fontFamily; pixelSize: 13 }
          text: popup.title
        }
        Repeater {
          model: popup.details.filter(Boolean)
          Text {
            required property string modelData
            color: popup.t.muted
            font { family: popup.t.fontFamily; pixelSize: 12 }
            text: modelData
          }
        }
      }
    }
  }

  // keeps the default sink's volume/mute properties live for the icon and popup
  PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

  // ---- Mullvad state, shared by every bar: one status read per change event ----
  Scope {
    id: mullvad
    property string state: "disconnected"
    property string place: ""     // "Country, City" of the exit
    property string server: ""    // relay hostname, empty when disconnected
    property string ip: ""
    function refresh() { statusProc.running = true }

    Process {
      id: statusProc
      command: ["mullvad", "status", "-j"]
      stdout: StdioCollector {
        onStreamFinished: {
          try {
            const status = JSON.parse(text);
            const loc = status.details?.location ?? {};
            mullvad.state = status.state;
            mullvad.place = [loc.country, loc.city].filter(Boolean).join(", ");
            mullvad.server = loc.hostname ?? "";
            mullvad.ip = loc.ipv4 ?? "";
          } catch (e) {}
        }
      }
    }
    // prints a line on every tunnel change; restart it if the daemon goes away
    Process {
      id: listenProc
      command: ["mullvad", "status", "-j", "listen"]
      running: true
      stdout: SplitParser { onRead: _ => mullvad.refresh() }
      onRunningChanged: if (!running) relisten.start()
    }
    Timer { id: relisten; interval: 5000; onTriggered: { listenProc.running = true; mullvad.refresh() } }
    Component.onCompleted: refresh()
  }

  // ---- cpu/ram/gpu and network details, only read while their popup is open ----
  Scope {
    id: stats
    property bool watching: false
    property string cpu: ""
    property string mem: ""
    property string gpu: ""
    Process {
      id: statsProc
      command: [Quickshell.shellPath("scripts/stats.sh")]
      stdout: SplitParser {
        onRead: line => {
          const f = line.split(" ");
          if (f[0] === "cpu") stats.cpu = "CPU " + f[1] + "%";
          else if (f[0] === "mem") stats.mem = "RAM " + f[1] + " / " + f[2] + " GiB";
          else if (f[0] === "gpu") stats.gpu = "GPU " + f[1] + "% · " + f[2] + "°C";
        }
      }
    }
    Timer { interval: 2000; running: stats.watching; repeat: true; triggeredOnStart: true; onTriggered: statsProc.running = true }
  }
  Scope {
    id: net
    property string title: ""
    property string detail: ""
    property string dns: ""
    function refresh() { netProc.running = true }
    Process {
      id: netProc
      command: [Quickshell.shellPath("scripts/network.sh")]
      stdout: StdioCollector {
        onStreamFinished: {
          const [type, conn, dev, ip, dns] = text.trim().split("|");
          net.title = type ? (type === "wifi" ? "Wi-Fi · " : "Wired · ") + conn : "Disconnected";
          net.detail = type ? dev + " · " + ip : "";
          // "1.1.1.1#cloudflare-dns.com" -> "DNS cloudflare-dns.com (TLS)"
          net.dns = dns ? "DNS " + (dns.includes("#") ? dns.split("#")[1] + " (TLS)" : dns) : "";
        }
      }
    }
  }

  // ---- pending dnf/flatpak updates: checked hourly, on hover, and after the upgrade terminal closes ----
  Scope {
    id: updates
    property int dnf: 0
    property int flatpak: 0
    property string driverMismatch: ""   // host driver version when the flatpak GL runtime doesn't match
    readonly property int total: dnf + flatpak
    readonly property bool attention: total > 0 || driverMismatch !== ""
    function refresh() { if (!updatesProc.running) updatesProc.running = true }
    function upgrade() { if (!upgradeProc.running) upgradeProc.running = true }
    Process {
      id: updatesProc
      command: [Quickshell.shellPath("scripts/updates.sh")]
      stdout: StdioCollector {
        onStreamFinished: {
          const [dnf, flatpak, driver] = text.trim().split("|");
          updates.dnf = parseInt(dnf) || 0;
          updates.flatpak = parseInt(flatpak) || 0;
          updates.driverMismatch = driver ?? "";
        }
      }
    }
    // the terminal is a child process, so its exit means the upgrade window was closed
    Process {
      id: upgradeProc
      command: ["ghostty", "--gtk-single-instance=false", "--confirm-close-surface=false", "-e", Quickshell.shellPath("scripts/upgrade.sh")]
      onExited: updates.refresh()
    }
    // first check waits a minute so login isn't busy with it
    Timer { interval: 60000; running: true; onTriggered: updates.refresh() }
    Timer { interval: 3600000; running: true; repeat: true; onTriggered: updates.refresh() }
  }

  // per-screen bar via Variants

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors { top: true; left: true; right: true }
      implicitHeight: theme.barHeight
      color: theme.bg

      // bottom hairline
      Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: theme.border
      }

      // --- center: clock, centred on the whole bar; hover shows the full date ---
      Text {
        id: clock
        anchors.centerIn: parent
        property date now: new Date()
        color: theme.fg
        font { family: theme.fontFamily; pixelSize: theme.fontSize }
        text: Qt.formatDateTime(now, "dddd hh:mm")
        Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.now = new Date() }
        MouseArea { id: ma_clock; anchors.fill: parent; hoverEnabled: true }
        BarPopup {
          t: theme
          target: clock
          shown: ma_clock.containsMouse
          title: Qt.formatDate(clock.now, "dddd, d MMMM yyyy")
          details: {
            // ISO week: the Thursday of this week decides which year/week it belongs to
            const d = new Date(Date.UTC(clock.now.getFullYear(), clock.now.getMonth(), clock.now.getDate()));
            d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
            const week = Math.ceil(((d - new Date(Date.UTC(d.getUTCFullYear(), 0, 1))) / 86400000 + 1) / 7);
            return ["Week " + week];
          }
        }
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: theme.sideMargin
        anchors.rightMargin: theme.sideMargin
        spacing: theme.wsSpacing

        // --- left: workspaces for this monitor ---
        Row {
          spacing: theme.wsSpacing
          Repeater {
            // Hyprland workspaces 1-5 on DP-6, 6-8 on HDMI-A-2 (matches workspaces.lua)
            model: (Hyprland.monitorFor(screen)?.name === "HDMI-A-2") ? [6, 7, 8] : [1, 2, 3, 4, 5]
            delegate: Item {
              property int wsId: modelData
              // active = shown on *this* monitor, so both bars mark their own workspace
              property bool active: Hyprland.monitorFor(screen)?.activeWorkspace?.id === wsId
              property bool empty: {
                const ws = Hyprland.workspaces.values.find(w => w.id === wsId);
                return !ws || ws.toplevels.values.length === 0;
              }
              width: theme.btnWidth; height: theme.barHeight
              Rectangle {
                anchors.fill: parent
                color: ma_ws.pressed ? theme.bgPress : (ma_ws.containsMouse || active) ? theme.bgHover : "transparent"
              }
              Text {
                anchors.centerIn: parent
                text: active ? "󰝤" : modelData
                color: (empty && !active) ? theme.muted : theme.fg
                font { family: theme.fontFamily; pixelSize: theme.fontSize }
              }
              MouseArea {
                id: ma_ws
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({workspace = \"" + wsId + "\"})"])
              }
            }
          }
        }

        // --- focused app: icon + name from its desktop entry, only on the monitor that has focus ---
        Row {
          id: focusedApp
          readonly property var toplevel: Hyprland.activeToplevel
          // native windows report a Wayland app id; XWayland ones only have Hyprland's class
          readonly property string appId: toplevel?.wayland?.appId ?? toplevel?.lastIpcObject?.class ?? ""
          // desktop entries load in the background; touching the list re-runs the lookup once they're in
          readonly property var entry: DesktopEntries.applications.values.length && appId ? DesktopEntries.heuristicLookup(appId) : null
          Layout.leftMargin: 10
          spacing: 7
          visible: Hyprland.focusedMonitor === Hyprland.monitorFor(screen) && appId !== ""
          IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 16
            source: focusedApp.entry?.icon ? Quickshell.iconPath(focusedApp.entry.icon, true) : ""
            visible: source != ""
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: focusedApp.entry?.name || focusedApp.appId
            color: theme.muted
            font { family: theme.fontFamily; pixelSize: 13 }
          }
        }

        Item { Layout.fillWidth: true }

        // --- right: icon buttons, each with a hover popup ---
        // terminal tools get their own ghostty process so --confirm-close-surface applies
        Row {
          spacing: theme.traySpacing
          // updates: orange when something is pending; left=upgrade in a terminal right=check again
          Item {
            id: updButton
            width: theme.btnWidth; height: theme.barHeight
            Rectangle {
              anchors.fill: parent
              color: ma_upd.pressed ? theme.bgPress : ma_upd.containsMouse ? theme.bgHover : "transparent"
            }
            Text {
              anchors.centerIn: parent
              color: updates.attention ? theme.accent : (ma_upd.containsMouse ? theme.fgBright : theme.muted)
              font { family: theme.fontFamily; pixelSize: theme.iconSize }
              text: "󰚰"
            }
            MouseArea {
              id: ma_upd
              anchors.fill: parent
              hoverEnabled: true
              onContainsMouseChanged: if (containsMouse) updates.refresh()
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) updates.refresh();
                else updates.upgrade();
              }
            }
            BarPopup {
              t: theme
              target: updButton
              shown: ma_upd.containsMouse
              titleColor: updates.attention ? theme.accent : theme.fg
              title: updates.total > 0 ? updates.total + (updates.total === 1 ? " update" : " updates") : "Up to date"
              details: [
                updates.dnf > 0 ? "dnf " + updates.dnf : "",
                updates.flatpak > 0 ? "flatpak " + updates.flatpak : "",
                updates.driverMismatch ? "Flatpak NVIDIA runtime missing for " + updates.driverMismatch : ""
              ]
            }
          }
          // bluetooth: left=power toggle right=blueman; hover lists connected devices
          Item {
            id: btButton
            readonly property var adapter: Bluetooth.defaultAdapter
            readonly property var connected: Bluetooth.devices.values.filter(d => d.connected)
            visible: adapter !== null
            width: theme.btnWidth; height: theme.barHeight
            Rectangle {
              anchors.fill: parent
              color: ma_bt.pressed ? theme.bgPress : ma_bt.containsMouse ? theme.bgHover : "transparent"
            }
            Text {
              anchors.centerIn: parent
              color: btButton.connected.length > 0 || ma_bt.containsMouse ? theme.fg : theme.muted
              font { family: theme.fontFamily; pixelSize: theme.iconSize }
              text: !btButton.adapter?.enabled ? "󰂲"
                  : btButton.connected.length > 0 ? "󰂱" : "󰂯"
            }
            MouseArea {
              id: ma_bt
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) Quickshell.execDetached(["blueman-manager"]);
                else if (btButton.adapter) btButton.adapter.enabled = !btButton.adapter.enabled;
              }
            }
            BarPopup {
              t: theme
              target: btButton
              shown: ma_bt.containsMouse
              title: !btButton.adapter?.enabled ? "Bluetooth off"
                   : btButton.connected.length > 0 ? "Bluetooth" : "Bluetooth · no devices"
              details: btButton.connected.map(d => d.name + (d.batteryAvailable ? " · " + Math.round(d.battery * 100) + "%" : ""))
            }
          }
          // mullvad: shield is orange while connected; left=toggle right=app
          Item {
            id: vpnButton
            width: theme.btnWidth; height: theme.barHeight
            Rectangle {
              anchors.fill: parent
              color: ma_vpn.pressed ? theme.bgPress : ma_vpn.containsMouse ? theme.bgHover : "transparent"
            }
            Text {
              anchors.centerIn: parent
              color: mullvad.state === "connected" ? theme.accent : (ma_vpn.containsMouse ? theme.fgBright : theme.muted)
              font { family: theme.fontFamily; pixelSize: theme.iconSize }
              text: mullvad.state === "disconnected" ? "󰦞" : "󰕥"
            }
            MouseArea {
              id: ma_vpn
              anchors.fill: parent
              hoverEnabled: true
              onContainsMouseChanged: if (containsMouse) mullvad.refresh()
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                // the app isn't on PATH, it lives in /opt
                if (mouse.button === Qt.RightButton) Quickshell.execDetached(["/opt/Mullvad VPN/mullvad-vpn"]);
                else Quickshell.execDetached(["mullvad", mullvad.state === "disconnected" ? "connect" : "disconnect"]);
              }
            }
            // hover: where the tunnel exits
            BarPopup {
              t: theme
              target: vpnButton
              shown: ma_vpn.containsMouse
              titleColor: mullvad.state === "connected" ? theme.accent : theme.fg
              // exit details only while connected; your real IP/location never shows on screen
              readonly property bool tunnelled: mullvad.state === "connected"
              title: tunnelled ? "Connected" + (mullvad.place ? " · " + mullvad.place : "")
                   : mullvad.state === "connecting" ? "Connecting…" : "Not connected"
              details: tunnelled ? [[mullvad.server, mullvad.ip].filter(Boolean).join(" · ")] : []
            }
          }
          // volume: icon reflects level, left=wiremix right=easyeffects
          Item {
            id: volButton
            readonly property var sink: Pipewire.defaultAudioSink
            width: theme.btnWidth; height: theme.barHeight
            Rectangle {
              anchors.fill: parent
              color: ma_vol.pressed ? theme.bgPress : ma_vol.containsMouse ? theme.bgHover : "transparent"
            }
            Text {
              anchors.centerIn: parent
              color: ma_vol.containsMouse ? theme.fgBright : theme.fg
              font { family: theme.fontFamily; pixelSize: theme.iconSize }
              text: {
                const sink = volButton.sink;
                if (!sink || !sink.audio) return "";
                if (sink.audio.muted) return "";
                return sink.audio.volume > 0.5 ? "" : "";
              }
            }
            MouseArea {
              id: ma_vol
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) Quickshell.execDetached(["easyeffects"]);
                else Quickshell.execDetached(["ghostty", "--gtk-single-instance=false", "--confirm-close-surface=false", "-e", "wiremix"]);
              }
            }
            BarPopup {
              t: theme
              target: volButton
              shown: ma_vol.containsMouse
              title: !volButton.sink?.audio ? "No output"
                   : volButton.sink.audio.muted ? "Muted" : "Volume " + Math.round(volButton.sink.audio.volume * 100) + "%"
              details: [volButton.sink?.description ?? ""]
            }
          }
          // cpu: left=btop right=nvtop
          Item {
            id: cpuButton
            width: theme.btnWidth; height: theme.barHeight
            Rectangle {
              anchors.fill: parent
              color: ma_cpu.pressed ? theme.bgPress : ma_cpu.containsMouse ? theme.bgHover : "transparent"
            }
            Text {
              anchors.centerIn: parent
              color: ma_cpu.containsMouse ? theme.fgBright : theme.fg
              font { family: theme.fontFamily; pixelSize: theme.iconSize }
              text: ""
            }
            MouseArea {
              id: ma_cpu
              anchors.fill: parent
              hoverEnabled: true
              onContainsMouseChanged: stats.watching = containsMouse
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: mouse => {
                if (mouse.button === Qt.RightButton) Quickshell.execDetached(["ghostty", "--gtk-single-instance=false", "--confirm-close-surface=false", "-e", "nvtop"]);
                else Quickshell.execDetached(["ghostty", "--gtk-single-instance=false", "--confirm-close-surface=false", "-e", "btop"]);
              }
            }
            BarPopup {
              t: theme
              target: cpuButton
              shown: ma_cpu.containsMouse
              title: stats.cpu || "CPU …"
              details: [stats.mem, stats.gpu]
            }
          }
          // network: left=nmtui, recoloured via NEWT_COLORS to sit on the Flexoki terminal palette
          Item {
            id: netButton
            width: theme.btnWidth; height: theme.barHeight
            Rectangle {
              anchors.fill: parent
              color: ma_net.pressed ? theme.bgPress : ma_net.containsMouse ? theme.bgHover : "transparent"
            }
            Text {
              anchors.centerIn: parent
              color: ma_net.containsMouse ? theme.fgBright : theme.fg
              font { family: theme.fontFamily; pixelSize: theme.iconSize }
              text: "󰈀"
            }
            MouseArea {
              id: ma_net
              anchors.fill: parent
              hoverEnabled: true
              onContainsMouseChanged: if (containsMouse) net.refresh()
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: Quickshell.execDetached(["env", "NEWT_COLORS=root=white,black;roottext=white,black;helpline=white,black;window=white,black;border=gray,black;shadow=black,black;title=white,black;textbox=white,black;acttextbox=black,lightgray;label=white,black;listbox=white,black;actlistbox=black,lightgray;sellistbox=white,black;actsellistbox=black,lightgray;button=white,gray;actbutton=black,lightgray;compactbutton=white,black;checkbox=white,black;actcheckbox=black,lightgray;entry=white,gray;disentry=gray,black;emptyscale=,gray;fullscale=,lightgray", "ghostty", "--gtk-single-instance=false", "--confirm-close-surface=false", "--class=qs.nmtui", "-e", "nmtui"])
            }
            BarPopup {
              t: theme
              target: netButton
              shown: ma_net.containsMouse
              title: net.title || "Network …"
              details: [net.detail, net.dns]
            }
          }
        }
      }
    }
  }
}
