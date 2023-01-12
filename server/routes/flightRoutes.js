'use strict';
module.exports = function(app) {
  var flightList = require('../controllers/flightController');

  // flightApi Routes
  app.route('/flights')
    .get(flightList.list_all_flights)
    .post(flightList.create_a_flight);

    app.route('/flights/sendMessage')
    .post(flightList.send_message);

};