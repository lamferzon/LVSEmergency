import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtLocation 5.15
import QtPositioning 5.2
import "../assets"

Page {
    id: window

    Connections {
        target: masterController.ui_teamController

        function onCurrentTeamChanged() {
            if (masterController.ui_teamController.currentTeam.area.latitude !== null
                    && masterController.ui_teamController.currentTeam.area.longitude !== null) {

                // update the position on the map
                map.center = QtPositioning.coordinate(
                            masterController.ui_teamController.currentTeam.area.latitude,
                            masterController.ui_teamController.currentTeam.area.longitude)
                console.log("Updated the coordinate")

                // ask for the users positions
                masterController.ui_userController.getUsersPosition(
                            masterController.ui_teamController.currentTeam.usersId);

            }

        }
    }

    Action {
        id: navigateBackAction
        icon.name: stackView.depth > 1 ? "back" : "drawer"
        onTriggered: {
            if (stackView.depth > 1) {
                stackView.pop()
                listView.currentIndex = -1
            } else {
                drawer.open()
            }
        }
    }

    Action {
        id: optionsMenuAction
        icon.name: "menu"
        onTriggered: optionsMenu.open()
    }

    header: ToolBar {
        Material.foreground: "white"

        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                action: navigateBackAction
            }

            Label {
                id: titleLabel
                text: listView.currentItem ? listView.currentItem.text : "LVSEmergency"
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                action: optionsMenuAction

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    Action {
                        text: "Logout"
                        onTriggered: {
                            masterController.ui_teamController.resetTeam();
                            masterController.ui_userController.resetUser();
                            masterController.ui_navigationController.needLoginForm();
                        }
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.min(window.width, window.height) / 3 * 2
        height: window.height
        interactive: stackView.depth === 1

        Rectangle {
            id: drawerRect
            anchors.fill: parent

            Rectangle {
                id: imageRect
                anchors.top: drawerRect.top
                anchors.left: drawerRect.left
                anchors.right: drawerRect.right
                height: imageLogo.height
                color: "#D9D9D9"
                Image {
                    id: imageLogo
                    source: "qrc:/assets/LVSEmergencyStatic.png"
                    anchors.centerIn: parent
                    width: parent.width
                    fillMode: Image.PreserveAspectFit
                }
            }

            ListView {
                id: listView

                focus: true
                currentIndex: -1
                width: parent.width
                anchors {
                    top: imageRect.bottom
                    bottom: drawerRect.bottom
                    left: drawerRect.left
                    right: drawerRect.right
                }

                delegate: ItemDelegate {
                    width: listView.width
                    text: model.title
                    visible: isVisible(model.user, model.admin)
                    height: visible == true ? implicitHeight : 0
                    highlighted: ListView.isCurrentItem
                    onClicked: {
                        listView.currentIndex = index
                        stackView.push(model.source)
                        drawer.close()

                        if (model.source === "qrc:/views/InserisciUtente.qml") {
                            masterController.ui_teamController.getTeams()
                        } else if (model.source === "qrc:/views/CreaSquadra.qml") {
                            masterController.ui_areaController.getAreas()
                        } else if (model.source === "qrc:/views/Impostazioni.qml") {
                            masterController.ui_teamController.getTeam(
                                        masterController.ui_userController.currentUser.idTeam)
                        } else if (model.source === "qrc:/views/CancellaUtente.qml") {
                            masterController.ui_userController.getUsers()
                        } else if (model.source === "qrc:/views/AreaInfo.qml") {
                            masterController.ui_areaController.getAprsData(
                                        masterController.ui_teamController.currentTeam.area.idArea)
                        } else if (model.source === "qrc:/views/Alarm.qml") {
                            masterController.ui_areaController.getAlarmsBadWheather(
                                        masterController.ui_teamController.currentTeam.area.idArea)
                            masterController.ui_areaController.getAlarmsFogOrFrost(
                                        masterController.ui_teamController.currentTeam.area.idArea)
                        }
                    }

                    function isVisible(userVisibility, adminVisibility) {

                        if (userVisibility && (masterController.ui_userController.currentUser.role === 2
                                               || masterController.ui_userController.currentUser.role === 1))
                            return true

                        if (adminVisibility && masterController.ui_userController.currentUser.role === 0)
                            return true

                        return false

                    }
                }

                model: ListModel {
                    ListElement { title: "Inserisci Utente"; admin: true; user: false ; source: "qrc:/views/InserisciUtente.qml" }
                    ListElement { title: "Cancella Utente"; admin: true; user: false ; source: "qrc:/views/CancellaUtente.qml" }
                    ListElement { title: "Crea Squadra"; admin: true; user: false ; source: "qrc:/views/CreaSquadra.qml" }
                    ListElement { title: "Allarmi"; admin: false; user: true; source: "qrc:/views/Alarm.qml" }
                    ListElement { title: "Dati Area"; admin: false; user: true; source: "qrc:/views/AreaInfo.qml" }
                    ListElement { title: "Mappa"; admin: false; user: true; source: "qrc:/views/Mappa.qml" }
                    ListElement { title: "Informazioni"; admin: true; user: true; source: "qrc:/views/Impostazioni.qml" }
                }

                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Flickable {
            id: flickable

            contentHeight: pane.height

            Pane {
                id: pane
                width: flickable.width

                Column {
                    id: column
                    spacing: 24
                    width: parent.width

                    Label {
                        id: username
                        width: parent.width
                        wrapMode: Label.Wrap
                        horizontalAlignment: Qt.AlignHCenter
                        text: "Bentornato " +
                              masterController.ui_userController.currentUser.username
                              + "!"
                        font.bold: true
                        font.pointSize: 16
                    }

                    Label {
                        id: info
                        width: parent.width
                        wrapMode: Label.Wrap
                        horizontalAlignment: Qt.AlignHCenter
                        text: "Ecco alcune informazioni su di te:"
                    }

                    RoundPane {
                        Material.elevation: 6
                        radius: 6
                        Material.background: "#F2CB05"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column {
                            id: columnInfo
                            spacing: 8

                            Label {
                                id: name
                                text: qsTr("Nome: ") + masterController.ui_userController.currentUser.name
                            }

                            Label {
                                id: surname
                                text: qsTr("Cognome: ") + masterController.ui_userController.currentUser.surname
                            }

                            Label {
                                id: cf
                                text: qsTr("Codice Fiscale: ") + masterController.ui_userController.currentUser.cf
                            }

                            Label {
                                id: ruolo
                                text: qsTr("Ruolo: ") + getRole(masterController.ui_userController.currentUser.role)

                                function getRole(role) {
                                    if (role === 0) return "Amministratore"
                                    if (role === 1) return "Caposquadra"
                                    if (role === 2) return "Volontario"
                                }
                            }
                        }
                    }

                    Rectangle {
                        height: 2
                        width: parent.width * 5 / 6
                        radius: 5
                        anchors.horizontalCenter: parent.horizontalCenter

                        color: "#999999"
                    }

                    Label {
                        id: modifyStatus
                        width: parent.width
                        wrapMode: Label.Wrap
                        horizontalAlignment: Qt.AlignHCenter
                        text: qsTr("Clicca il pulsante per modificare lo stato di operatività.")

                        visible: masterController.ui_userController.currentUser.role !== 0
                    }

                    Button {
                        text: masterController.ui_userController.currentUser.state == 0 ?
                                  qsTr("Stato: inattivo") : qsTr("Stato: attivo")

                        highlighted: masterController.ui_userController.currentUser.state == 1

                        anchors.horizontalCenter: parent.horizontalCenter

                        visible: masterController.ui_userController.currentUser.role !== 0

                        onClicked: {
                            var stateString = masterController.ui_userController.currentUser.state == 0 ? "ACTIVE" : "INACTIVE"
                            masterController.ui_userController.currentUser.setState(stateString)
                            masterController.ui_userController.modifyUser()
                        }
                    }

                    Rectangle {
                        height: 2
                        width: parent.width * 5 / 6
                        radius: 5
                        anchors.horizontalCenter: parent.horizontalCenter

                        color: "#999999"

                        visible: masterController.ui_teamController.currentTeam === null ? false : true
                    }

                    Label {
                        id: areaVisualization
                        width: parent.width
                        wrapMode: Label.Wrap
                        horizontalAlignment: Qt.AlignHCenter
                        text: qsTr("Il tuo team opera a: ") +
                              masterController.ui_teamController.currentTeam.area.areaName

                        visible: masterController.ui_teamController.currentTeam === null ? false : true
                    }

                    RoundPane {
                        Material.elevation: 6
                        radius: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: masterController.ui_teamController.currentTeam === null ? false : true

                        width: parent.width * 4 / 5
                        height: parent.width * 4 / 5

                        Plugin {
                            id: mapPlugin
                            name: "osm"
                        }

                        Map {
                            id: map
                            anchors.fill: parent
                            plugin: mapPlugin
                            zoomLevel: 14

                            MapQuickItem {
                                id: marker
                                anchorPoint.x: image.width * 0.5
                                anchorPoint.y: image.height

                                coordinate: QtPositioning.coordinate(
                                                masterController.ui_teamController.currentTeam.area.latitude,
                                                masterController.ui_teamController.currentTeam.area.longitude)

                                sourceItem: Image {
                                    id: image
                                    source: "qrc:/assets/marker.png"
                                }
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar { }
        }

        Component.onCompleted: {
            masterController.ui_teamController.getTeam(
                        masterController.ui_userController.currentUser.idTeam)
        }
    }
}


