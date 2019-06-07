import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_view/map_view.dart';

import '../helpers/ensure-visible.dart';

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address) async {
    if (address.isEmpty) {
      return;
    }
    final Uri uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'address': address,
        'key': 'AIzaSyBR6pVaeskMSlsOBhRccmT7tgBcR0yOSs8',
      },
    );
    final http.Response response = await http.get(uri);
    final Map<String, dynamic> addressData = json.decode(response.body);
    print(addressData);
    final String formattedAddress =
        addressData['results'][0]['formatted_address'];
    final Map<String, dynamic> coordinates =
        addressData['results'][0]['geometry']['location'];
    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyBR6pVaeskMSlsOBhRccmT7tgBcR0yOSs8');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers(
      [
        Marker(
          'position',
          'Position',
          coordinates['lat'],
          coordinates['lng'],
        ),
      ],
      center: Location(
        coordinates['lat'],
        coordinates['lng'],
      ),
      width: 500,
      height: 300,
      maptype: StaticMapViewType.roadmap,
    );
    setState(() {
      _addressInputController.text = formattedAddress;
      _staticMapUri = staticMapUri;
    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null ? Container() : Image.network(_staticMapUri.toString()),
      ],
    );
  }
}
