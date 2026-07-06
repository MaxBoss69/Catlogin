// QuickAction.qml
import QtQuick

Item {
    id: root

    property alias iconSource: icon.source
    property alias label: labelText.text
    signal clicked()

    height: 40
    width: 90

    scale: mouseArea.containsMouse ? 1.1 : 1.0
    transformOrigin: Item.Center

    Behavior on scale {
        NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Row {
        anchors.centerIn: parent

        // Icon container
        Rectangle {
            height: parent.height
            width: height
            color: "transparent"

            // Icon
            Image {
                id: icon
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
            }
        }

        // Spacer
        Item {
            width: 9
            height: 1
        }

        // Label
        Text {
            id: labelText
            color: config.primaryTextColor
            font.pointSize: 11
        }
    }
}