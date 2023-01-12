
import Felgo 3.0
import QtQuick 2.5
import QtLocation 5.5
import QtPositioning 5.5

MapQuickItem {
    z: 2
    property var lastDataFetch
    property string tailNumber
    property var altitude
    property alias rotationAngle: rotation.angle
    sourceItem: IconButton {
        id:pin
        icon: IconType.plane
        size: 18
        disabledColor: "black"
        selectedColor: "darkgreen"
        color: "red"
        opacity: 1
        Behavior on opacity {
            NumberAnimation { duration: 1980 }
        }
     }
    transform: Rotation { id:rotation
        origin.x: pin.x+pin.width/2
        origin.y: pin.y+pin.height/2
                          angle: 0
    }
    anchorPoint: Qt.point(0,0)
    //zoomLevel: 10
}


