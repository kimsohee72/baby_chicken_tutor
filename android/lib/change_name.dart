import 'dart:async';
import 'dart:convert';
import 'package:ble_example/app-bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:hex/hex.dart';
import 'Chick.dart';
import 'Rovoid.dart';
import 'main.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' show radians;

// 연결 상태 표시 문자열
String stateText = 'Connecting';
// 연결 버튼 문자열
String connectButtonText = 'Disconnect';
// 현재 연결 상태 저장용
// BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

// 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
StreamSubscription<BluetoothDeviceState>? _stateListener;

List<BluetoothService> bluetoothService = [];
// late BluetoothDevice dev;

int pp = 0;
int re = 0;
int ind = 0;
int re_ind = 0;
bool warning = false;
bool st_autoPlay = false;
bool te_autoPlay = false;
bool size = true;
int Choose_player = 0;
int touch_te = 0;


class ChangeName extends StatefulWidget {
  ChangeName({Key? key, required this.device}) : super(key: key);
  // 장치 정보 전달 받기
  final BluetoothDevice device;

  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName>{
  // flutterBlue
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  // String bleState = "Searching...";
  // String bleState1 = "Searching...";
  int watchDogCount = 0;
  // late BluetoothDevice device;
  // // late BluetoothDeviceState state;
  bool isUpdated = true;
  bool sendStarted = false;
  late BuildContext test;
  bool go_home = false;
  int k=0;
  String Label_text = "바꿀 이름을 작성해 주세요!";
  final _contentEditController = TextEditingController();

  @override
  initState() {
    // flutterBlue.stopScan();
    hello = true;
    go_home = false;
    super.initState();
    dev = widget.device;
    print(dev);
    // 상태 연결 리스너 등록
    _stateListener = widget.device.state.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // 상태가 동일하다면 무시
        return;
      }
      // 연결 상태 정보 변경
      roboid.setBleConnectionState(event);
    });
    // 연결 시작
    roboid.connect();
    eventBus.on().listen((event) {
      if(event == "1"){
        setState((){});
      }
      if(event == "2"){
        setState(() {
          stateText = 'Connecting';
        });
      }
      // if(event == "3"){
      //   setState(() {
      //     stateText = 'Disconnecting';
      //   });
      // }
      if(event == "go_home"){
        Future.delayed(Duration(seconds: 3),() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()),);
        });
      }
      if(event == "이름 변경 됨"){
        // showDialog(
        //     context: context,
        //     barrierDismissible: false, // 바깥 영역 터치시 닫을지 여부
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         content: Text("정말로 변경하시겠습니까?"),
        //         insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
        //         actions: [
        //           TextButton(
        //             child: const Text('확인'),
        //             onPressed: () {
        //               eventBus.fire("go_home");
        //             },
        //           ),
        //         ],
        //       );
        //     }
        // );

        Future.delayed(Duration(seconds: 1),() {
          // Navigator.pop(context);
        });
      }

    });
    if (deviceState == BluetoothDeviceState.connected) {
      chick.bleState = "Connected";
      /* 연결된 상태라면 연결 해제 */
      setState(() { });
    } else if (deviceState ==
        BluetoothDeviceState.disconnected) {
      chick.bleState = "Disconnected";
      /* 연결 해재된 상태라면 연결 */
      setState(() { });
    }
  }

  @override
  void dispose() {
    // 상태 리스터 해제
    _stateListener?.cancel();
    // 연결 해제
    roboid.disconnect();
    chick.bleState = "";
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      // 화면이 mounted 되었을때만 업데이트 되게 함
      super.setState(fn);
    }
  }

  /* 연결 상태 갱신 */


  @override
  Widget build(BuildContext context) {
    // if(MediaQuery.of(context).size.width/MediaQuery.of(context).size.height < 1.7){
    //   size = false;
    // }

    print("위젯 전송 장치 ${widget.device}");
    // chick.nameChange = true;
    return Scaffold(
      appBar: appBar("이름 바꾸기 - 현재 이름 ${widget.device.name}", chick.bleState, context,true),
      body:
      // Center(
      //   child: Container(
      //     width:  (MediaQuery.of(context).size.width) * 0.90,
      //     child:
          Row(
            children: <Widget>[
              // OutlinedButton(
              //     onPressed: () {
              //       if (deviceState == BluetoothDeviceState.connected) {
              //         chick.bleState = "Connected";
              //         /* 연결된 상태라면 연결 해제 */
              //         roboid.disconnect();
              //       } else if (deviceState ==
              //           BluetoothDeviceState.disconnected) {
              //         chick.bleState = "Disconnected";
              //         /* 연결 해재된 상태라면 연결 */
              //         roboid.connect();
              //       }
              //     },
              //     child: Text(connectButtonText)),SizedBox(width: 40,),
              SizedBox(width: 40,),
              Container(
                child: TextField(
                  controller: _contentEditController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Label_text,
                  ),
                ),
                width: 600,
              ),
                  SizedBox(width: 40,),
                  ElevatedButton(onPressed: (){
                    FocusScope.of(context).unfocus();
                    scanResultList = [];
                    Name = "";
                    Mac = "";
                    if(_contentEditController.text.length > 0 && _contentEditController.text.length < 19){
                      name = _contentEditController.text;
                      List<int> word = utf8.encode(name);
                      // List<int> k = [];
                      // List<int> hex = [];
                      // for(int w in word){
                      //   k.add(w);
                      //   String change = HEX.encode(k);
                      //   hex.add(int.parse(change));
                      //   k = [];
                      // }
                      print("변환 코드 " + word.toString());
                      name_change = [0xe8,word.length,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                      for(int i=0;i<name.length;i++){
                        name_change[i+2] =word[i];
                      }

                      chick.nameChange = true;

                      Future.delayed(Duration(seconds: 1),() {
                        name_change = [0xf0,word.length,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                        hello = false;
                        chick.nameChange = true;
                      });
                      // Navigator.pop(context);
                      // if(go_home){
                      //   go_home = false;
                      //   Navigator.pop(
                      //     context,
                      //     // MaterialPageRoute(builder: (context) => MyHomePage()),
                      //   );
                      //
                      // }
                    }
                    else{
                      setState(() {
                        _contentEditController.text.length < 1 ? Label_text="바꿀 이름을 작성해 주세요!":Label_text="18자 이하로 이름을 지어주세요";
                        _contentEditController.text = "";

                      });
                    }


                  }, child: Text("변경하기"))
                  
                  // TextField(
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     labelText: '바꿀 이름을 작성해 주세요',
                  //   ),
                  // ),

            ],
          ),
      //   ),
      // )
    );
  }


  /* 각 캐릭터리스틱 정보 표시 위젯 */
  Widget characteristicInfo(BluetoothService r) {
    String name = '';
    String properties = '';
    // 캐릭터리스틱을 한개씩 꺼내서 표시
    for (BluetoothCharacteristic c in r.characteristics) {
      properties = '';
      name += '\t\t${c.uuid}\n';
      if (c.properties.write) {
        properties += 'Write ';
      }
      if (c.properties.read) {
        properties += 'Read ';
      }
      if (c.properties.notify) {
        properties += 'Notify ';
      }
      if (c.properties.writeWithoutResponse) {
        properties += 'WriteWR ';
      }
      if (c.properties.indicate) {
        properties += 'Indicate ';
      }
      name += '\t\t\tProperties: $properties\n';
    }
    return Text(name);
  }

  /* Service UUID 위젯  */
  Widget serviceUUID(BluetoothService r) {
    String name = '';
    name = r.uuid.toString();
    return Text(name);
  }

  /* Service 정보 아이템 위젯 */
  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      title: serviceUUID(r),
      subtitle: characteristicInfo(r),
    );
  }
}