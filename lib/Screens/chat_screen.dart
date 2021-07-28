import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Model/user_inforamation_model.dart';
import 'package:flutter_app/Providers/mediator/changeMediatorChatStatus.dart';
import 'package:flutter_app/Providers/mediator/sendnotification.dart';
import 'package:flutter_app/Screens/MediatorScreens/mediator_profile_login.dart';
import 'package:flutter_app/Screens/UsersScreens/final_message_screen.dart';
import 'package:flutter_app/Services/firebase.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/checkConnection.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/savedatalocal.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:flutter_app/Main/Bloc/Mediator/get_user_by_id_bloc.dart';
import 'MediatorScreens/user_informaiton_Screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart' as Foundation;

class ChatScreen extends StatefulWidget {
  final int peerId, helpId, id;
  final bool isFromNotification, isNeedToSave, isFromChatList;

  ChatScreen(this.peerId, this.helpId, this.id, this.isFromNotification,
      this.isNeedToSave, this.isFromChatList);

  @override
  _ChatScreenState createState() => _ChatScreenState(
      peerId, helpId, id, isFromNotification, isNeedToSave, isFromChatList);
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  _ChatScreenState(this.peerId, this.helpId, this.id, this.isFromNotification,
      this.isNeedToSave, this.isFromChatList);

  int peerId;
  int id;
  int helpId;
  String peerName;
  bool isFromNotification;
  bool isNeedToSave;
  bool isFromChatList;
  Data userType;

  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();
  int _limit = 20;
  final int _limitIncrement = 20;
  String threadId;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  String dateTimestamp;

  String peerAvatarName;
  bool isIdAvailable;
  List list = [];
  String status;
  Map<String, dynamic> mediatorData = new Map<String, dynamic>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkResponse(
          onTap: () => onBackPress(),
          child: Image.asset('assets/images/back_ic.png'),
        ),
        shadowColor: Colors.transparent,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0.0,
        title: getPeerData(),
      ),
      body: WillPopScope(
        child: Container(
          width: SizeConfig.safeBlockHorizontal * 100,
          height: SizeConfig.safeBlockVertical * 100,
          decoration: backgroundBoxDecoration,
          child: chatScreen(),
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget appbar(peerName, peerAvatarName) {
    return Container(
      child: Row(
        children: [
          Container(
              width: SizeConfig.safeBlockHorizontal * 11,
              margin: EdgeInsets.only(right: 10.0),
              height: SizeConfig.safeBlockVertical * 8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Card(
                    margin: EdgeInsets.only(top: 8.0, bottom: 6.0),
                    child: Container(),
                    color: sendButtonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.elliptical(
                            ResponsiveFlutter.of(context).hp(2.0),
                            ResponsiveFlutter.of(context).hp(2.0)))),
                  ),
                  Text(
                    peerAvatarName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: fontStyle,
                        color: Colors.white,
                        fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),
                  ),
                ],
              )),
          TextWidgets().boldTextWidget(Colors.black, peerName, context,
              ResponsiveFlutter.of(context).fontSize(3.0))
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    // Utils.showProgressBar(context);

    // Navigator.push(context, MaterialPageRoute(builder: (context) =>
    //   UserInformation(
    //       notificationType, helpId, userUserId, requestBackupId),))
    //
    // if (isFromNotification) {
    //   Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => HomeScreen(),
    //       ),
    //       (route) => false);
    // }

    if (Platform.isAndroid)
      PushNotificationsManager.flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails()
          .then((NotificationAppLaunchDetails value) {
        if (value.didNotificationLaunchApp) {
          if (userType.user_type == 'user') {
            if (isFromChatList) {
              Navigator.pop(context);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinalMessageScreen(),
                  ));
            }
          }
          if (userType.user_type == 'mediator') {
            if (status == 'MediatorPending') {
              print('Flutter Philly' + mediatorData['helpId'].toString());
              if (isFromChatList) {
                Navigator.pop(context);
              } else
                return Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInformation(
                            mediatorData['isBackUpMediator'] == false
                                ? 'help_request'
                                : 'help_backup_request',
                            mediatorData['helpId'],
                            mediatorData['userId'],
                            0,
                            false)));
            } else if (status == 'BackUpMediatorPending') {
              print('Flutter Philly' + mediatorData['helpId'].toString());
              if (isFromChatList) {
                Navigator.pop(context);
              } else
                return Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInformation(
                            mediatorData['isBackUpMediator'] == false
                                ? 'help_request'
                                : 'help_backup_request',
                            mediatorData['helpId'],
                            mediatorData['userId'],
                            0,
                            false)));
            } else if (isFromChatList) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MediatorRegistrationScreen(false, true),
                  ));
            }
          }
        } else {
          Navigator.pop(context);
        }
      });
    else {
      Navigator.pop(context);
    }

    // Navigator.pop(context);

    return Future.value(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    changeUserStatus('offline');

    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        changeUserStatus('offline');
        break;
      case AppLifecycleState.paused:
        print('App paused');
        changeUserStatus('offline');
        break;
      case AppLifecycleState.detached:
        print('App Killed');
        // Fluttertoast.showToast(msg: 'Killed');
        changeUserStatus('offline');

        break;
      case AppLifecycleState.resumed:
        print('App resume');
        changeUserStatus('online');
        // Fluttertoast.showToast(msg: 'resume');
        break;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    print('uwfw' + peerId.toString());
    getUserByIdBloc.getRequestDetails(peerId);
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);

    changeUserStatus('online');
    if (id.hashCode <= peerId.hashCode) {
      threadId = '$id-$peerId';
    } else {
      threadId = '$peerId-$id';
    }
    print('nufwe' + threadId);

    FirebaseFirestore.instance
        .collection('messageList')
        .doc(helpId.toString())
        .snapshots()
        .listen((DocumentSnapshot event) {
      if (event.exists) {
        print('iofhkrtiho' + event.data()['Id'].toString());
        print('iofhkrtiho' + peerId.toString());
        list.clear();
        list.addAll(event.data()['Id']);
        var contain = list.where((element) => element == id.toString());

        print('iofhkrtihoasdsdasda' + contain.toString());

        if (contain.isNotEmpty) {
          print('iofhkrtiho');

          setState(() {
            isIdAvailable = true;
          });
        } else {
          print('iofhkrtiho1');

          setState(() {
            isIdAvailable = false;
          });
        }
      } else {
        setState(() {
          isIdAvailable = false;
        });
      }
    });
    // print('Flutter Fully Truce' + peerId.toString());
    super.initState();
    getUserData();
  }

  getUserData() async {
    userType = await SaveDataLocal.getUserDataFromLocal();
    status = await SaveDataLocal.getUserStatus();
    if (status == 'MediatorPending')
      mediatorData = await SaveDataLocal.getRespondedMediatorType();
    if (status == 'BackUpMediatorPending')
      mediatorData = await SaveDataLocal.getRespondedMediatorType();
  }

  _scrollListener() {
      if (listScrollController.offset >=
              listScrollController.position.maxScrollExtent &&
          !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");

        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
    }
    /*else {
      typingStatusUpdate('false');
    }*/
  }

  Widget chatScreen() {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.elliptical(
              ResponsiveFlutter.of(context).hp(2.0),
              ResponsiveFlutter.of(context).hp(2.0)))),
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                buildListMessage(),
                // Input content
                inputBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messageList')
            .doc(helpId.toString())
            .collection(threadId)
            .orderBy('timestamp', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            print('Flutter Fully Truce' + snapshot.data.toString());

            listMessage.addAll(snapshot.data.documents);

            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                return buildItem(index, snapshot.data.documents[index]);
              },
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['senderId'] == id) {
      // Right (my message)
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                child: Text(
                  decrypt(document.data()['content']),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontStyle,
                      fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                      fontWeight: FontWeight.w600),
                ),
                constraints: BoxConstraints(
                    maxWidth: SizeConfig.safeBlockHorizontal * 60,
                    minWidth: SizeConfig.safeBlockHorizontal * 45),
                padding: EdgeInsets.only(
                    top: 20.0, bottom: 20.0, right: 25.0, left: 25.0),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: sendButtonColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0))),
                margin: EdgeInsets.all(10.0))
          ]);
    } else {
      // Left (peer message)

      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                decrypt(document.data()['content']),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: ResponsiveFlutter.of(context).fontSize(2.0),
                    fontFamily: fontStyle,
                    fontWeight: FontWeight.w600),
              ),
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20.0, right: 25.0, left: 25.0),
              constraints: BoxConstraints(
                  maxWidth: SizeConfig.safeBlockHorizontal * 60,
                  minWidth: SizeConfig.safeBlockHorizontal * 45),
              decoration: BoxDecoration(
                  color: chatReceiverColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0),
                      topLeft: Radius.circular(25.0))),
              margin: EdgeInsets.all(10.0),
            )
          ]);
    }
  }

  void onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();

      print('niouwef' + peerId.toString() + "/" + helpId.toString());
      SendNotification()
          .sendNotification(peerId.toString(), content.trim().toString(),
              helpId.toString(), context)
          .then((value) {
        if (value) {
          dateTimestamp = DateTime.now().microsecondsSinceEpoch.toString();
          WriteBatch batch = FirebaseFirestore.instance.batch();
          print('niouwef' + isIdAvailable.toString());
          if (!isIdAvailable && isNeedToSave) {
            list.add(id.toString());
            print('niouwef');

            // FirebaseFirestore.instance.collection('messageList').doc(helpId.toString()).delete();
            FirebaseFirestore.instance
                .collection('messageList')
                .doc(helpId.toString())
                .set({'Id': list});
            setState(() {
              isIdAvailable = true;
            });
          }

          var documentReference = FirebaseFirestore.instance
              .collection('messageList')
              .doc(helpId.toString())
              .collection(threadId)
              .doc(dateTimestamp);

          batch.set(documentReference, {
            'senderId': id,
            'receiverId': peerId,
            'timestamp': dateTimestamp,
            'content': encrypt(content),
            'dateAndTime':
                getLastMessageTimeAsString(int.parse(dateTimestamp)).toString(),
            'helpId': helpId
          });

          print('Flutter Fully Truce' + batch.toString());

          batch.commit();

          listScrollController.animateTo(0.0,
              duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        } else {
          Fluttertoast.showToast(
              msg: 'Something went wrong',
              backgroundColor: Colors.black,
              textColor: Colors.red);
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  getLastMessageTimeAsString(int smsTimeInMilis) {
    var date = new DateTime.fromMicrosecondsSinceEpoch(smsTimeInMilis);
    String result = date
        .toUtc()
        .toString()
        .substring(0, date.toUtc().toString().indexOf('.'));

    print('Flutter Fully Truce object' + result.trim());
    return result.toString();
  }

  Widget inputBox() {
    return Container(
      padding: EdgeInsets.only(
          left: ResponsiveFlutter.of(context).hp(2.0),
          right: ResponsiveFlutter.of(context).hp(2.0)),
      child: Row(
        children: <Widget>[
          // Button send image
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 20.0),
              child: TextField(
                // onTap: () => typingStatusUpdate('true'),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                showCursor: true,
                autofocus: false,
                onSubmitted: (value) {
                  // onSendMessage(textEditingController.text, 0);
                  // typingStatusUpdate('false');
                },
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: fontStyle,
                    fontWeight: FontWeight.w500),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type message...',
                  hintStyle: TextStyle(
                      color: labelColor,
                      fontFamily: fontStyle,
                      fontWeight: FontWeight.w500),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
          InkResponse(
            child: Material(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset('assets/images/send_ic.png'),
              ),
              color: Colors.white,
            ),
            onTap: () {
              connectivityCheck().then((intenet) => {
                    if (intenet != null && intenet)
                      {onSendMessage(textEditingController.text)}
                    else
                      {Fluttertoast.showToast(msg: 'internet Not Available')}
                  });
            },
          ),
        ],
      ),
      width: SizeConfig.safeBlockVertical * 70,
      height: 70.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: labelColor, width: 0.5)),
          color: Colors.white),
    );
  }

  changeUserStatus(String status) {
    ChangeMediatorChatStatus()
        .changeMediatorChatStatus(status, context)
        .then((value) => print('nufwe' + value.toString()));
  }

  getPeerData() {
    return StreamBuilder<UserInformationModel>(
      stream: getUserByIdBloc.subject.stream,
      builder: (context, AsyncSnapshot<UserInformationModel> snapshot) {
        if (snapshot.hasData) {
          print('nuiwfe' + snapshot.data.toJson().toString());
          peerName = snapshot.data.data.name;
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
          return appbar(snapshot.data.data.name, peerAvatarName);
        } else {
          return Container();
        }
      },
    );
  }

  static String encrypt(String data) {
    var encryptionKey = 'MD5';

    var charCount = data.length;
    var encrypted = [];
    var kp = 0;
    var kl = encryptionKey.length - 1;

    for (var i = 0; i < charCount; i++) {
      var other = data[i].codeUnits[0] ^ encryptionKey[kp].codeUnits[0];
      encrypted.insert(i, other);
      kp = (kp < kl) ? (++kp) : (0);
    }
    return dataToString(encrypted);
  }

  static String decrypt(data) {
    return encrypt(data);
  }

  static String dataToString(data) {
    var s = "";
    for (var i = 0; i < data.length; i++) {
      s += String.fromCharCode(data[i]);
    }
    return s;
  }
}
