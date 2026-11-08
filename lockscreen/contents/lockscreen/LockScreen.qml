// Plasma's lock screen (Super + L) is not drawn by SDDM but by kscreenlocker.
// This file lets kscreenlocker show our SDDM theme: it reuses Main.qml and
// fakes the few SDDM objects (sddm, config, userModel) that Main.qml expects.
import QtQuick
import QtCore
import "../../.."   // the theme folder with Main.qml, WaveBar.qml, ...

Item {
    id: root

    // kscreenlocker looks for these properties and signals by name
    property bool viewVisible: false
    property bool suspendToRamSupported: false
    property bool suspendToDiskSupported: false
    signal suspendToRam()
    signal suspendToDisk()

    // Some accounts have no password, so PAM lets them in right away.
    // We still wait until the user presses "Login" instead of unlocking by ourselves.
    property bool unlockedWithoutPassword: false

    // true while a password typed by the user is being checked by PAM.
    // PAM can also fail on its own (e.g. when the system goes to sleep),
    // and we don't want to show "Login failed" for that.
    property bool passwordSubmitted: false

    // A password typed while PAM wasn't listening. It is handed over as soon as
    // PAM asks for it, see onPromptForSecretChanged.
    property string pendingPassword: ""

    // the ids below are visible inside Main.qml and stand in for SDDM's objects

    // read-only access to the same theme.conf SDDM uses, so colors and icons stay in one place
    // (only value() is used; Settings properties would get written back into the file)
    Settings {
        id: themeConf
        location: Qt.resolvedUrl("../../../theme.conf")
    }

    // every string property here is filled from theme.conf with the same name, see Component.onCompleted
    QtObject {
        id: config

        property string background
        property string avatar
        property string usernameIcon
        property string passwordIcon
        property string sleepIcon
        property string restartIcon
        property string shutdownIcon
        property string sessionIcon
        property string fancyDateFont
        property string sessionSwitcherEnabled

        property string backgroundColor
        property string cardBackgroundColor
        property string borderColor
        property string primaryTextColor
        property string placeholderTextColor
        property string secondaryTextColor
        property string red
        property string orange
        property string yellow
        property string green
        property string blue
        property string purple

        property string waveBlockWidth
        property string waveBlockSpacing
        property string waveBaseHeight
        property string waveAmplitude
        property string waveFrequency
        property string waveSpeed
        property string waveAmplitude2
        property string waveFrequency2
        property string waveSpeed2
    }

    // You can't switch sessions on a lock screen, so this stays empty.
    // It only exists because SessionSwitcher.qml expects a sessionModel.
    ListModel {
        id: sessionModel
        property int lastIndex: 0
    }

    QtObject {
        id: userModel
        readonly property string lastUser: kscreenlocker_userName
    }

    QtObject {
        id: sddm

        // a locked screen must not allow rebooting or shutting down without a password
        readonly property bool canSuspend: root.suspendToRamSupported
        readonly property bool canReboot: false
        readonly property bool canPowerOff: false

        signal loginSucceeded()
        signal loginFailed()

        // only the password matters, the user is already logged in
        function login(user, password, session) {
            if (root.unlockedWithoutPassword)
                root.unlock()
            else {
                root.passwordSubmitted = true
                // When the screen locks by itself, kscreenlocker ignores every start
                // during the first seconds (the "grace time") and nobody tries again
                // later, so after a sleep PAM may never have been started. Then the
                // password would go nowhere and the button seems dead, so start PAM
                // now and hand the password over once it asks for it.
                if (authenticator.state === 1)   // Authenticating
                    authenticator.respond(password)
                else {
                    root.pendingPassword = password
                    authenticator.startAuthenticating()
                }
            }
        }
        function suspend() { root.suspendToRam() }
    }

    Main {
        anchors.fill: parent

        // During the short wait after a wrong password PAM isn't listening yet,
        // so anything typed then would be lost. Breeze locks the fields too.
        inputEnabled: !retryTimer.running

        // kscreenlocker only ever unlocks the user who locked the screen,
        // so typing another name here would do nothing anyway
        usernameEditable: false

        // When the screen locks by itself (idle timeout), the first start in
        // Component.onCompleted can come to nothing, and the password would then
        // go nowhere. So like Breeze, start again whenever the card shows up;
        // if PAM is already waiting this does nothing.
        onUiVisibleChanged: if (uiVisible) authenticator.startAuthenticating()
    }

    function unlock() {
        sddm.loginSucceeded()
        Qt.quit()   // closing the greeter is what unlocks the session
    }

    Connections {
        target: authenticator

        function onSucceeded() {
            // if PAM never asked for a password, let the user confirm first
            if (authenticator.hadPrompt)
                root.unlock()
            else
                root.unlockedWithoutPassword = true
        }

        function onPromptForSecretChanged() {
            if (root.pendingPassword === "")
                return
            authenticator.respond(root.pendingPassword)
            root.pendingPassword = ""
        }

        function onFailed(kind) {
            if (kind !== 0)   // ignore fingerprint/smartcard, only react to the password
                return
            root.pendingPassword = ""
            // only complain if the user actually tried a password
            if (root.passwordSubmitted)
                sddm.loginFailed()
            root.passwordSubmitted = false
            retryTimer.restart()
        }
    }

    // after a wrong password PAM blocks for ~2 seconds, so wait before asking again
    // (same 3 seconds as Plasma's own lock screen)
    Timer {
        id: retryTimer
        interval: 3000
        onTriggered: authenticator.startAuthenticating()
    }

    Component.onCompleted: {
        // Fill config with the values from theme.conf, so we don't have to write
        // every key out twice. Looping over config also hands us its functions and
        // Qt's own "objectName", so we skip those and only keep our string properties.
        // If a key is missing in theme.conf, the property just stays empty.
        for (const key in config)
            if (typeof config[key] === "string" && key !== "objectName")
                config[key] = themeConf.value(key, "")

        // even if theme.conf turns the session switcher on, it makes no sense here
        config.sessionSwitcherEnabled = "false"

        // ask PAM for the password right away so the first attempt already counts
        authenticator.startAuthenticating()
    }
}
