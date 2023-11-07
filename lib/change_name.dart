import 'dart:async';
import 'dart:convert';
import 'package:ble_example/app-bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'Chick.dart';
import 'Rovoid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  bool loading = false;
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
    // 연결 시작
    roboid.connect();
    eventBus.on().listen((event) {
      if(event == "connection"){
        print("연결상태 변함");
        setState((){});
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

        Future.delayed(Duration(seconds: 2),() {
          hello = false;
          Navigator.pop(context);
        });
      }

    });
  }

  @override
  void dispose() {
    // 상태 리스터 해제
    // state?.cancel();
    // 연결 해제
    roboid.disconnect();
    chick.bleState = "";
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBar("이름 바꾸기", chick.bleState, context,true),
      body:AbsorbPointer
      (
        absorbing: loading,
          child :Stack(
        children: [
          Row(
            children: <Widget>[
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
                scanResultList = {};
                Name = "";
                Mac = "";
                if(_contentEditController.text.length > 0 && _contentEditController.text.length < 19){
                  loading = true;
                  name = _contentEditController.text;
                  List<int> word = utf8.encode(name);
                  print("변환 코드 " + word.toString());
                  name_change = [0xe8,word.length,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                  for(int i=0;i<name.length;i++){
                    name_change[i+2] =word[i];
                  }
                  hello = true;
                  chick.nameChange = true;
                  print("이름 변경하기를 희망함");
                  //
                  Future.delayed(Duration(seconds: 1),() {
                    name_change = [0xf0,word.length,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                    hello = false;
                    print("이름 변경하기가 완료됨");
                    chick.nameChange = true;
                  });
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
          Visibility(
              visible: loading,
              child:  Stack(
                children: [
                  // Container(
                  //   color: Colors.grey,
                  // ),
                  Center(
                    //로딩바 구현 부분
                    child: SpinKitPouringHourGlassRefined( // FadingCube 모양 사용
                      color: Colors.blue, // 색상 설정
                      size: 50.0, // 크기 설정
                      duration: Duration(seconds: 2), //속도 설정
                    ),
                  ),
                ],
              )
          ),
        ],
      )
    )
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