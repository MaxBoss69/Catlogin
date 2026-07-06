import QtQuick
import QtQuick.Effects
import QtQuick.Controls

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.backgroundColor

    FontLoader {
        id: dayFont
        source: config.fancyDateFont
    }
    
    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        visible: source != ""
    }

    WaveBar {

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 400

        width: parent.width
        height: 100
    }

    Component.onCompleted: passwordField.forceActiveFocus()

    // card
    Rectangle {

        visible: true

        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 200

        width: 450
        height: 590

        color: config.cardBackgroundColor
        border.color: config.borderColor
        border.width: 2
        radius: 35

        // vertical layout
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0


            // Top Border - Avatar spacer. width needs at least 1. will be skipped if 0
            Item { 
                width: 1
                height: 50
            }

            // avatar container
            Rectangle {

                anchors.horizontalCenter: parent.horizontalCenter

                width: 125
                height: width
                radius: width / 2

                border.color: config.borderColor
                border.width: 1
                clip: true
        

                // avatar
                Image {

                    anchors.fill: parent
                    source: config.avatar

                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }
                
            }

            // Avatar - Date spacer. width needs at least 1. will be skipped if 0
            Item { 
                width: 1
                height: 20
            }

            // positioning the wekkday and date closer together
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: -20


                // weekday
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    font.family: dayFont.name
                    font.pointSize: 100
                    color: config.primaryTextColor

                    text: {
                            var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                            return days[new Date().getDay()]
                    }
                }

                // date container
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter

                    height: 35
                    width: 80

                    radius: height/2
                    color: config.primaryTextColor

                    // date
                    Text {
                        id:date

                        anchors.centerIn: parent

                        font.pointSize: 12
                        font.weight: Font.DemiBold
                        color: config.secondaryTextColor

                        // day / month
                        text: {
                            var now = new Date()
                            var day = String(now.getDate()).padStart(2, "0")
                            var month = String(now.getMonth() + 1).padStart(2, "0")
                            return day + " / " + month
                        }
                    }
                }

            }

            // Date - Username spacer. width needs at least 1. will be skipped if 0
            Item { 
                width: 1
                height: 40
            }

            InputField {
                id: usernameField
                iconSource: config.usernameIcon
                placeholderText: "Username"
                text: userModel.lastUser
                onAccepted: passwordField.forceActiveFocus()
                fieldFocus: false
            }

            // Username - Password spacer. width needs at least 1. will be skipped if 0
            Item { 
                width: 1
                height: 15
            }

            InputField {
                id: passwordField
                iconSource: config.passwordIcon
                placeholderText: "Password"
                echoMode: TextInput.Password
                onAccepted: loginButton.clicked()
                fieldFocus: true
            }

            // Password - Login button spacer. width needs at least 1. will be skipped if 0
            Item { 
                width: 1
                height: 20
            }

            // Login Button
            Button {
                id: loginButton

                width: parent.width
                height: 45

                // Text
                contentItem: Text {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: "Login"

                    color: config.secondaryTextColor
                    font.bold: true
                    font.pointSize: 12

                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                // background gradiant
                background: Rectangle {
                    radius: 25

                    scale: loginButton.hovered ? (loginButton.pressed ? 1.05 : 1.03) : 1.0

                    Behavior on scale { NumberAnimation { duration: 80 } }

                    gradient: Gradient {
                        orientation: Gradient.Horizontal

                        GradientStop { position: 0; color: config.red }
                        GradientStop { position: 0.166*1; color: config.orange }
                        GradientStop { position: 0.166*2; color: config.yellow }
                        GradientStop { position: 0.166*3; color: config.green }
                        GradientStop { position: 0.166*4; color: config.blue }
                        GradientStop { position: 1.0; color: config.purple }
                    }
                }

                onClicked: {

                    sddm.login(
                        usernameField.text,
                        passwordField.text,
                        sessionModel.lastIndex
                    )
                }
            }

            // Login Button - error text spacer. width needs at least 1. will be skipped if 0
            Item { 
                width: 1
                height: 10
            }

            // error text
            Text {
                id: errorText
                text: "Error haja"
                color: config.red
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    
    }

    // quick actions
    Row {

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: card.bottom
        anchors.topMargin: 60

        spacing: 30

        QuickAction {
            iconSource: config.sleepIcon
            label: "Sleep"
            onClicked: sddm.suspend()
        }
        
        QuickAction {
            iconSource: config.restartIcon
            label: "Restart"
            onClicked: sddm.reboot()
        }
        
        QuickAction {
            iconSource: config.shutdownIcon
            label: "Shut Down"
            onClicked: sddm.powerOff()
        }

    }

    // sddm login stuff
    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Login failed"
            errorText.visible = true
            passwordField.text = ""
        }
    }
}