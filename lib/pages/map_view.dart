import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';

const String apiToken =
    'pk.eyJ1Ijoic29oYWdtYWhpbiIsImEiOiJja2Y2eGt4MDgwaW5tMnJxZzdpeTBnaWw1In0.eg_fDEMqXHvgu6sWJJ1AXg';
const String mapStyle = 'sohagmahin/ckf70r9td43as19o18mfojw45';

class MapView extends StatelessWidget {
  final TextEditingController _latLonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<Position> getLocation() async {
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied &&
        permission == LocationPermission.deniedForever) {
      LocationPermission permission = await requestPermission();
    }
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _latLonController.text = "${position.latitude} , ${position.longitude}";
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<Position>(
        future: getLocation(),
        builder: (context, AsyncSnapshot<Position> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            return _buildMap(context, snapshot);
          } else if (snapshot.hasError) {
            children = _buildErrorWidget(snapshot);
          } else {
            children = _buildLoadingWidget();
          }
          return Center(
            child: Column(
              children: children,
            ),
          );
        },
      ),
    );
  }

  FlutterMap _buildMap(BuildContext context, AsyncSnapshot<Position> snapshot) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(snapshot.data.latitude, snapshot.data.longitude),
        zoom: 17.0,
      ),
      layers: [
        TileLayerOptions(
          maxZoom: 20,
          minZoom: 15,
          urlTemplate: "https://api.mapbox.com/styles/v1/" +
              mapStyle +
              "/tiles/{z}/{x}/{y}?access_token=" +
              apiToken,
          additionalOptions: {
            'accessToken': apiToken,
            'id': 'mapbox.mapbox-streets-v8'
          },
        ),
        MarkerLayerOptions(
          markers: [
            _buildMarker(context, snapshot.data),
          ],
        ),
      ],
    );
  }

  Marker _buildMarker(BuildContext context, Position position) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(position.latitude, position.longitude),
      builder: (ctx) => Container(
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/icons/icons.png'),
                  fit: BoxFit.cover),
            ),
          ),
          onTap: () {
            _showModal(context);
          },
        ),
      ),
    );
  }

  Future<void> _showModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Lat/Lon'),
                controller: _latLonController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                controller: _nameController,
              ),
              RaisedButton(
                onPressed: () {
                  debugPrint("Lat/Lon: " +
                      _latLonController.text +
                      "\n" +
                      "Name: " +
                      _nameController.text);
                },
                child: Text('Send to console'),
              )
            ],
          ),
        );
      },
    );
  }

  _buildErrorWidget(AsyncSnapshot snapshot) {
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text('Error: ${snapshot.error}'),
      )
    ];
  }
}

_buildLoadingWidget() {
  return <Widget>[
    SizedBox(
      child: CircularProgressIndicator(),
      width: 60,
      height: 60,
    ),
    const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text('Awaiting result...'),
    )
  ];
}
