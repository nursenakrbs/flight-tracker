import Felgo 3.0
import QtLocation 5.5
import QtPositioning 5.5
import QtQuick 2.5
import QtQml 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

App {
    id:app
    property string serverUrl: "http://localhost:3000/flights"
    property var jsonData: undefined
    property var selectedItem: undefined
    property var newObject: []

    // handler function to be executed when the App Item is fully created, starts web requests
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: app.setInterval();
    }
    function setInterval(){
        var request = HttpRequest
        .get(serverUrl)
        .then(function(res) {
            jsonData = res.body; // keep JSON result
            console.log(JSON.stringify(jsonData));
            if(res!=='undefined')
                map.createMapItems(jsonData);
            else if(newObject.length>0)
                map.disableVehicles();

        }).catch(function(err) {
            map.disableVehicles();
            console.log(err.message);
            console.log(err.response);
        });
    }
    NavigationStack {
        Page {
            navigationBarHidden: false
            title: "Flight Tracker"
            id: page
            AppMap {
                id: map
                anchors.fill: parent
                center: QtPositioning.coordinate(48.2082,16.3738)
                zoomLevel: minimumZoomLevel+1
                Behavior on zoomLevel {
                    NumberAnimation { duration: 1000 } // ... animate to reach new value within 500ms
                }

               /** plugin: Plugin {
                    name: "mapbox"
                    // configure your own map_id and access_token here
                    parameters: [  PluginParameter {
                            name: "mapbox.mapping.map_id"
                            value: "mapbox.streets"
                        },
                        PluginParameter {
                            name: "mapbox.access_token"
                            value: "pk.eyJ1IjoiZ3R2cGxheSIsImEiOiJjaWZ0Y2pkM2cwMXZqdWVsenJhcGZ3ZDl5In0.6xMVtyc0CkYNYup76iMVNQ"
                        },
                        PluginParameter {
                            name: "mapbox.mapping.highdpi_tiles"
                            value: true
                        }]
                }*/
                plugin: Plugin {
                    name: "osm"
                    PluginParameter { name: "osm.useragent"; value: "My great Qt OSM application" }
                    PluginParameter { name: "osm.mapping.host"; value: "http://osm.tile.server.address/" }
                    PluginParameter { name: "osm.mapping.copyright"; value: "All mine" }
                    PluginParameter { name: "osm.routing.host"; value: "http://osrm.server.address/viaroute" }
                    PluginParameter { name: "osm.geocoding.host"; value: "http://geocoding.server.address" }
                }

                Rectangle {
                    id : detailBox
                    anchors.horizontalCenter: map.horizontalCenter
                    anchors.verticalCenter: map.bottom
                    width: parent.width-10
                    x:5
                    height: dp(0)
                    radius: 20.0
                    z:2
                    property var tailNumber: ""
                    property var dataModel: ListModel {
                        ListElement {
                            title: "Tail Number"
                            value: ""
                        }
                        ListElement {
                            title: "Latitude"
                            value: "0"
                        }
                        ListElement {
                            title: "Longitude"
                            value: "0"
                        }
                        ListElement {
                            title: "Altitude"
                            value: "0"
                        }
                        ListElement {
                            title: "Last Data Fetch"
                            value: "0"

                        }
                    }
                    Behavior on height {
                        NumberAnimation { duration: 200 } // ... animate to reach new value within 500ms
                    }

                    AppTextField {
                        id: messageField
                        y: myListView.y + myListView.height+dp(10)
                        width: parent.width-dp(40)
                        height: dp(40)
                        placeholderText: "Type your message here.."
                        anchors.horizontalCenter: parent.horizontalCenter
                        borderWidth: 1
                    }

                    AppButton {
                        id:messageButton
                        text: "Send"
                        onClicked: map.sendMessage()
                        y: messageField.y+dp(40)
                        flat: false
                        backgroundColor: "#56a8e3"
                        textColor: "white"
                        anchors.right: messageField.right
                        borderWidth: 0

                    }
                    TableView {
                        id: myListView
                        width: parent.width-dp(40)
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: dp(20)
                        height: detailBox.height/4 - dp(20)
                        headerVisible: false
                        TableViewColumn {
                            role: "title"
                            width: myListView.width/2-1
                        }
                        TableViewColumn {
                            role: "value"
                            width: myListView.width/2-1

                        }
                        model: detailBox.dataModel
                    }
                    /*AppListView {
                        id: myListView

                        // UI properties
                        x: detailBox.width/10 // left margin
                        y: detailBox.height/10 // top margin
                        spacing: dp(5) // vertical spacing between list items/rows/delegates
                        backgroundColor: parent.color
                        // the model will usually come from a web server, copy it here for faster development & testing

                        model: detailBox.modelData
                        delegate:
                        Row {
                            id: detailsDelegate
                            spacing: dp(20)

                            Column {
                                width: detailBox.width/2
                                anchors.verticalCenter: parent.verticalCenter
                                AppText {
                                    text: modelData.title
                                    // make all days the same width
                                    width: detailBox.width/2
                                    //
                                }
                            }
                            Column {
                                width: detailBox.width/2
                                anchors.verticalCenter: parent.verticalCenter
                                AppText {
                                    text: modelData.value
                                    horizontalAlignment: Text.AlignHCenter
                                    //anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                        }
                    }//ListView*/
                    IconButton {
                        icon: IconType.close
                        color: "lightgray"
                        anchors.right: parent.right
                        onClicked: map.hideDetails()
                    }
                    // remove focus from textedit if background is clicked
                    MouseArea {
                        anchors.fill: myListView
                        onClicked: messageField.focus = false
                    }
                }
                function sendMessage(){
                    if(messageField.text.length>0){
                        const reqBody = {
                            'message':  messageField.text,
                            'to': detailBox.tailNumber
                        }
                        var request = HttpRequest
                        .post(serverUrl+'/sendMessage',reqBody)
                        .then(function(res) {
                            if(res.body.result){
                                messageButton.text="Successful!"
                                messageButton.backgroundColor="green"
                                messageField.text = ""
                            } else {
                                messageButton.text="Failure!"
                                messageButton.backgroundColor="red"
                            }
                        }).catch(function(err) {
                            messageButton.text="Error!"
                            messageButton.backgroundColor="red"
                        });
                    } else {
                        messageButton.text="No Message!"
                        messageButton.backgroundColor="red"
                    }
                    Qt.createQmlObject('import Felgo 3.0; import QtQuick 2.5; import QtLocation 5.5; import QtPositioning 5.5; Timer {
                                                    interval: 2000
                                                    running: true
                                                    repeat: false
                                                    onTriggered: map.messageNotification();
                                                }', map);
                }
                function messageNotification(){
                    messageButton.text="Send";
                    messageButton.backgroundColor= "#56a8e3";
                }

                property var component;
                //get data from server on initialization to create map items (in a for loop)
                function createMapItems (data){
                    component = Qt.createComponent("MapItem.qml");
                    if (component.status === Component.Ready)
                        map.finishCreation();
                    else
                        component.statusChanged.connect(map.finishCreation);
                }
                function finishCreation(){
                    if(newObject.length>0){
                        //check if vehicle data is received
                        var flag = false;
                        newObject.forEach(function(element) {
                            jsonData.forEach(function(el) {
                                if(element.tailNumber === el.tailNumber){
                                    element.destroy();
                                    flag = true;
                                }
                            });
                            if(!flag){
                                element.sourceItem.color="black";
                                element.lastDataFetch += 2;
                            }
                            flag=false;
                        });                    }

                    jsonData.forEach(function(element, index) {
                        var col = element.onmission ? "green" : "red";
                        newObject[index] = component.createObject(map, { 'coordinate':QtPositioning.coordinate(element.latitude, element.longitude), 'tailNumber': element.tailNumber, 'rotationAngle':  element.rotation*180/Math.PI+45,
                                                                      'lastDataFetch': 0 });
                        var mark = Qt.createQmlObject('import Felgo 3.0; import QtQuick 2.5; import QtLocation 5.5; import QtPositioning 5.5; MapQuickItem {z: 1;
                                                sourceItem:IconButton {
                                                    icon: IconType.circle;
                                                    size: 5;
                                                    color: "'+ col +'"
                                                  }}', map);
                        mark.coordinate = QtPositioning.coordinate(element.latitude, element.longitude);
                        map.addMapItem(mark);

                        newObject[index].sourceItem.color = col;
                        newObject[index].sourceItem.opacity = 0;
                        //newObject[index].sourceItem.transform.angle = element.rotation*180/Math.PI;
                        if(detailBox.height == 2*page.height/3){
                            if(newObject[index].tailNumber === detailBox.tailNumber){
                                map.center = newObject[index].coordinate;
                                detailBox.dataModel.setProperty(0, "value", newObject[index].tailNumber);
                                detailBox.dataModel.setProperty(1, "value", element.latitude.toString());
                                detailBox.dataModel.setProperty(2, "value", element.longitude.toString());
                                detailBox.dataModel.setProperty(3, "value", element.altitude.toString());
                                detailBox.dataModel.setProperty(4, "value", newObject[index].lastDataFetch.toString()+ " seconds ago");

                                detailBox.dataModelChanged();
                            }
                        }
                        newObject[index].sourceItem.clicked.connect(function(){
                            newObject[index].sourceItem.size = 20;
                            map.zoomLevel = map.maximumZoomLevel-7;
                            detailBox.height = 2*page.height/3;
                            map.center = newObject[index].coordinate;
                            selectedItem = newObject[index];
                            detailBox.tailNumber =  newObject[index].tailNumber;
                            detailBox.dataModel.setProperty(0, "value", newObject[index].tailNumber);
                            detailBox.dataModel.setProperty(1, "value", element.latitude.toString());
                            detailBox.dataModel.setProperty(2, "value", element.longitude.toString());
                            detailBox.dataModel.setProperty(3, "value", element.altitude.toString());
                            detailBox.dataModel.setProperty(4, "value", newObject[index].lastDataFetch.toString()+ " seconds ago");
                            detailBox.dataModelChanged();
                            myListView.resizeColumnsToContents();
                        });
                        map.addMapItem(newObject[index]);
                    });
                }
                function hideDetails(){
                    map.zoomLevel = map.minimumZoomLevel+1;
                    detailBox.height = dp(0);
                }
                function disableVehicles(){
                    newObject.forEach(function(element) {
                        element.sourceItem.color="black";
                        element.lastDataFetch += 2;
                        element.sourceItem.opacity=1;
                        map.updateDetails(element);
                    });
                }
                function updateDetails(element){
                    if(element.tailNumber === detailBox.tailNumber){
                        if(element.lastDataFetch<60)
                            detailBox.dataModel.setProperty(4, "value", element.lastDataFetch.toString()+ " seconds ago");
                        else if(element.lastDataFetch>=60 && element.lastDataFetch<3600)
                            detailBox.dataModel.setProperty(4, "value", "~"+Math.round(element.lastDataFetch/60).toString()+ " minutes ago");
                        else
                            detailBox.dataModel.setProperty(4, "value", "~"+Math.round(element.lastDataFetch/3600).toString()+ " hours ago");

                        detailBox.dataModelChanged();
                    }
                }

            } // AppMap
        }
    }
}
