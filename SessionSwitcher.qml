import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias iconSource: icon.source
    property alias selectedIndex: sessionCombo.currentIndex

    height: 40
    width: 140
    clip: true

    scale: comboHover.hovered || sessionCombo.popup.visible ? 1.1 : 1.0
    transformOrigin: Item.Center

    Behavior on scale {
        NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
    }

    Row {
        anchors.centerIn: parent

        // Icon container
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            id: iconRect
            height: root.height - 15
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
            id: spacer
            width: 9
            height: 1
        }

        // Session ComboBox
        ComboBox {
            id: sessionCombo
            width: root.width - iconRect.width - spacer.width
            height: root.height
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex

            onActivated: function(index) {
                currentIndex = index
            }

            HoverHandler {
                id: comboHover
                cursorShape: Qt.PointingHandCursor
            }

            // transparent background
            background: Rectangle {
                color: "transparent"
            }

            // text and arrow
            contentItem: Item {
                implicitWidth: sessionCombo.availableWidth

                Text {
                    id: arrowText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: sessionCombo.popup.visible ? "▲" : "▼"
                    color: config.primaryTextColor
                    font.pointSize: 9
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: arrowText.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: sessionCombo.displayText
                    color: config.primaryTextColor
                    font.pointSize: 11
                    elide: Text.ElideRight
                }
            }

            // popup
            popup: Popup {
                y: sessionCombo.height + 5
                width: Math.max(sessionCombo.width, 160)
                implicitHeight: contentItem.implicitHeight
                padding: 6

                background: Rectangle {
                    color: config.cardBackgroundColor
                    border.color: config.borderColor
                    border.width: 2
                    radius: 18
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: sessionCombo.delegateModel
                    currentIndex: sessionCombo.highlightedIndex
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentHeight > height
                }
            }
            
            // popup item delegate
            delegate: ItemDelegate {
                id: delegateItem
                width: ListView.view.width
                height: 34
                highlighted: sessionCombo.highlightedIndex === index

                readonly property bool isCurrent: sessionCombo.currentIndex === index

                background: Rectangle {
                    radius: 12
                    color: delegateItem.highlighted ? config.borderColor : "transparent"
                }

                contentItem: Text {
                    text: model.name
                    color: config.primaryTextColor
                    font.pointSize: 10
                    font.bold: delegateItem.isCurrent
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                    rightPadding: 12
                }
            }

            // hide original arrow
            indicator: Item {}
        }
    }
}