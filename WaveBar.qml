// WaveBar.qml
import QtQuick

Item {
    id: waveContainer

    property int blockWidth: parseInt(config.waveBlockWidth)
    property int blockSpacing: parseInt(config.waveBlockSpacing)
    property real baseHeight: parseFloat(config.waveBaseHeight)
    
    // Primary wave
    property real amplitude: parseFloat(config.waveAmplitude)
    property real frequency: parseFloat(config.waveFrequency)
    property real speed: parseFloat(config.waveSpeed)
    
    // secondary wave
    property real amplitude2: parseFloat(config.waveAmplitude2)
    property real frequency2: parseFloat(config.waveFrequency2)
    property real speed2: parseFloat(config.waveSpeed2)


    property real phase: 0
    property real phase2: 0

    property var gradientStops: [
        { pos: 0,       color: config.red },
        { pos: 0.166*1, color: config.orange },
        { pos: 0.166*2, color: config.yellow },
        { pos: 0.166*3, color: config.green },
        { pos: 0.166*4, color: config.blue},
        { pos: 1.0,     color: config.purple }
    ]

    property var gradientStopsRgb: []
    property alias timerRunning: waveTimer.running

    height: 100

    Timer {
        id: waveTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            waveContainer.phase += waveContainer.speed
            waveContainer.phase2 += waveContainer.speed2
        }
    }

    function hexToRgb(hex) {
        hex = hex.replace("#", "")
        return {
            r: parseInt(hex.substring(0, 2), 16) / 255,
            g: parseInt(hex.substring(2, 4), 16) / 255,
            b: parseInt(hex.substring(4, 6), 16) / 255
        }
    }

    function colorAt(t) {
        for (var i = 0; i < gradientStops.length - 1; i++) {
            var a = gradientStops[i]
            var b = gradientStops[i + 1]

            if (t >= a.pos && t <= b.pos) {
                var localT = (t - a.pos) / (b.pos - a.pos)
                var colA = hexToRgb(a.color)
                var colB = hexToRgb(b.color)

                return Qt.rgba(
                    colA.r + (colB.r - colA.r) * localT,
                    colA.g + (colB.g - colA.g) * localT,
                    colA.b + (colB.b - colA.b) * localT,
                    1.0
                )
            }
        }

        return gradientStops[gradientStops.length - 1].color
    }

    function waveHeight(index) {
        var wave1 = Math.sin(index * frequency + phase) * amplitude
        var wave2 = Math.sin(index * frequency2 + phase2) * amplitude2
        return Math.abs(wave1 + wave2) + baseHeight
    }


    Row {
        id: waveRow
        anchors.centerIn: parent
        spacing: waveContainer.blockSpacing

        Repeater {
            id: repeater
            model: Math.floor(waveContainer.width / (waveContainer.blockWidth + waveContainer.blockSpacing))

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter

                width: waveContainer.blockWidth
                height: waveContainer.waveHeight(index)
                radius: waveContainer.blockWidth/2

                color: waveContainer.colorAt(index / (repeater.count - 1))

            }
        }
    }
}