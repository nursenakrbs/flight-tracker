'use strict';

var addon = require('bindings')('vehicle-tracking-binding');
var idNameMap = new Map();

exports.list_all_flights =
  function (req, res) {

    var updatedIds = addon.getUpdatedVehicleIds();
    var result = [];
    updatedIds.forEach(id => {
        if (!idNameMap.has(id))
            idNameMap.set(id, addon.getName(id));
        var positionArray = addon.getPosition(id);
        var flight =
        {
          "latitude": positionArray[1],
          "longitude": positionArray[0],
          "altitude": positionArray[2],
          "tailNumber": idNameMap.get(id),
          "onmission": false,
          "rotation": positionArray[3]
        };

        result.push(flight);
    });

    res.writeHead(200, { "Content-Type": "application/json" });
    res.write(JSON.stringify(result));
    res.end();
  };

exports.create_a_flight = function(req, res) {
  var new_flight = new Flight(req.body);
  new_flight.save(function(err, flight) {
    if (err)
      res.send(err);
    res.json(flight);
  });
};

exports.send_message = function(req,res){
    console.log(req.body);
    res.json({"result": true});
}

