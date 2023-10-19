import 'dart:async';
import 'package:ble_example/app-bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
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

// 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
StreamSubscription<BluetoothDeviceState>? _stateListener;

List<BluetoothService> bluetoothService = [];

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


class DeviceScreen extends StatefulWidget {
  DeviceScreen({Key? key, required this.device}) : super(key: key);
  // 장치 정보 전달 받기
  final BluetoothDevice device;

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> with TickerProviderStateMixin{
  // flutterBlue
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  // String bleState = "Searching...";
  // String bleState1 = "Searching...";
  int watchDogCount = 0;
  late BluetoothDevice device;
  // late BluetoothDeviceState state;
  bool isUpdated = true;
  bool sendStarted = false;
  late BuildContext test;
  String te = "";
  String na = "";
  int k=0;
  late final AnimationController rotate_st = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> animation_st =
  CurvedAnimation(parent: rotate_st, curve: Curves.linear);

  late final AnimationController rotate_te = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> animation_te =
  CurvedAnimation(parent: rotate_te, curve: Curves.linear);

  Color color = Colors.amber;

  @override
  initState() {
    // flutterBlue.stopScan();
    hello = false;
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
      if(event == "3"){
        setState(() {
          stateText = 'Disconnecting';
        });
      }
      if(event == "4"){
        setState(() { });
      }
      if(event == "5"){
        setState(() {
          print("play값 " + play.toString());
          if((chick_packet[7]>>7)&0x01 == 0){
            play = false;
          }
          else{
            play = true;
          }
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
    rotate_st.dispose();
    rotate_te.dispose(); // you need this
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
    return Scaffold(
      appBar: appBar("로봇 제어", chick.bleState, context,true),
      // drawer: Drawer(
      //     width: (MediaQuery.of(context).size.width) * 0.7,
      //     child: Row(children: [
      //       Container(
      //         width: (MediaQuery.of(context).size.width) * 0.05,
      //         color: Colors.transparent,
      //       ),
      //       Align(
      //         alignment: Alignment.center,
      //         child: FittedBox(
      //             child: Column(
      //               children: [
      //                 Image(
      //                   width: (MediaQuery.of(context).size.width) * 0.3,
      //                   image: AssetImage('assets/Forklift_name.png'),
      //                 ),
      //                Text(
      //                       chick.te,
      //                       style: TextStyle(
      //                         color: Colors.grey[400],
      //                         fontSize: 13,
      //                         fontFamily: 'NanumSquareRound',
      //                       ),
      //                     ),
      //               ],
      //             )
      //         )
      //       ),
      //       Container(
      //         width: (MediaQuery.of(context).size.width) * 0.02,
      //         color: Colors.transparent,
      //       ),
      //       Container(
      //         width: 3,
      //         height: (MediaQuery.of(context).size.height - 40) * 0.6,
      //         color: Color(0xfffdd507),
      //       ),
      //       Container(
      //         width: (MediaQuery.of(context).size.width) * 0.02,
      //         color: Colors.transparent,
      //       ),
      //       Container(
      //         width: (MediaQuery.of(context).size.width) * 0.7-(MediaQuery.of(context).size.width) * 0.4,
      //         child: ListView(
      //           shrinkWrap: true,
      //           padding: EdgeInsets.zero,
      //           children: <Widget>[
      //             // ListTile(
      //             //     leading: Icon(Icons.radar, color: Color(0xfffdd507)),
      //             //     title: Text(
      //             //       "baby chicken 연결",
      //             //       style: TextStyle(
      //             //         fontSize: 18.0,
      //             //         fontFamily: 'NanumSquareRound',
      //             //       ),
      //             //     ),
      //             //     onTap: () {
      //             //       if (chick.bleState1 == "Searching...") {
      //             //         _create();
      //             //       }
      //             //
      //             //     }),
      //             _Listmenu(context, Icons.sports_esports_outlined, 1, '조이 스틱',
      //                 chick, event),
      //             // _Listmenu(context, Icons.precision_manufacturing, 0, '모터 초기화',
      //             //     chick, event),
      //             // _Listmenu(context, Icons.smart_toy_outlined, 2, '행동 동작', chick,
      //             //     event),
      //             // _Listmenu(context, Icons.settings_outlined, 3, '직진 보정', chick,
      //             //     event),
      //           ],
      //         ),
      //       )
      //     ])),
      body: Center(
        child: Container(
          width:  (MediaQuery.of(context).size.width) * 0.90,
          child: Column(
            children: [
              OutlinedButton(
                  onPressed: () {
                    if (deviceState == BluetoothDeviceState.connected) {
                      chick.bleState = "Connected";
                      /* 연결된 상태라면 연결 해제 */
                      roboid.disconnect();
                    } else if (deviceState ==
                        BluetoothDeviceState.disconnected) {
                      chick.bleState = "Disconnected";
                      /* 연결 해재된 상태라면 연결 */
                      roboid.connect();
                    }
                  },
                  child: Text(connectButtonText)),
              // 치즈스틱 테스트용 코드
              // Stack(
              //   children: [
              //     Container(
              //       padding: EdgeInsets.fromLTRB(0, 10, 0, 80),
              //       width: 100,
              //       height: 325,
              //       child: Listview_sperated(chick),
              //       decoration: BoxDecoration(
              //         color: Color(0xffe7b604),
              //         border: Border.all(
              //             color: Color(0xfffdd507),
              //             style: BorderStyle.solid,
              //             width: 10),
              //         borderRadius: BorderRadius.all(
              //           Radius.circular(100),
              //         ),
              //       ),
              //     ),
              //     Positioned(
              //         top: 240,
              //         child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               primary: Colors.grey[300],
              //               shadowColor: Colors.grey[500],
              //               minimumSize: Size(100, 60),
              //               shape: CircleBorder(),
              //             ),
              //             onPressed: () {
              //               if (chick.soundClip.id & 1 == 1)
              //                 chick.soundClip.value = 0x80 + 0x0;
              //               else
              //                 chick.soundClip.value = 0x0;
              //             },
              //             child: Icon(Icons.music_off,
              //                 color: Colors.grey[600], size: 30)))
              //   ],
              // ),
              ShakeItem(autoPlay: st_autoPlay, shakeList: [ShakeOpacityConstant()], col: 0,rotation: rotate_st,animation: animation_st,),
              ShakeItem(autoPlay: te_autoPlay, shakeList: [ShakeOpacityConstant()], col: 1,rotation: rotate_te,animation: animation_te,),
              Row(
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width) * 0.55,
                    child: Center(
                        child: Column(
                          children: [
                            ElevatedButton(onPressed: (){}, child: Text("코드 시뮬레이션")),
                            Row(
                              children: [
                                ElevatedButton(onPressed: (){ setState(() {
                                  if(Choose_player != 0&& play){
                                    chick.chickplay.mode = 1;
                                    chick.play_stop.value = 0;
                                    chick.play_stop.id++;
                                  }
                                });Choose_player = 0;}, child: Text("학생")),
                                Container(
                                    width : 10
                                ),
                                ElevatedButton(onPressed: (){
                                  touch_te = 0;
                                  for(int k=0;k<8;k++){
                                    chick.chick_code[k] = chick_packet[k+8];
                                    teacher_packet[k*2] = (chick_packet[k+8] >> 4)&0x07;
                                    if((chick_packet[k+8] >> 4)&0x07!=0){
                                      touch_te++;
                                    }
                                    teacher_packet[k*2+1] = chick_packet[k+8]&0x07;
                                    if(chick_packet[k+8]&0x07!=0){
                                      touch_te++;
                                    }
                                  }
                                  setState(() { });}, child: Text("학생 -> 선생님")),
                              ],
                            ),
                           Row(
                                children: [
                                  ElevatedButton(onPressed: (){setState(() {
                                    if(Choose_player != 1 && play){
                                      chick.chickplay.mode = 0x00;
                                      chick.chickplay.id++;
                                      chick.chickplay.value = 0x08;
                                    }
                                  });Choose_player = 1;}, child: Text("선생님")),
                                  Container(
                                    width : 10
                                  ),
                                  ElevatedButton(onPressed: (){chick.send.value++;setState(() { });}, child: Text("선생님 -> 학생")),
                                ],
                            )
                          ],
                        )
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width) * 0.20,
                    height:(MediaQuery.of(context).size.width) * 0.20,
                    child: Choose_player == 0 ? input_code(context,rotate_st, animation_st) : input_code(context,rotate_te, animation_te),
                  )
                ],
              ),
              // FittedBox(
              //     child: Container(
              //         // color:Colors.red,
              //         // height: (MediaQuery.of(context).size.height - 40)*0.26,
              //         width:MediaQuery.of(context).size.width,
              //         child: Center(
              //           child: Stack(
              //             children: [
              //               Column(
              //                 children: [
              //                   // ShakeItem(autoPlay: _autoPlay, shakeList: [ShakeOpacityConstant()], col: 0,rotation: rotate_st,animation: animation_st,),
              //                   // ShakeItem(autoPlay: _autoPlay, shakeList: [ShakeOpacityConstant()], col: 1,rotation: rotate_te,animation: animation_te,),
              //                   // FittedBox(
              //                   //   child: Center(
              //                   //       child: Container(
              //                   //         width: (MediaQuery.of(context).size.height - 40) * 0.3,
              //                   //         height:(MediaQuery.of(context).size.height - 40) * 0.3,
              //                   //         child: Choose_player == 0 ? input_code(context,rotate_st, animation_st) : input_code(context,rotate_te, animation_te),
              //                   //       )
              //                   //   ),
              //                   // ),
              //                 ],
              //               ),
              //               // play ?  Blocks(context,_rotationController,_rotationAnimation) : Container(color: Colors.transparent,)
              //             ],
              //           ),
              //         )
              //     )
              //
              // ),
              // Expanded(
              //   flex: 5,
              //   child: Container(
              //     color: Colors.transparent,
              //   ),
              // ),

            ],
          ),
        ),
      )
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       /* 장치명 */
  //       title: Text(widget.device.name),
  //     ),
  //     body: Center(
  //         child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             /* 연결 상태 */
  //             Text('$stateText'),
  //             /* 연결 및 해제 버튼 */
  //             OutlinedButton(
  //                 onPressed: () {
  //                   if (deviceState == BluetoothDeviceState.connected) {
  //                     /* 연결된 상태라면 연결 해제 */
  //                     roboid.disconnect();
  //                   } else if (deviceState ==
  //                       BluetoothDeviceState.disconnected) {
  //                     /* 연결 해재된 상태라면 연결 */
  //                     roboid.connect();
  //                   }
  //                 },
  //                 child: Text(connectButtonText)),
  //           ],
  //         ),
  //
  //         /* 연결된 BLE의 서비스 정보 출력 */
  //         Expanded(
  //           child: ListView.separated(
  //             itemCount: bluetoothService.length,
  //             itemBuilder: (context, index) {
  //               return listItem(bluetoothService[index]);
  //             },
  //             separatorBuilder: (BuildContext context, int index) {
  //               return Divider();
  //             },
  //           ),
  //         ),
  //         Listview_sperated(chick,context,0),
  //         Listview_sperated(chick,context,1),
  //         Listview_sperated(chick,context,2),
  //         Listview_sperated(chick,context,3),
  //         Listview_sperated(chick,context,4),
  //         Listview_sperated(chick,context,5),
  //
  //       ],
  //     )),
  //   );
  // }
  Widget Listview_sperated(Chick chick) {
    final List<String> entries = <String>['소리\n중지','경고\n음','사이렌\n소리', '엔진\n소리', '방귀\n소리', '미션\n완료', '행복한\n기분','화난\n기분','슬픈\n기분','생일\n축하'];
    final List<int> mode = [0x20,0x30];
    final List<int> clip = [0,4,9,12,13,8,1,2,3,6];
    final radius = (MediaQuery.of(context).size.width)*0.12;

    return ListView.separated(
        padding: const EdgeInsets.all(8.0),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return ElevatedButton(
            onPressed: () {
              if (index < 4) {
                chick.soundClip.mode = mode[0];
              }
              else {
                chick.soundClip.mode = mode[1];
              }
              chick.soundClip.value = clip[index];
            }, child: Center(
              child: Text('${entries[index]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 11,))),
            style: ElevatedButton.styleFrom(
              primary: Color(0xffffdb96),
              shadowColor: Colors.black54,
              fixedSize: Size(MediaQuery
                  .of(context)
                  .size
                  .width * 0.07, MediaQuery
                  .of(context)
                  .size
                  .width * 0.07,),
              shape: CircleBorder(),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
    const Divider(height: 10.0, color: Colors.transparent),
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


class ShakeItem extends StatelessWidget {
  final bool autoPlay;
  final Duration? duration;
  final int col;
  final List<ShakeConstant> shakeList;
  final AnimationController rotation;
  final Animation<double> animation;
  const ShakeItem({Key? key,required this.col, required this.shakeList,this.autoPlay = false,this.duration, required this.rotation, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: shakeList.map((shakeConstant){
        return ShakeWidget(
            duration: duration,
            shakeConstant: shakeConstant,
            autoPlay: autoPlay,
            child: Row(
              children: [
                col == 0 ? Container(width: 50, color : Choose_player == 0 ? Colors.yellow : Colors.transparent, child: Text("학생"),) : Container(width: 50,color : Choose_player == 1 ? Colors.yellow : Colors.transparent, child: Text("선생님"),),
                _Blocks(context, col,rotation, animation),
              ],
            )
        );
      }).toList(),
    );
  }
}

Widget print_code(int col, int index,AnimationController _rotationController,Animation<double> _rotationAnimation){
  final List<String> entries = <String>["","assets/input/foward.png","assets/input/backward.png","assets/input/turn_left.png","assets/input/turn_right.png","assets/code_icon/action.png","assets/input/repeat.png",];
  int first = ((index)/2).toInt()+8;
  int second = ((index)/2).floor()+8;
  if((chick_packet[7]>>6)&0x01 == 1){
    ind = (chick_packet[16])&0x0f;
    re_ind= (chick_packet[16]>>4)&0x0f;
  }
  if((chick_packet[7]>>7)&0x01 == 0){
    ind = -1;
    re_ind = -1;
    re = 0;
  }
  // print( "나는 선생님 입력 코드 : ${chick.chick_code}");
  // print("오류의 이유 : " + ind.toString() + " " + re_ind.toString());

  if((chick_packet[first]>>4) > 6 || (chick_packet[second]&0x07) > 6){
    return Container(color: Colors.transparent);
  }
  else if(col == 0){
    return
      ( index)%2 ==  0?
      (chick_packet[first] == 0 ? Container(color: Colors.transparent,) : Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: Choose_player == 0 ? (ind ==  index ? Color(0xffffd600) : re_ind == index && re_ind != 0 ? Colors.green : Colors.transparent) : Colors.transparent,
            ),
          ),
          child: Choose_player == 0 ? re == 1 ? (re_ind == index && re_ind != 0 ? RotationTransition(
            turns: _rotationAnimation,
            child: Image.asset(entries[chick_packet[first]>>4]),
          ) : Image.asset(entries[chick_packet[first]>>4])) : Image.asset(entries[chick_packet[first]>>4]): Image.asset(entries[chick_packet[first]>>4])
        // Image.asset(,entries[chick_packet[first]>>4]),
      ) )
          : ( chick_packet[second]&0x07 == 0 ? Container(color: Colors.transparent,) :Container(
          decoration: col == 0 ? BoxDecoration(
            border: Border.all(
              width: 3,
              color: Choose_player == 0 ? (ind == index ? Color(0xffffd600) : re_ind == index && re_ind != 0 ? Colors.green : Colors.transparent) : Colors.transparent,
            ),
          ) : BoxDecoration(),
          child: Choose_player == 0 ? (re == 1 ? (re_ind ==  index&& re_ind != 0 ? RotationTransition(
            turns: _rotationAnimation,
            child: Image.asset(entries[chick_packet[second]&0x07]),
          ) : Image.asset(entries[chick_packet[second]&0x07])) : Image.asset(entries[chick_packet[second]&0x07]) ): Image.asset(entries[chick_packet[second]&0x07])
        // Image.asset(entries[chick_packet[second]&0x07])
      ));
  }
  else{
    return
      // (index)%2 ==  0?
    (teacher_packet[index] == 0 ? Container(color: Colors.transparent,) : Container(
        decoration: col == 1 ? BoxDecoration(
          border: Border.all(
            width: 3,
            color: Choose_player == 1 ? (ind == index ? Colors.red : re_ind == index && re_ind != 0 ? Colors.green : Colors.transparent) : Colors.transparent,
          ),
        ) : BoxDecoration(),
        child: Choose_player == 1 ? re == 1 ? (re_ind == index && re_ind != 0 ? RotationTransition(
          turns: _rotationAnimation,
          child: Image.asset(entries[teacher_packet[index]]),
        ) : Image.asset(entries[teacher_packet[index]])) : Image.asset(entries[teacher_packet[index]]): Image.asset(entries[teacher_packet[index]])
      // Image.asset(,entries[chick_packet[first]>>4]),
    ) );
    //     : ( teacher_packet[second-7]&0x07 == 0 ? Container(color: Colors.transparent,) :Container(
    //     decoration: BoxDecoration(
    //       border: Border.all(
    //         width: 3,
    //         color: ind == index ? Color(0xffffd600) : re_ind == index && re_ind != 0 ? Colors.green : Colors.transparent,
    //       ),
    //     ),
    //     child: re == 1 ? (re_ind ==  index&& re_ind != 0 ? RotationTransition(
    //       turns: _rotationAnimation,
    //       child: Image.asset(entries[teacher_packet[second-7]&0x07]),
    //     ) : Image.asset(entries[teacher_packet[second-7]&0x07])) : Image.asset(entries[teacher_packet[second-7]&0x07])
    //   // Image.asset(entries[chick_packet[second]&0x07])
    // ));
  }
}

Widget input_code(BuildContext context,AnimationController _rotationController,Animation<double> _rotationAnimation ){
  final List<String> entries = <String>["assets/code_icon/play.png","assets/code_icon/foward.png","assets/code_icon/backward.png","assets/code_icon/turn_left.png","assets/code_icon/turn_right.png","assets/code_icon/action.png","assets/code_icon/repeat.png","assets/code_icon/delete_all.png"];
  final List<String> entries_off = <String>["assets/code_icon/stop.png","assets/code_icon/foward_off.png","assets/code_icon/backward_off.png","assets/code_icon/turn_left_off.png","assets/code_icon/turn_right_off.png","assets/code_icon/action_off.png","assets/code_icon/repeat_off.png","assets/code_icon/delete_all_off.png"];



  return Column(
    children: [
      Expanded(
          flex: 33,
          child: Row(
            children: [
              Expanded(
                  flex: 34,
                  child: Container(color: Colors.transparent,
                    child: play ?  Blocks(context,_rotationController,_rotationAnimation) : Container(color: Colors.transparent,)
                    ,)
              ),
              Expanded(
                  flex: 34,
                  child: GestureDetector(
                    onTap: (){
                      if(!play && Choose_player == 0){
                        chick.chickplay.mode = 0x00;
                        chick.chickplay.id++;
                        chick.chickplay.value = 0x01;
                      }
                      else if(!play && Choose_player == 1 && touch_te<16){
                        teacher_packet[touch_te] = 1;
                        touch_te += 1;
                      }
                    },
                    child: play ?  Image.asset(entries_off[1]):Image.asset(entries[1]),
                  )
              ),
              Expanded(
                  flex: 33,
                  child: GestureDetector(

                    onTap: (){
                      if(!play && Choose_player == 0){
                        chick.chickplay.mode = 0x00;
                        chick.chickplay.id++;
                        chick.chickplay.value = 0x05;
                      }
                      else if(!play && Choose_player == 1&& touch_te<16){
                        teacher_packet[touch_te] = 5;
                        touch_te += 1;
                      }
                    },
                    child:play ? Image.asset(entries_off[5]): Image.asset(entries[5]),
                  )
              ),
            ],
          )
      ),
      Expanded(
          flex: 34,
          child:  Row(
            children: [
              Expanded(
                  flex: 34,
                  child:GestureDetector(

                    onTap: (){
                      if(!play && Choose_player == 0) {
                        chick.chickplay.mode = 0x00;
                        chick.chickplay.id++;
                        chick.chickplay.value = 0x03;
                      }
                      else if(!play && Choose_player == 1&& touch_te<16){
                        teacher_packet[touch_te] = 3;
                        touch_te += 1;
                      }
                    },
                    child: play ?  Image.asset(entries_off[3]):Image.asset(entries[3]),
                  )
              ),
              Expanded(
                  flex: 34,
                  child: GestureDetector(

                    onTap: (){
                      if(Choose_player == 0){
                        // play = true;
                        chick.chickplay.mode = 0x00;
                        chick.chickplay.id++;
                        chick.chickplay.value = 0x08;

                      }
                      else if(Choose_player == 1 && !play){

                        chick.chickplay.mode = 1;
                        chick.play_stop.value = 1;
                        chick.play_stop.id++;
                      }
                      else if (Choose_player == 1 && play){
                        chick.chickplay.mode = 1;
                        chick.play_stop.value = 0;
                        chick.play_stop.id++;
                      }
                    },
                    child: play ? Image.asset(entries_off[0]) : Image.asset(entries[0]),
                  )
              ),
              Expanded(
                  flex: 33,
                  child: GestureDetector(

                    onTap: (){
                      if(!play && Choose_player == 0){
                        chick.chickplay.mode = 0x00;
                        chick.chickplay.id++;
                        chick.chickplay.value = 0x04;
                      }
                      else if(!play && Choose_player == 1&& touch_te<16){
                        teacher_packet[touch_te] = 4;
                        touch_te += 1;
                      }
                    },
                    child: play ? Image.asset(entries_off[4]):Image.asset(entries[4]),
                  )
              ),
            ],
          )
      ),
      Expanded(
          flex: 33,
          child:  Row(
            children: [
              Expanded(
                  flex: 34,
                  child:GestureDetector(

                    onTap: (){
                      if(!play && Choose_player == 0){
                        chick.chickplay.mode = 0x00;
                        chick.chickplay.id++;
                        chick.chickplay.value = 0x06;
                      }
                      else if(!play && Choose_player == 1&& touch_te<16){
                        teacher_packet[touch_te] = 6;
                        touch_te += 1;
                      }
                    },
                    //                  ((chick_packet[8]>>4)) != 0
                    // ((chick_packet[8]>>4)) == 0?  Image.asset(entries_off[6]):
                    child:  play ? Image.asset(entries_off[6]): Image.asset(entries[6]),
                  )
              ),
              Expanded(
                  flex: 34,
                  child: GestureDetector(

                      onTap: (){
                        if(!play && Choose_player == 0){
                          chick.chickplay.mode = 0x00;
                          chick.chickplay.id++;
                          chick.chickplay.value = 0x02;
                        }
                        else if(!play && Choose_player == 1&& touch_te<16){
                          teacher_packet[touch_te] = 2;
                          touch_te += 1;
                        }
                      },
                      child:Container(
                        child:  play ?  Image.asset(entries_off[2]):Image.asset(entries[2]),
                      )
                  )
              ),
              Expanded(
                  flex: 33,
                  child: Container(
                    child: GestureDetector(
                      child: play ?  Image.asset(entries_off[7]) : Image.asset(entries[7]),
                      // onTap: (){
                      //   if(!play && Choose_player == 1){
                      //     te_autoPlay = true;
                      //   }
                      // },
                      // onTapUp: (TapUpDetails){
                      //   if(!play && Choose_player == 1){
                      //     te_autoPlay = false;
                      //   }
                      // },
                      onLongPressDown: (LongPressDownDetails){
                        if(!play && Choose_player == 0){
                          chick.chickplay.id++;
                          chick.chickplay.value = 7;

                        }
                        else if(!play && Choose_player == 1){
                          te_autoPlay = true;
                        }
                      },
                      onLongPress: (){
                        if(!play && Choose_player == 0){
                          st_autoPlay = true;
                          chick.Pressed = false;
                          chick.chickplay.id++;
                          chick.chickplay.value = 10;
                        }
                        else if(!play && Choose_player == 1){
                          te_autoPlay = false;
                          touch_te = 0;
                          teacher_packet = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
                          chick.chick_code = [0,0,0,0,0,0,0,0];
                        }
                      },
                      onLongPressUp: (){
                        if(!play && Choose_player == 0){
                          chick.chickplay.id++;
                          chick.chickplay.value = 7;
                          st_autoPlay = false;
                        }
                        else if(!play && Choose_player == 1){
                          te_autoPlay = false;

                        }
                      },
                      onLongPressEnd: (LongPressEndDetails) {
                        if(!play && Choose_player == 0){
                          chick.chickplay.id++;
                          chick.chickplay.value = 7;
                          st_autoPlay = false;
                        }
                      },
                      onLongPressMoveUpdate: (LongPressDownDetails){
                        if(!play && Choose_player == 0){
                          if(LongPressDownDetails.localOffsetFromOrigin.dx > 20){
                            chick.chickplay.id++;
                            chick.chickplay.value = 7;
                            st_autoPlay = false;
                          }

                          else if(LongPressDownDetails.localOffsetFromOrigin.dy > 20){
                            chick.chickplay.id++;
                            chick.chickplay.value = 7;
                            st_autoPlay = false;
                          }
                        }
                        else if(!play && Choose_player == 1){
                          if(LongPressDownDetails.localOffsetFromOrigin.dx > 20){
                            te_autoPlay = false;
                          }

                          else if(LongPressDownDetails.localOffsetFromOrigin.dy > 20){
                            te_autoPlay = false;
                          }
                        }
                      },


                    ),)
              ),
            ],
          )
      ),
    ],
  );
}

Widget _Blocks(BuildContext context, int col,AnimationController _rotationController,Animation<double> _rotationAnimation){
  if(MediaQuery.of(context).size.width/MediaQuery.of(context).size.height < 1.7){
    size = false;
  }
  return Container(
    color: Colors.transparent,
    height: (MediaQuery.of(context).size.height-40) * 0.13,
    width: (MediaQuery.of(context).size.width) * 0.8,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0.0),
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount:16,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          width: (MediaQuery.of(context).size.height-40) * 0.115,
          color: Colors.transparent,
          child: Center(
              child: print_code(col, index,_rotationController,_rotationAnimation)
          ),
        );
      },
      // separatorBuilder: (BuildContext context, int index) => VerticalDivider(width: 10, color: Colors.transparent),

    ),
  );
}

Widget Blocks(BuildContext context,AnimationController _rotationController,Animation<double> _rotationAnimation){
  final List<String> entries = <String>["","assets/input/foward.png","assets/input/backward.png","assets/input/turn_left.png","assets/input/turn_right.png","assets/code_icon/action.png","assets/input/repeat.png",];

  if((chick_packet[7]>>6)&0x01 == 0){
    pp = chick_packet[16]&0x0f;
    re = (chick_packet[16]>>4)&0x01;
  }
  if((chick_packet[7]>>7)&0x01 == 0){
    re = 0;
  }
  print("반복하는가? "+pp.toString());



  return Container(

    height: (MediaQuery.of(context).size.height-40) * 0.9,
    width: (MediaQuery.of(context).size.height-40) * 0.9,
  );
}

Widget Listview_sperated(Chick chick) {
  final List<String> entries = <String>['경고\n음','사이렌\n소리', '엔진\n소리', '방귀\n소리', '미션\n완료', '행복한\n기분', '화난\n기분', '슬픈\n기분', '생일\n축하'];
  final List<int> clip = [0x04, 0x0a, 0x0c,0x0e, 0x23, 0x30, 0x31, 0x32, 0x35];

  return ListView.separated(
    padding: const EdgeInsets.all(8.0),
    itemCount: entries.length,
    itemBuilder: (BuildContext context, int index) {
      return ElevatedButton(
        onPressed: () {
         if(chick.soundClip.id & 1 == 1) chick.soundClip.value = 0x80 + clip[index];
         else chick.soundClip.value = clip[index];

        },
        child: Center(
            child: Text('${entries[index]}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 11,fontFamily: 'NanumSquareRound',))),
        style: ElevatedButton.styleFrom(
          primary: Color(0xfffdd507),
          shadowColor: Colors.grey[500],
          fixedSize: Size(100, 55),
          shape: CircleBorder(),
        ),
      );
    },
    separatorBuilder: (BuildContext context, int index) =>
    const Divider(height: 10.0, color: Colors.transparent),
  );
}