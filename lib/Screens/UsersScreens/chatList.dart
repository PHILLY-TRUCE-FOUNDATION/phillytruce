import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Model/chatModel.dart';
import 'package:flutter_app/Providers/getChatLIstUser.dart';
import 'package:flutter_app/Screens/chat_screen.dart';
import 'package:flutter_app/Utils/SizeConfig.dart';
import 'package:flutter_app/Utils/const.dart';
import 'package:flutter_app/Utils/strings.dart';
import 'package:flutter_app/Widget/backgorund.dart';
import 'package:flutter_app/Widget/error_widget.dart';
import 'package:flutter_app/Widget/text.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:flutter/foundation.dart' as Foundation;

class ChatList extends StatefulWidget {
  final int helpId, userId;

  ChatList(this.helpId, this.userId);

  @override
  _ChatListState createState() => _ChatListState(helpId, userId);
}

class _ChatListState extends State<ChatList> {
  _ChatListState(helpId, userId);

  int helpId;
  int userId;
  ChatModel chatModel;
  List<ChatData> lissst = [];
  List list = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: true,
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
        title: TextWidgets().boldTextWidget(
            homeButtonTextColor,
            Strings.appName,
            context,
            ResponsiveFlutter.of(context).fontSize(3.0)),
      ),
      body: Container(
        width: SizeConfig.safeBlockHorizontal * 100,
        height: SizeConfig.safeBlockVertical * 100,
        decoration: backgroundBoxDecoration,
        child: Card(
            margin: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
            elevation: 1.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(
                    ResponsiveFlutter.of(context).hp(2.0),
                    ResponsiveFlutter.of(context).hp(2.0)))),
            child: isLoading
                ? Container(
                    child: Center(
                    child: Platform.isAndroid
                        ? CircularProgressIndicator()
                        : CupertinoActivityIndicator(),
                  ))
                : showData()),
      ),
    );
  }

  showData() {
    return isLoading && lissst.length == 0
        ? buildErrorWidget('No Message found')
        : ListView.builder(
            padding: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
            itemCount: lissst.length,
            itemBuilder: (context, index) {
              return requestPendingListItems(lissst[index]);
            },
          );
  }

  @override
  void initState() {
    print('fwef' + widget.helpId.toString());
    print('fwef' + widget.userId.toString());
    getUSerIDs();
    super.initState();
  }

  getUSerIDs() {
    FirebaseFirestore.instance
        .collection('messageList')
        .doc(widget.helpId.toString())
        .snapshots()
        .listen((DocumentSnapshot event) {
      print('niouwfn' + event.data().toString());
      if(event.exists) {
        List<String> streetsList = new List<String>.from(event.data()['Id']);
        print('niouwfn' + streetsList.toString());

        list.addAll(streetsList);
      }
      print('minofw' + list.length.toString());
      if (list.length != 0) getChatList();
      if (list.length == 0) {
        setState(() {
          isLoading = false;
        });
      }
    });

    // return StreamBuilder<DocumentSnapshot>(
    //     stream: FirebaseFirestore.instance
    //         .collection('messageList')
    //         .doc('100')
    //         .snapshots(),
    //     builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    //       print('Production ' + snapshot.data.toString());
    //
    //       if (snapshot.hasData) {
    //         print('Production ' + snapshot.data.id);
    //         print('Production ' + snapshot.data.data()['Id'].toString());
    //         // List<String> streetsList = new List<String>.from(streetsFromJson);
    //
    //         print('niof' + 'iuniuwhnfiuhwiufhwiuf');
    //         getChatList();
    //         isLoading = false;
    //         return ListView.builder(
    //           padding: EdgeInsets.all(ResponsiveFlutter.of(context).hp(2.0)),
    //           itemCount: lissst.length,
    //           itemBuilder: (context, index) {
    //             return requestPendingListItems(lissst[index]);
    //           },
    //         );
    //       } else {
    //         return Container(
    //           child: Center(
    //             child: Platform.isAndroid
    //                 ? CircularProgressIndicator()
    //                 : CupertinoActivityIndicator(),
    //           ),
    //         );
    //       }
    //     });
  }

  getChatList() {
    GetChatListByIdListClient().getChatUserByIdList(list).catchError((onError) {
      print('niof' + onError.toString());
    }).then((ChatModel value) {
      print('niof' + 'uibfuwec');
      setState(() {
        chatModel = value;
        if (value != null) lissst.addAll(value.data);
        isLoading = false;
      });

    });
  }

  Widget requestPendingListItems(ChatData chatModel) {
    print('Production ' + chatModel.toJson().toString());
    print('Production ' + chatModel.name.toString());
    print('Production ' + chatModel.user_id.toString());
    print('Production ' + chatModel.name.toString());

    return InkResponse(
        child: Container(
          alignment: Alignment.topLeft,
          height: ResponsiveFlutter.of(context).hp(14.0),
          child: Row(
            children: [
              Container(
                width: SizeConfig.safeBlockHorizontal * 16,
                height: SizeConfig.safeBlockVertical * 11,
                margin: EdgeInsets.only(right: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Card(
                      margin: EdgeInsets.only(top: 8.0, bottom: 6.0),
                      child: Container(),
                      color: sendButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.elliptical(
                              ResponsiveFlutter.of(context).hp(3.0),
                              ResponsiveFlutter.of(context).hp(3.0)))),
                    ),
                    Text(
                      getCharacters(chatModel.name).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: fontStyle,
                          color: Colors.white,
                          fontSize:
                              ResponsiveFlutter.of(context).fontSize(3.5)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        chatModel.name.trim().toString().length != 0
                            ? TextWidgets().semiBoldTextWidget(
                                Colors.black,
                                chatModel.name,
                                context,
                                ResponsiveFlutter.of(context).fontSize(2.0))
                            : Container(),
                      ],
                    ),
                    // chatModel.phone_no.trim().toString().length != 0
                    //     ? TextWidgets().semiBoldTextWidget(
                    //         Colors.black,
                    //     chatModel.phone_no,
                    //         context,
                    //         ResponsiveFlutter.of(context).fontSize(2.0))
                    //     : Container()
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Align(
                    child: Image.asset('assets/images/right_arrow_ic.png'),
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    style: BorderStyle.solid, color: labelColor, width: 0.5)),
          ),
        ),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                    chatModel.user_id, widget.helpId, widget.userId, false,false,true),
              ),
            ));
  }

  String getCharacters(String peerName) {
    List<String> list = List();
    if(peerName.characters.length > 1) {
      String firstCharacter = peerName.characters.elementAt(0),
          secondCharacter = peerName.characters.elementAt(1);
      if (peerName.contains(' ')) {
        list = peerName.split(' ');

        firstCharacter = list[0].characters.elementAt(0);
        secondCharacter = list[1].characters.isNotEmpty
            ? list[1].characters.elementAt(0)
            : list[0].characters.elementAt(1);
      }
      return firstCharacter + secondCharacter;
    }
    else{
      list = peerName.split(' ');
      String firstCharacter = peerName.characters.elementAt(0);
      firstCharacter = list[0].characters.elementAt(0);
      return firstCharacter + firstCharacter;

    }
  }

  onBackPress() {
    Navigator.pop(context);
  }
}
