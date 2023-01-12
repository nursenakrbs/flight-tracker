$(function() {
  var viewer = new Cesium.Viewer('cesiumContainer', {
    navigationHelpButton: false,
    geocoder: false,
    homeButton: false,
    fullscreenButton: false,
    targetFrameRate: 60,
    baseLayerPicker: true,
    resolutionScale: 2.0,
    sceneModePicker: true,
    animation: true,
    sceneMode: Cesium.SceneMode.SCENE2D,
    contextOptions: {
      scene3DOnly: false,
      contextOptions: {
        allowTextureFilterAnisotropic: true
      }
    }
  });

  var scene = viewer.scene;

  // Create new CZML datasource
  var czmlStream = new Cesium.CzmlDataSource();
  var czmlStreamUrl = 'czml';

  // Setup EventSource
  var czmlEventSource = new EventSource(czmlStreamUrl);

  // Listen for EventSource data coming
  czmlEventSource.onmessage = function(e) {
    czmlStream.process(JSON.parse(e.data));
  }

  // Put the datasource into Cesium
  viewer.dataSources.add(czmlStream);
});
