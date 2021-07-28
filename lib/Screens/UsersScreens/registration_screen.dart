import 'dart:convert';
import 'dart:io';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/add_user_information.dart';
import 'package:flutter_app/Screens/UsersScreens/final_message_screen.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/checkConnection.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/progrssIndicator.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:flutter_ios_voip_kit/flutter_ios_voip_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen>
    with WidgetsBindingObserver {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController whereYouAtController = TextEditingController();
  TextEditingController whatGoingOnController = TextEditingController();

  List<Choice> options = List();
  Choice choice;
  Position currentPosition;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  //pushToken
  String pushDeviceToken;
  String voIPPushDeviceToken;

  //Selection
  String userSelection;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  Data userData;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: InkResponse(
          onTap: () => onBackPress(),
          child: Image.asset('assets/images/back_ic.png'),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: TextWidgets().boldTextWidget(
            homeButtonTextColor,
            Strings.appName,
            context,
            ResponsiveFlutter.of(context).fontSize(3.0)),
      ),
      body: WillPopScope(
        child: Container(
          width: SizeConfig.safeBlockHorizontal * 100,
          height: SizeConfig.safeBlockVertical * 100,
          decoration: backgroundBoxDecoration,
          child: registrationForm(),
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Future<bool> onBackPress() {
    // Utils.showProgressBar(context);

    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        print('App paused');
        // changeUserStatus('offline');
        break;
      case AppLifecycleState.detached:
        print('App Killed');
        // Fluttertoast.showToast(msg: 'Killed');
        // changeUserStatus('offline');

        break;
      case AppLifecycleState.resumed:
        print('App resume');
        getPushToken();
        if (Platform.isIOS) getVoiPPushTokeN();
        // Fluttertoast.showToast(msg: 'resume');
        break;
    }
  }

  getPermissionStatus() async {
    bool hasBackgroundPermission =
        await BackgroundLocation.checkPermissions().isGranted;

    bool isfirstTime = await isFirstTime();
    bool hasPermission = await Permission.location.status.isDenied;
    bool hasPermission1 =
        await Permission.location.serviceStatus.isNotApplicable;
    if (hasPermission ||
        hasPermission1 ||
        !hasBackgroundPermission ||
        isfirstTime) {
      Future.delayed(Duration(seconds: 1), () => showAlertDialog(context));
    } else {
      _getLocation();
      _getCurrentLocation();
    }
  }

  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasPermission = await Permission.location.status.isDenied;

    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime != null && !isFirstTime && !hasPermission) {
      prefs.setBool('first_time', false);

      return false;
    } else {
      prefs.setBool('first_time', false);
      return true;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    getPushToken();
    if (Platform.isIOS) getVoiPPushTokeN();
    if (Platform.isAndroid) getPermissionStatus();
    if (Platform.isIOS) getPermissions();

    connectivityCheck().then((bool isAvailable) {
      if (isAvailable) {
        print('Flutter Fully Truce' + isAvailable.toString());
        // getPermissions();
      } else {
        print('Flutter Fully Truce' + isAvailable.toString());

        _showAlert(context);
      }
    });

    getUserData();

    options.add(new Choice(
        title: Strings.neighborhoodBeef,
        icon: AssetImage('assets/images/radio_btn.png'),
        isSelected: true));
    options.add(new Choice(
        title: Strings.domesticDispute,
        icon: AssetImage('assets/images/radio_btn.png'),
        isSelected: false));
    options.add(new Choice(
        title: Strings.other,
        icon: AssetImage('assets/images/radio_btn.png'),
        isSelected: false));
    options.add(new Choice(
        title: Strings.moreDetails,
        icon: AssetImage('assets/images/radio_btn.png'),
        isSelected: false));
    super.initState();
  }

  void _showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Internet"),
              content: Text("Internet not detected. Please connect it."),
            ));
  }

  @override
  void dispose() {
    /*  nameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    whatGoingOnController.dispose();
    whereYouAtController.dispose();*/
    super.dispose();
  }

  Widget registrationForm() {
    return Card(
      margin: EdgeInsets.only(
          top: ResponsiveFlutter.of(context).hp(2.0),
          bottom: ResponsiveFlutter.of(context).hp(2.0),
          right: ResponsiveFlutter.of(context).hp(2.0),
          left: ResponsiveFlutter.of(context).hp(2.0)),
      elevation: 1.0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.elliptical(
              ResponsiveFlutter.of(context).hp(2.0),
              ResponsiveFlutter.of(context).hp(2.0)))),
      child: Form(
        key: _formKey,
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ListView(
            primary: false,
            shrinkWrap: true,
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.fromLTRB(
                  ResponsiveFlutter.of(context).hp(2.0),
                  ResponsiveFlutter.of(context).hp(1.0),
                  ResponsiveFlutter.of(context).hp(2.0),
                  0,
                ),
                child: TextWidgets().semiBoldTextWidget(
                    Colors.red,
                    Strings.confirmationText,
                    context,
                    ResponsiveFlutter.of(context).fontSize(2.0)),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: nameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.name,
                    hintText: Strings.enterName,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
// errorText: _getErrorText(),
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    return null;
                  },
                  maxLength: 10,
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(10),
                  ],
                  textCapitalization: TextCapitalization.sentences,
                  controller: mobileNumberController,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    counter: Offstage(),
                    labelText: Strings.mobileNumber,
                    hintText: Strings.enterMobileNumber,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
// errorText: _getErrorText(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(0.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: emailController,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: Strings.emailOption,
                    hintText: Strings.enterEmailOption,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
// errorText: _getErrorText(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  readOnly: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: whereYouAtController,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    suffixIcon: Image.asset('assets/images/gps_ic.png'),
                    labelText: Strings.whereYouAt,
                    labelStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
// errorText: _getErrorText(),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: options.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0.0,
                      childAspectRatio: 4.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkResponse(
                          child: options[index].isSelected == false
                              ? Image(image: options[index].icon)
                              : Image(
                                  image: AssetImage(
                                    'assets/images/radio_selected_btn.png',
                                  ),
                                ),
                          onTap: () {
                            for (int i = 0; i < options.length; i++)
                              options[i].isSelected = false;
                            options[index].isSelected = true;
                            setState(() {
                              userSelection = options[index].title;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(right: 5.0)),
                        TextWidgets().semiBoldTextWidget(
                            Colors.black,
                            options[index].title,
                            context,
                            ResponsiveFlutter.of(context).fontSize(2.0)),
                      ],
                    );
                    //just for testing, will fill with image lat
                  },
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(1.0),
                    ResponsiveFlutter.of(context).hp(2.0),
                    0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  controller: whatGoingOnController,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                      fontFamily: fontStyle, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(30.0),
                    hintText: Strings.whatsGoingOn,
                    isDense: false,
                    alignLabelWithHint: true,
                    hintStyle: TextStyle(
                        fontFamily: fontStyle,
                        color: labelColor,
                        fontWeight: FontWeight.w400),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: labelColor)),
                    border: new OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: labelColor,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
// errorText: _getErrorText(),
                  ),
                ),
              ),
              FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: sendButtonColor,
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(10.0, 10.0))),
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(
                      ResponsiveFlutter.of(context).hp(2.0),
                      ResponsiveFlutter.of(context).hp(1.0),
                      ResponsiveFlutter.of(context).hp(2.0),
                      0),
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Text(
                    Strings.send,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: fontStyle,
                        fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) dialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  dialog() {
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
                    Image.asset('assets/images/send_graphic_ic.png'),
                    Padding(
                      padding: EdgeInsets.only(
                          right: ResponsiveFlutter.of(context).hp(1.0),
                          left: ResponsiveFlutter.of(context).hp(1.0),
                          top: ResponsiveFlutter.of(context).hp(1.0)),
                      child: Text(
                        Strings.dialogMessage,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize:
                                ResponsiveFlutter.of(context).fontSize(2.0),
                            fontFamily: fontStyle),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            right: ResponsiveFlutter.of(context).hp(1.0),
                            left: ResponsiveFlutter.of(context).hp(1.0)),
                        child: Text(
                          Strings.dialogSecondMessage,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ResponsiveFlutter.of(context).fontSize(2.0),
                              fontFamily: fontStyle),
                        )),
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'CANCEL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: fontStyle,
                                      color: Colors.red,
                                      fontSize: ResponsiveFlutter.of(context)
                                          .fontSize(2.0)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    confirmationClick();
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

  confirmationClick() {
    connectivityCheck().then((intenet) {
      if (intenet != null && intenet) {
        Utils.showProgressBar(context);

        final Map<String, String> data = new Map<String, String>();
        data['user_type'] = 'user';
        data['name'] = nameController.text.trim().toString();
        data['phone_no'] = mobileNumberController.text.trim().toString();
        data['email'] = emailController.text.trim().toString();
        data['location_name'] = whereYouAtController.text == null
            ? ''
            : whereYouAtController.text.trim().toString();
        data['user_latitude'] =
            currentPosition == null ? '' : currentPosition.latitude.toString();
        data['user_longitude'] =
            currentPosition == null ? '' : currentPosition.longitude.toString();
        data['user_option'] =
            userSelection == null ? '' : userSelection.trim().toString();
        data['user_detail'] = whatGoingOnController.text.trim().toString();
        data['device_type'] = Platform.isAndroid == true ? 'android' : 'ios';
        data['device_token'] = pushDeviceToken.toString().length == 0
            ? ""
            : pushDeviceToken.toString();
        data['voip_token'] =
            Platform.isAndroid ? "" : voIPPushDeviceToken.toString();

        AddUserApiClient()
            .addUser(data, context)
            .then((http.Response response) {
          if (response.statusCode == 200) {
            UserInformationModel userData =
                UserInformationModel.fromJson(json.decode(response.body));
            if (userData.statusCode == 3) {
              SaveDataLocal.saveUserData(userData);
              SaveDataLocal.saveUserStatus('UserPending');

              Utils.dismissProgressBar(context);
              navigateFinalScreen(userData.data.help_id);
            } else {
              Utils.dismissProgressBar(context);
              Fluttertoast.showToast(msg: userData.message);
            }
          } else {
            Utils.dismissProgressBar(context);
            Fluttertoast.showToast(msg: 'Something went wrong');
            print('Flutter Fully Truce Error');
          }
        }).catchError((onError) {
          Utils.dismissProgressBar(context);
          // Fluttertoast.showToast(msg: 'Something went wrong');
          print('Flutter Fully Truce Error : ----' + onError.toString());
        });
      } else {
        Utils.dismissProgressBar(context);
        Fluttertoast.showToast(msg: 'internet Not Available');
      }
    });
  }

  navigateFinalScreen(helpId) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => FinalMessageScreen(),
        ),
        (route) => false);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      currentPosition = position;
    });
    /*.catchError((e) {
      print('Flutter Fully Truce' + e.toString());
    });*/
  }

  _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('location: ${position.latitude}');
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    whereYouAtController.text = first.addressLine;
    print("Adrees Lcoation New : - " +
        "${first.featureName} : ${first.addressLine}");
  }

  getPermissions() async {
    // await CallKeep.askForPermissionsIfNeeded(context);

    await BackgroundLocation.getPermissions();

    await [
      Permission.location,
    ].request();

    if (await Permission.location.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }
    if (await Permission.locationAlways.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }

    if (await Permission.locationAlways.isDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      // getPermissions();
    }
    if (await Permission.location.isGranted) {
      _getLocation();
      _getCurrentLocation();
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        Future.delayed(Duration(seconds: 2), () {
          getPermissions();
        });
      },
    );
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
        Future.delayed(Duration(seconds: 2), () {
          showAlertDialog(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Allow Philly Truce to access your device\'s location.'),
      content: Text(
          "Philly Truce collects location data to enable the location display of user, mediator and backup mediator to each other for help even when the app is closed or not in use."),
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

  getPushToken() {
    PushNotificationsManager().pushToken.then((value) {
      print('Flutter Fully Truce' + value.toString());
      setState(() {
        pushDeviceToken = value;
      });
    });
  }

  getVoiPPushTokeN() {
    FlutterIOSVoIPKit _voipPush = FlutterIOSVoIPKit();

    _voipPush.getVoIPToken().then((value) {
      print('Flutter Fully Truce VoIP Token' + value.toString());
      setState(() {
        voIPPushDeviceToken = value;
      });
    });
  }

  getUserData() async {
    userData = await SaveDataLocal.getUserDataFromLocal();

    if (userData == null || userData.user_type != 'user') {
    } else {
      nameController.text = userData.name;
      mobileNumberController.text = userData.phone_no;
      emailController.text = userData.email;
    }
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

class Choice {
  Choice({this.title, this.icon, this.isSelected});

  final String title;
  final AssetImage icon;
  bool isSelected;
}
