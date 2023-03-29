import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class StyleInfo {
  final String name;
  final String baseStyle;
  final Future<void> Function(MapboxMapController) addDetails;
  final CameraPosition position;

  const StyleInfo(
      {required this.name,
      required this.baseStyle,
      required this.addDetails,
      required this.position});
}

class MapsDemo extends StatefulWidget {
  // --dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE
  static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");

  const MapsDemo({super.key});

  @override
  State<MapsDemo> createState() => _MapsDemoState();
}

class _MapsDemoState extends State<MapsDemo> {
  @override
  void initState() {
    super.initState();
  }

  int selectedStyleId = 0;
  MapboxMapController? controller;

  _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  static Future<void> addGeojsonHeatmap(MapboxMapController controller) async {
    await controller.addSource(
        "earthquakes-heatmap-source",
        const GeojsonSourceProperties(
          data: {
            "type": "FeatureCollection",
            "features": [
              {
                "type": "Feature",
                "properties": {"mag": 1.29},
                "geometry": {
                  "type": "Point",
                  "coordinates": [-118.806, 34.022]
                }
              },
              {
                "type": "Feature",
                "properties": {"mag": 1.3},
                "geometry": {
                  "type": "Point",
                  "coordinates": [-118.806, 34.022]
                }
              },
            ]
          }
    ));
        // );
        // const GeojsonSourceProperties(
        //   data:
        //       "https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson",
        // ));
    await controller.addLayer(
        "earthquakes-heatmap-source",
        "earthquakes-heatmap-layer",
        const HeatmapLayerProperties(
          heatmapColor: [
            Expressions.interpolate,
            ["linear"],
            ["heatmap-density"],
            .1,
            "rgba(33.0, 102.0, 172.0, 0.0)",
            0.2,
            "rgb(103.0, 169.0, 207.0)",
            0.4,
            "rgb(209.0, 229.0, 240.0)",
            0.6,
            "rgb(253.0, 219.0, 240.0)",
            0.8,
            "rgb(239.0, 138.0, 98.0)",
            1,
            "rgb(178.0, 24.0, 43.0)",
          ],
          heatmapWeight: [
            Expressions.interpolate,
            ["linear"],
            [Expressions.get, "mag"],
            1,
            1,
            6,
            1,
          ],
          heatmapIntensity: [
            Expressions.interpolate,
            ["linear"],
            [Expressions.zoom],
            1,
            1,
            9,
            3,
          ],
          heatmapRadius: [
            Expressions.interpolate,
            ["linear"],
            [Expressions.zoom],
            1,
            2,
            9,
            20,
          ],
          heatmapOpacity: [
            Expressions.interpolate,
            ["linear"],
            [Expressions.zoom],
            7,
            1,
            9,
            0.5
          ],
        ));
  }

  static const _stylesAndLoaders = [
    StyleInfo(
      name: "Geojson heatmap",
      baseStyle: MapboxStyles.DARK,
      addDetails: addGeojsonHeatmap,
      position: CameraPosition(target: LatLng(33.5, -118.1), zoom: 5),
    ),
  ];

  _onStyleLoadedCallback() async {
    final styleInfo = _stylesAndLoaders[selectedStyleId];
    styleInfo.addDetails(controller!);
    controller!
        .animateCamera(CameraUpdate.newCameraPosition(styleInfo.position));
  }

  @override
  Widget build(BuildContext context) {
    final styleInfo = _stylesAndLoaders[selectedStyleId];
    return Scaffold(
      body: MapsDemo.ACCESS_TOKEN.isEmpty ||
              MapsDemo.ACCESS_TOKEN.contains("YOUR_TOKEN")
          ? buildAccessTokenWarning()
          : 
          Stack(
            children: [
              MapboxMap(
                styleString: styleInfo.baseStyle,
                accessToken: MapsDemo.ACCESS_TOKEN,
                onMapCreated: _onMapCreated,
                initialCameraPosition: styleInfo.position,
                onStyleLoadedCallback: _onStyleLoadedCallback,
              ),
            ],
          )
    );
  }

  Widget buildAccessTokenWarning() {
    return Container(
      color: Colors.red[900],
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Please pass in your access token with",
            "--dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE",
            "passed into flutter run or add it to args in vscode's launch.json",
          ]
              .map((text) => Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: MapsDemo()));
}