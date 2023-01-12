var express = require('express'),
    app = express(),
    http = require('http'),
    restPort = process.env.PORT || 3000;

bodyParser = require('body-parser');

var addon = require('bindings')('vehicle-tracking-binding');

app.use(bodyParser.urlencoded({ extended: true}));
app.use(bodyParser.json());

// configure everything for Cesium frontend, just basic setup
app.set('czml_port', restPort + 1);
app.use(function (req, resp, next) {
    resp.header("Access-Control-Allow-Origin", "*");
    resp.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

// Serve the www directory statically
app.use(express.static('www'));

//---------------------------------------
// mini CZML app
//---------------------------------------
var openConnections = [];

app.get('/czml', function (req, resp) {

    req.socket.setTimeout(2 * 60 * 1000);

    // send headers for event-stream connection
    // see spec for more information
    resp.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive'
    });
    resp.write('\n');

    // push this res object to our global variable
    openConnections.push(resp);

    // send document packet
    var d = new Date();
    resp.write('id: ' + d.getMilliseconds() + '\n');
    resp.write('data:' + JSON.stringify({ "id": "document", "version": "1.0" }) + '\n\n'); // Note the extra newline

    // When the request is closed, e.g. the browser window
    // is closed. We search through the open connections
    // array and remove this connection.
    req.on("close", function () {
        var toRemove;
        for (var j = 0; j < openConnections.length; j++) {
            if (openConnections[j] == resp) {
                toRemove = j;
                break;
            }
        }
        openConnections.splice(j, 1);
    });
});

setInterval(function () {
    // we walk through each connection
    openConnections.forEach(function (resp) {

        // send doc
        var d = new Date();
        resp.write('id: ' + d.getMilliseconds() + '\n');
        resp.write('data:' + createMsg() + '\n\n'); // Note the extra newline
    });

}, 1000);

var idNameMap = new Map();

function createMsg() {
    var updatedIds = addon.getUpdatedVehicleIds();
    var result = [];
    updatedIds.forEach(id => {
        if (!idNameMap.has(id))
            idNameMap.set(id, addon.getName(id));
        var positionArray = addon.getPosition(id);

        var entity = {
            "id": id,
            "position": { "cartographicDegrees": [positionArray[0], positionArray[1], positionArray[2]] },
            "billboard": {
                "image": [
                    {
                        "uri": "images/helicopter.png"
                    }
                ],
                "rotation": positionArray[3]
            },
            "label": {
                "font": "12pt Lucida Console",
                "fillColor": { "rgba": [0, 0, 0, 255] },
                "pixelOffset": {
                    "cartesian2": [0, 40]
                },
                "text": idNameMap.get(id)
            }
        };
        result.push(entity);
    });
    return JSON.stringify(result);
}
//--------------------------------------

// startup everything

var routes = require('./routes/flightRoutes');
routes(app);

app.listen(restPort);
http.createServer(app).listen(app.get('czml_port'), function () {
    console.log("CZML server listening on port " + app.get('czml_port'));
})

console.log('FLIGHT TRACKER SERVER STARTED ON: '+ restPort);
