import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geo_map_locator/model/location_model.dart';
import 'package:geo_map_locator/widget/texticon.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  final double lat;
  final double long;

  HomePage({required this.lat, required this.long});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> markers = [];

  static const double RADIUS = 20;
  late double minLat;
  late double maxLat;
  late double minLong;
  late double maxLong;

  late final Marker yourLocation;

  void getLocations(String str) async {
    List<Marker> mr = [yourLocation];
    Response response = await get(Uri.parse(
        'https://z.overpass-api.de/api/interpreter?data=[out:json] [bbox:$minLat,$minLong,$maxLat,$maxLong]; (node["amenity"=$str]; way["amenity"=$str]; rel["amenity"=$str];); out center;'));
    if (response.statusCode == 200) {
      if ((jsonDecode(response.body)['elements'] as List).length != 0) {
        for (var data in jsonDecode(response.body)['elements'])
          if (data['lat'] != null && data['lon'] != null)
            mr.add(setMarker(LocationModel.fromJson(data)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Not Found"),
        ));
      }

      setState(() {
        markers = mr;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.body),
      ));
    }
  }

  Marker setMarker(LocationModel model) {
    return Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 100,
      width: 100,
      point: LatLng(model.lat, model.long),
      builder: (ctx) => TextIcon(
        text: model.name,
      ),
    );
  }

  @override
  void initState() {
    yourLocation = Marker(
      anchorPos: AnchorPos.align(AnchorAlign.center),
      height: 100,
      width: 100,
      point: LatLng(widget.lat, widget.long),
      builder: (ctx) => TextIcon(
        text: "Your Location",
        color: Colors.blue,
      ),
    );
    markers = [
      yourLocation,
    ];

    minLat = widget.lat - RADIUS / 111.12;
    maxLat = widget.lat + RADIUS / 111.12;
    minLong =
        widget.long - RADIUS / (cos(widget.long / 180 * pi) * 111.12).abs();
    maxLong =
        widget.long + RADIUS / (cos(widget.long / 180 * pi) * 111.12).abs();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              zoom: 16.0,
              center: LatLng(widget.lat, widget.long),
              plugins: [
                MarkerClusterPlugin(),
              ],
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerClusterLayerOptions(
                maxClusterRadius: 0,
                size: Size(40, 40),
                anchor: AnchorPos.align(AnchorAlign.center),
                markers: markers,
                builder: (context, markers) {
                  return FloatingActionButton(
                    onPressed: null,
                    child: Text(markers.length.toString()),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 50, left: 40, right: 40),
            child: TextField(
              cursorColor: Colors.grey,
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey,
                ),
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                focusColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              ),
              style: TextStyle(
                fontSize: 20,
              ),
              onSubmitted: (val) {
                getLocations(val.trim().replaceAll(" ", "_").toLowerCase());
              },
            ),
          ),
        ],
      ),
    );
  }
}
