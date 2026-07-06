import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property alias echoMode: field.echoMode
    property alias iconSource: icon.source
    property alias field: field
    property alias fieldFocus: field.focus

    signal accepted()

    width: parent.width
    height: 45
    radius: height / 2

    border.color: config.borderColor
    color: config.backgroundColor

    Row {
        width: parent.width
        height: parent.height

        // left border - SVG spacer
        Item {
            height: 1
            width: parent.height / 3
        }

        // icon container
        Item {

            anchors.top: parent.top
            anchors.topMargin: parent.height / 4

            height: parent.height / 2
            width: height

            // icon
            Image {
                id: icon
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
            }
        }

        // icon - input spacer
        Item {
            height: 1
            width: 5
        }

        // input
        TextField {

            anchors.top: parent.top
            anchors.topMargin: 0

            id: field
            width: parent.width
            height: parent.height

            color: config.primaryTextColor
            placeholderTextColor: config.placeholderTextColor

            background: Rectangle {
                color: "transparent"
            }

            onAccepted: root.accepted()
        }
    }
}