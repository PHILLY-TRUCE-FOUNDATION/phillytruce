import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_locations.dart';
import 'package:flutter_app/Model/get_locations.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/request_backup.dart';
import 'package:flutter_app/Providers/update_user_location.dart';
import 'package:flutter_app/Screens/Calling/calling_screen.dart';
import 'package:flutter_app/Screens/chat_screen.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:http/http.dart' as http;

import 'follow_up_screen.dart';

class MapScreen extends StatefulWidget {
  final String mediatorType;
  final int id, peerId, helpId;
  final String peerName, location, email;

  MapScreen(this.mediatorType, this.id, this.peerId, this.helpId, this.peerName,
      this.location, this.email);

  @override
  _MapScreenState createState() => _MapScreenState(
      mediatorType, id, peerId, helpId, peerName, location, email);
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  _MapScreenState(this.mediatorType, this.id, this.peerId, this.helpId,
      this.peerName, this.location, this.email);

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();

  String mediatorType;
  int id, peerId, helpId;
  String peerName, location, email, peerAvatarName;

  Data mediatorData;
  BitmapDescriptor userPinLocationIcon, mediatorPinLocationIcon;
  Set<Circle> circles = Set();

  // Position currentPosition;
  Location previousPosition1;
  Location currentPosition1;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String previousAddress;
  String currentAddress;
  bool firstTime = true;

  http.Client httpClient = http.Client();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Stack(
          children: [
            Container(
              color: Colors.transparent,
              padding: mediatorType == 'MainMediator'
                  ? EdgeInsets.only(bottom: 200.0)
                  : EdgeInsets.all(0.0),
              child: GoogleMap(
                circles: circles,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  print('ief');
                  print('ief' + _controller.isCompleted.toString());
                  _goToTheLake(double.parse(mediatorData.user_latitude),
                      double.parse(mediatorData.user_longitude));
                },
                markers: markers,
              ),
            ),
            addGoogleMapWithMarkers(),
            GestureDetector(
              child: Container(
                  margin: EdgeInsets.only(
                      top: ResponsiveFlutter.of(context).hp(6.0),
                      left: ResponsiveFlutter.of(context).hp(3.0)),
                  width: SizeConfig.safeBlockHorizontal * 12,
                  height: SizeConfig.safeBlockHorizontal * 12,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10.0, 10.0)),
                      color: Colors.white,
                      image: DecorationImage(
                          image: AssetImage('assets/images/back_ic.png'),
                          alignment: Alignment.center))),
              onTap: () => onBackPress(),
            ),
            mediatorType == 'MainMediator'
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.elliptical(
                                  ResponsiveFlutter.of(context).hp(4.0),
                                  ResponsiveFlutter.of(context).hp(4.0)),
                              topRight: Radius.elliptical(
                                  ResponsiveFlutter.of(context).hp(4.0),
                                  ResponsiveFlutter.of(context).hp(4.0)))),
                      clipBehavior: Clip.hardEdge,
                      elevation: 2.0,
                      margin: EdgeInsets.all(0.00),
                      child: bottomCard(),
                    ))
                : Container(),
            markers.length == 0
                ? Container(
                    height: SizeConfig.safeBlockVertical * 100,
                    width: SizeConfig.safeBlockHorizontal * 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }

  callAPiCalling(peerId) async {
    final channel_name = this.helpId.toString() +
        this.id.toString() +
        DateTime.now().millisecond.toString();
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallingScreen(
            channelName: channel_name,
            peerId: peerId.toString(),
            role: ClientRole.Broadcaster,
            isIncomingCall: false,
            peerName: 'User',
          ),
        ));
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  Future<bool> onBackPress() {
    // Utils.showProgressBar(context);

    Navigator.pop(context);

    return Future.value(false);
  }

  Widget bottomCard() {
    print('Flutter Fully Truce ' +
        id.toString() +
        peerId.toString() +
        helpId.toString() +
        peerName);

    List<String> list = List();
    String firstCharacter = peerName.characters.elementAt(0),
        secondCharacter = peerName.characters.elementAt(1);
    if (peerName.contains(' ')) {
      list = peerName.split(' ');

      firstCharacter = list[0].characters.elementAt(0);
      secondCharacter = list[1].characters.isNotEmpty
          ? list[1].characters.elementAt(0)
          : list[0].characters.elementAt(1);
    }

    peerAvatarName = firstCharacter + secondCharacter;
    return Container(
        padding: EdgeInsets.only(bottom: 20.0, top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(right: 40.0, left: 40.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: ResponsiveFlutter.of(context).hp(10.0),
                    clipBehavior: Clip.hardEdge,
                    // color: labelColor,
                    width: ResponsiveFlutter.of(context).hp(8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRect(
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Card(
                            clipBehavior: Clip.hardEdge,
                            margin: EdgeInsets.only(top: 6.0, bottom: 6.0),
                            child: Container(),
                            color: sendButtonColor,
                          ),
                          Text(
                            peerAvatarName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: fontStyle,
                                color: Colors.white,
                                fontSize: ResponsiveFlutter.of(context)
                                    .fontSize(2.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                      child: Container(
                    margin: EdgeInsets.only(left: 10.0, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidgets().semiBoldTextWidget(
                            Colors.black,
                            peerName,
                            context,
                            ResponsiveFlutter.of(context).fontSize(2.2)),
                        email.length != 0
                            ? TextWidgets().semiBoldTextWidget(
                                labelColor,
                                email,
                                context,
                                ResponsiveFlutter.of(context).fontSize(2.0))
                            : Container(),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10.0, top: 10.0, left: 60.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.elliptical(10.0, 10.0))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  location.length != 0
                      ? Padding(
                          padding: EdgeInsets.only(right: 10.0, top: 5.0),
                          child: Image(
                            image: AssetImage(
                              'assets/images/location_pin_ic.png',
                            ),
                          ),
                        )
                      : Container(),
                  Flexible(
                      child: Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveFlutter.of(context).fontSize(1.5),
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontStyle,
                    ),
                  )),
                  Padding(padding: EdgeInsets.only(right: 10.0)),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 5,
                      child: InkResponse(
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0),
                          padding: EdgeInsets.only(
                              right: 20.0, bottom: 10.0, top: 10.0, left: 20.0),
                          decoration: BoxDecoration(
                              color: trueCallColor,
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10.0, 10.0))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage(
                                    'assets/images/phone_call_ic.png'),
                              ),
                              Padding(padding: EdgeInsets.only(right: 10.0)),
                              TextWidgets().boldTextWidget(
                                  Colors.white,
                                  'TRUCE CALL',
                                  context,
                                  ResponsiveFlutter.of(context).fontSize(2.0))
                            ],
                          ),
                        ),
                        onTap: () => callAPiCalling(peerId),
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      child: GestureDetector(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          width: SizeConfig.safeBlockHorizontal * 12,
                          height: SizeConfig.safeBlockHorizontal * 12,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(10.0, 10.0)),
                            color: sendButtonColor,
                            image: DecorationImage(
                                image: AssetImage('assets/images/chat_ic.png'),
                                alignment: Alignment.center),
                          ),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  peerId, helpId, id, false, false, true),
                            )),
                      ),
                    ),
                  ]),
            ),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: EdgeInsets.only(
                  top: 4.0, bottom: 0.0, right: 40.0, left: 40.0),
              child: Container(
                decoration: BoxDecoration(
                    color: sendButtonColor,
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(15.0, 15.0))),
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text(
                  Strings.requestBackUp,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontStyle,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                requestForBackUp();
              },
            ),
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: EdgeInsets.only(
                  top: 4.0, bottom: 5.0, right: 40.0, left: 40.0),
              child: Container(
                decoration: BoxDecoration(
                    color: sendButtonColor,
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(15.0, 15.0))),
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Text(
                  Strings.followUp,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontStyle,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowUpScreen(helpId),
                    ));

                // if (_formKey.currentState.validate()) dialog();
              },
            ),
          ],
        ));
  }

  requestForBackUp() {
    Utils.showProgressBar(_scaffoldKey.currentContext);
    RequestBackUpClient().requestBackUpRequest(helpId).then((int statusCode) {
      if (statusCode == 3) {
        Utils.dismissProgressBar(_scaffoldKey.currentContext);
      } else {
        // showStaticAlertDialog(_scaffoldKey.currentContext, message);
        // Fluttertoast.showToast(msg: message);
        // Fluttertoast.showToast(msg: message);
        Utils.dismissProgressBar(_scaffoldKey.currentContext);
      }
    });
  }

  dialog(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(
                top: ResponsiveFlutter.of(context).hp(2.0),
                bottom: ResponsiveFlutter.of(context).hp(1.0)),
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            content: Container(
              width: SizeConfig.safeBlockHorizontal * 100,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image.asset('assets/images/send_graphic_ic.png'),
                    Padding(
                      padding: EdgeInsets.only(
                          right: ResponsiveFlutter.of(context).hp(1.0),
                          left: ResponsiveFlutter.of(context).hp(1.0),
                          top: ResponsiveFlutter.of(context).hp(1.0)),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 10,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize:
                                ResponsiveFlutter.of(context).fontSize(2.0),
                            fontFamily: fontStyle),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          right: ResponsiveFlutter.of(context).hp(1.0),
                          left: ResponsiveFlutter.of(context).hp(1.0)),
                      margin: EdgeInsets.only(
                          top: ResponsiveFlutter.of(context).hp(3.0)),
                      height: 0.3,
                      decoration: BoxDecoration(
                          color: labelColor,
                          borderRadius:
                              BorderRadius.all(Radius.elliptical(10.0, 10.0))),
                      width: SizeConfig.safeBlockHorizontal * 70,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: ResponsiveFlutter.of(context).hp(1.0)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FlatButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    if (Platform.isAndroid) {
                                      bool hasBackgroundPermission =
                                          await BackgroundLocation
                                                  .checkPermissions()
                                              .isGranted;
                                      if (!hasBackgroundPermission)
                                        Future.delayed(Duration(seconds: 2),
                                            showAlertDialog(context));
                                      else {
                                        getBackgroundLocationPermission();
                                      }
                                    } else {
                                      getBackgroundLocationPermission();
                                    }
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                        fontFamily: fontStyle,
                                        color: Colors.green,
                                        fontSize: ResponsiveFlutter.of(context)
                                            .fontSize(2.0)),
                                  )),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.593683, 78.962883),
    zoom: 20.4746,
  );

  Future<void> _goToTheLake(lat, long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 17.4746)));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getMediatorsLocationBloc.getMediatorLocationsDetails(helpId);

    setCustomMapPin();
    getMediatorData();
    markers.clear();
    super.initState();
  }

  void setCustomMapPin() async {
    mediatorPinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/mediator_pin.png',
        mipmaps: true);

    userPinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/user_pin.png',
        mipmaps: true);
  }

  getMediatorData() async {
    mediatorData = await SaveDataLocal.getUserDataFromLocal();
    _getCurrentLocation();
  }

  addCircle(LatLng latLng) {
    Circle circle = Circle(
        visible: true,
        circleId: CircleId('0'),
        center: latLng,
        radius: 80,
        strokeColor: Colors.black,
        strokeWidth: 0,
        fillColor: bigMapCircleColor);
    circles.add(circle);

    Circle circle1 = Circle(
        visible: true,
        circleId: CircleId('1'),
        center: latLng,
        radius: 40,
        strokeWidth: 0,
        fillColor: smallMapCircleColor);
    circles.add(circle1);
  }

  addGoogleMapWithMarkers() {
    return StreamBuilder<GetLocations>(
        stream: getMediatorsLocationBloc.subject.stream,
        builder: (context, AsyncSnapshot<GetLocations> snapshot) {
          if (snapshot.hasData) {
            print('mnoiwef' + snapshot.data.data.toString());
            if (snapshot.data.data != null)
              print('mnoiwef1' + snapshot.data.data.toString());

            for (int i = 0; i < snapshot.data.data.length; i++) {
              if (snapshot.data.data.elementAt(i).user_role ==
                  'backup_mediator') {
                final Marker marker = Marker(
                    markerId: MarkerId(i.toString()),
                    position: LatLng(
                        double.parse(
                            snapshot.data.data.elementAt(i).user_latitude),
                        double.parse(
                            snapshot.data.data.elementAt(i).user_longitude)),
                    icon: mediatorPinLocationIcon);

                markers.add(marker);
              } else if (snapshot.data.data.elementAt(i).user_role ==
                  'mediator') {
                final Marker marker = Marker(
                    markerId: MarkerId(i.toString()),
                    position: LatLng(
                        double.parse(
                            snapshot.data.data.elementAt(i).user_latitude),
                        double.parse(
                            snapshot.data.data.elementAt(i).user_longitude)),
                    icon: mediatorPinLocationIcon);

                markers.add(marker);
              } else if (snapshot.data.data.elementAt(i).user_role == 'user') {
                if (snapshot.data.data.elementAt(i).user_longitude.isNotEmpty) {
                  final Marker marker = Marker(
                      markerId: MarkerId(i.toString()),
                      position: LatLng(
                          double.parse(
                              snapshot.data.data.elementAt(i).user_latitude),
                          double.parse(
                              snapshot.data.data.elementAt(i).user_longitude)),
                      icon: userPinLocationIcon);

                  markers.add(marker);
                  addCircle(LatLng(
                      double.parse(
                          snapshot.data.data.elementAt(i).user_latitude),
                      double.parse(
                          snapshot.data.data.elementAt(i).user_longitude)));
                  if (firstTime)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      dialog(
                          'IF YOU WANT TO MEET USER NOW, MAKE SURE USER LOCATION IS SAFE. REQUEST BACK UP BEFORE GOING!');
                    });
                } else {
                  if (firstTime)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      dialog(
                          'USER HAS NOT SHARED LOCATION. IF YOU WANT TO MEET USER NOW, DECIDE WHERE YOU WILL MEET AND REQUEST BACK UP BEFORE GOING!');
                    });
                  // dialog(
                  //     'USER HAS NOT SHARED LOCATION. IF YOU WANT TO MEET USER NOW, DECIDE WHERE YOU WILL MEET AND REQUEST BACK UP BEFORE GOING!');
                }
              }
            }
            print('jpjfi' + markers.length.toString());

            _controller.future.then((value) {
              Future.delayed(Duration(milliseconds: 200), () {
                if (firstTime) {
                  firstTime = false;
                  value.animateCamera(CameraUpdate.newLatLngBounds(
                      boundsFromLatLngList(
                          markers.map((loc) => loc.position).toList()),
                      50));
                }
              });
            });
            return Container();
          }
          print('jpjfi' + markers.length.toString());
          return Container();
        });

    /*setState(() {
      var marker = Marker(
        markerId: MarkerId("Mediator"),
        position: LatLng(double.parse(mediatorData.user_latitude),
            double.parse(mediatorData.user_longitude)),
        icon: userPinLocationIcon,
      );
      _markers["Mediator"] = marker;
      var marker1 = Marker(
        markerId: MarkerId("Mediator"),
        position: LatLng(20.581754,
            78.986755),
        icon: userPinLocationIcon,
      );
      _markers["Mediator"] = marker;
    });
*/
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(_scaffoldKey.currentContext);

        getBackgroundLocationPermission();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Allow Philly Truce to access your device\'s location.'),
      content: Text(
          "Philly Truce collects location data to enable the location display of  user, mediator and backup mediator to each other for help even when the app is closed or not in use."),
      actions: [okButton],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _getCurrentLocation() async {
    Marker marker;
    marker = Marker(
        markerId: MarkerId('self'),
        position: LatLng(double.parse(mediatorData.user_latitude),
            double.parse(mediatorData.user_longitude)),
        icon: mediatorPinLocationIcon);
    markers.add(marker);

    // currentLocation.onLocationChanged
    //     .listen((LocationData.LocationData currentLocation) {
    //   marker = Marker(
    //       markerId: MarkerId('self'),
    //       position: LatLng(currentLocation.latitude, currentLocation.longitude),
    //       icon: mediatorPinLocationIcon);
    //   if (this.mounted)
    //     setState(() {
    //       markers.add(marker);
    //     });
    // });
  }

  getBackgroundLocationPermission() async {
    bool hasBackgroundPermission =
        await BackgroundLocation.checkPermissions().isGranted;
    if (hasBackgroundPermission) {
      permissionGrant();
    } else {
      BackgroundLocation.getPermissions(onGranted: () {
        permissionGrant();
      });
    }
  }

  permissionGrant() async {
    bool hasBackgroundPermission =
        await BackgroundLocation.checkPermissions().isGranted;
    bool hasPermission = await Permission.location.status.isGranted;

    if (hasPermission || hasBackgroundPermission) {
      BackgroundLocation.startLocationService();
      BackgroundLocation.setAndroidConfiguration(1000);

      BackgroundLocation.getLocationUpdates((location) {
        // Fluttertoast.showToast(msg: 'Location Changed' + location.toString());
        Marker marker;
        currentPosition1 = location;
        updateLocation(helpId, location);
        marker = Marker(
            markerId: MarkerId('self'),
            position: LatLng(location.latitude, location.longitude),
            icon: mediatorPinLocationIcon);
        if (this.mounted)
          setState(() {
            markers.add(marker);
          });
      });
    }
  }

  updateLocation(helpId, Location location) {
    // Fluttertoast.showToast(msg: 'Update Location');
    if (previousPosition1 == null) {
      // _getCurrentLocation(helpId);
      // _getAddressFromLatLng(helpId);

      _getLocation(helpId);
      previousPosition1 = location;
      // Fluttertoast.showToast(msg: 'Call API');
    } else {
      geolocator
          .distanceBetween(
              previousPosition1.latitude,
              previousPosition1.longitude,
              currentPosition1.latitude,
              currentPosition1.longitude)
          .then((double distance) {
        // Fluttertoast.showToast(msg: distance.toString());

        if (distance >= 100) {
          // _getCurrentLocation(helpId);
          // _getAddressFromLatLng(helpId);
          _getLocation(helpId);
          previousPosition1 = currentPosition1;
          // Fluttertoast.showToast(msg: 'Call API');
        }
      });
    }
  }

  _getLocation(helpId) async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    currentAddress = first.addressLine;
    print("Adrees Lcoation New : - " +
        "${first.featureName} : ${first.addressLine}");
    UpdateUserLocationClient(httpClient: httpClient).updateUserLocation(
        LatLng(currentPosition1.latitude, currentPosition1.longitude),
        helpId,
        currentAddress);
  }

  /*_getAddressFromLatLng(helpId) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          currentPosition1.latitude, currentPosition1.longitude);
      Placemark place = p[0];
      previousAddress = currentAddress;

      currentAddress =
          "${place.name},${place.subThoroughfare},${place.subLocality},${place.locality}, ${place.postalCode}, ${place.country} ";

      UpdateUserLocationClient(httpClient: httpClient).updateUserLocation(
          LatLng(currentPosition1.latitude, currentPosition1.longitude),
          helpId,
          currentAddress);
    } catch (e) {
      print(e);
    }
  }*/

  @override
  void dispose() {
    _controller.future.then((value) => value.dispose());
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        // getMediatorsLocationBloc.getMediatorLocationsDetails(helpId);

        print('dimi' + 'resumed');
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        print('dimi' + 'inactive');

        break;
      case AppLifecycleState.paused:
        // widget is paused
        print('dimi' + 'paused');
        break;
      case AppLifecycleState.detached:
        print('dimi' + 'detached');

        // widget is detached
        break;
    }
  }
}
