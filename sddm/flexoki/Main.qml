// Minimal Flexoki Dark login: clock, user, password; click the session name to cycle sessions
import QtQuick

Rectangle {
    id: root
    color: "#100F0F"

    readonly property color fg: "#CECDC3"
    readonly property color muted: "#878580"
    readonly property color faint: "#575653"
    readonly property color ui: "#282726"
    readonly property color accent: "#DA702C"
    readonly property color error: "#D14D41"
    readonly property string font: "Noto Sans Mono"

    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    // sessionModel/userModel only expose names through delegates, so mirror them here
    Instantiator { id: sessions; model: sessionModel; delegate: QtObject { property string name: model.name } }
    Instantiator { id: users; model: userModel; delegate: QtObject { property string name: model.name } }

    function login() {
        message.text = ""
        sddm.login(user.text, password.text, sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            message.text = "wrong password"
            password.forceActiveFocus()
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 14
        width: 320

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.fg
            font { family: root.font; pixelSize: 72; weight: Font.Light }
            text: Qt.formatTime(new Date(), "HH:mm")
            Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm") }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.muted
            font { family: root.font; pixelSize: 15 }
            text: Qt.formatDate(new Date(), "dddd, d MMMM")
        }

        Item { width: 1; height: 28 }

        TextInput {
            id: user
            width: parent.width
            horizontalAlignment: TextInput.AlignHCenter
            color: root.fg
            font { family: root.font; pixelSize: 15 }
            text: userModel.lastUser !== "" ? userModel.lastUser : (users.count > 0 ? users.objectAt(0).name : "")
            KeyNavigation.tab: password
            onAccepted: password.forceActiveFocus()
        }

        Rectangle {
            width: parent.width
            height: 42
            color: "transparent"
            border.width: 1
            border.color: password.activeFocus ? root.accent : root.ui

            TextInput {
                id: password
                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: root.fg
                font { family: root.font; pixelSize: 15 }
                focus: true
                clip: true
                KeyNavigation.backtab: user
                onAccepted: root.login()

                Text {
                    anchors.centerIn: parent
                    visible: password.text.length === 0
                    color: root.faint
                    font: password.font
                    text: "password"
                }
            }
        }

        Text {
            id: message
            anchors.horizontalCenter: parent.horizontalCenter
            height: 18
            color: root.error
            font { family: root.font; pixelSize: 13 }
        }
    }

    // session switch: click (or F10) to cycle through installed sessions
    Text {
        id: session
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 36 }
        color: sessionArea.containsMouse ? root.fg : root.faint
        font { family: root.font; pixelSize: 13 }
        text: sessions.count > root.sessionIndex ? sessions.objectAt(root.sessionIndex).name : ""
        MouseArea {
            id: sessionArea
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessions.count
        }
    }

    Shortcut { sequence: "F10"; onActivated: root.sessionIndex = (root.sessionIndex + 1) % sessions.count }
}
