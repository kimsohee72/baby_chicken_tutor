import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Chick.dart';
import 'app-bar.dart';
import 'Rovoid.dart';
import 'change_name.dart';
import 'device_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isScanning = false;
  bool _isVisible = false;
  String choose = "CHICK 선택해 주세요!";
  int k = 0;

  late BluetoothDevice choose_dev;
  @override
  initState() {
    print("초기화의 문제 발생");
    super.initState();
    // 블루투스 초기화
    initBle();
    // flutterBlue.stopScan();
    permission();
    scanResultList = [];
    // scan();
    chick_packet = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
  }

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> status =
    await [Permission.location].request(); // [] 권한배열에 권한을 작성

    if (await Permission.location.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  void initBle() {
    // BLE 스캔 상태 얻기 위한 리스너
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState(() {});
    });
    // Timer.periodic(Duration(seconds: 4),(timer){
    //   print("안녕");
    //   _isVisible = !_isVisible;
    //   setState(() {
    //     scan();
    //   });
    // });
  }

  /*
  스캔 시작/정지 함수
  */
  scan() async {
    if (!_isScanning) {
      // 스캔 중이 아니라면
      // 기존에 스캔된 리스트 삭제
      scanResultList.clear();
      // 스캔 시작, 제한 시간 4초
      flutterBlue.startScan(timeout: Duration(seconds: 1));
      // 스캔 결과 리스너
      flutterBlue.scanResults.listen((results) {
        for(ScanResult r in results){
          int i = 0;

          if(r.advertisementData.manufacturerData[0xf138].toString().contains("[32")){
            log(r.device.name);
            for(ScanResult a in scanResultList){
              if(a.device.id == r.device.id){
                i++;
              }
            }
            if(i==0){
              if(r.rssi>-80){
                scanResultList.add(r);
                print(r.advertisementData.manufacturerData.toString());
              }
            }
          }
        }
        // UI 갱신
        setState(() {
          print("이전 이름이 출력되는 이유는 " + scanResultList[0].device.name.toString());
        });
      });
    } else {
      // 스캔 중이라면 스캔 정지
      print("스캔 중이라면 스캔 정지");
      flutterBlue.stopScan();
    }
  }

  /*
   여기서부터는 장치별 출력용 함수들
  */
  /*  장치의 신호값 위젯  */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* 장치의 MAC 주소 위젯  */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  /* 장치의 명 위젯  */
  Widget deviceName(ScanResult r) {
    String name = '';

    if (r.device.name.isNotEmpty) {
      // device.name에 값이 있다면
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      // advertisementData.localName에 값이 있다면
      name = r.advertisementData.localName;
    } else {
      // 둘다 없다면 이름 알 수 없음...
      name = 'N/A';
    }
    return Text(name);
  }

  /* BLE 아이콘 위젯 */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }

  /* 장치 아이템을 탭 했을때 호출 되는 함수 */
  void onTap(ScanResult r) {
    // 단순히 이름만 출력
    print('${r.device.name}');
    // choose = r.device.name + "\n" + bb;
    Name = r.device.name;
    Mac = r.device.id.id;
    choose_dev = r.device;
    setState(() {});

  }

  /* 장치 아이템 위젯 */
  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  //새로고침
  void _onRefresh() async{
    // scan();
    await Future.delayed(Duration(milliseconds: 1000)); //1초를 기다린 후 새로고침한다.
    //이 부분에 새로고침 시 불러올 기능을 구현한다.
    _refreshController.refreshCompleted();
  }

  //무한 스크롤
  void _onLoading() async{
    await Future.delayed(Duration(milliseconds: 1000)); //1초를 기다린 후 새로운 데이터를 불러온다.
    //이부분에 데이터를 계속 불러오는 기능을 구현한다.
    //리스트뷰를 사용한다면 간단한 예로 list.add를 이용하여 데이터를 추가시켜준다.
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {

    chick_packet = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    chick.chickplay.value = 0;
    chick.chickplay.id = 0;
    chick.play_stop.value = 0;


    return Scaffold(
      appBar: appBar(choose,chick.bleState,context,false),
        body:Stack(
          children: [
          Align(
          alignment: Alignment.centerLeft,
          child:Container(
              // color: Colors.green,
              width: (MediaQuery.of(context).size.width) * 0.5,
              height:(MediaQuery.of(context).size.width) * 0.35,
              child: Column(
                children: [
                  Text(Name,style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
                  Text(Mac,style: TextStyle(
                    fontSize: 20,
                  )),
                  Container(
                    height: (MediaQuery.of(context).size.height - 40)*0.1,
                  ),
                  ElevatedButton(onPressed: Name == "" ? null :  (){
                    flutterBlue.stopScan();
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeviceScreen(device: choose_dev)),
                    );
                  }, child: Text("연결하기")),
                  ElevatedButton(onPressed: Name == "" ? null :(){

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeName(device: choose_dev)),
                    );

                  }, child: Text("이름 바꾸기")),
                  ElevatedButton(onPressed: _isScanning ? null :(){
                    scan();
                    setState(() {
                      // scanResultList = [];
                      Mac = "";
                      Name = "";
                    });
                  }, child: Text("찾기"))
                ],
              ),
            )),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: (MediaQuery.of(context).size.width) * 0.5,

                child:Container(
                  // color: Colors.red,
                  height:(MediaQuery.of(context).size.width) * 0.35,
                  width: (MediaQuery.of(context).size.width) * 0.4,
                  child: SmartRefresher(
                      enablePullDown: true,	// 아래로 당겨서 새로고침 할 수 있게 할건지의 유무를 결정
                      enablePullUp: true, // 위로 당겨서 새로운 데이터를 불러올수 있게 할건지의 유무를 결정
                      controller: _refreshController,
                      onRefresh: _onRefresh,	// 새로고침을 구현한 함수
                      // onLoading: _onLoading,	// 무한스크롤을 구현한 함수

                      child:
                      ListView.separated(
                        itemCount: scanResultList.length,
                        itemBuilder: (context, index) {
                          return listItem(scanResultList[index]);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider();
                        },
                      )

                  ),
                )
              ),
            )
          ],
        )
    );
  }
  // Widget build(BuildContext context) {
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.title),
  //     ),
  //     body:
  //     Center(
  //       /* 장치 리스트 출력 */
  //       child: ListView.separated(
  //         itemCount: scanResultList.length,
  //         itemBuilder: (context, index) {
  //           return listItem(scanResultList[index]);
  //         },
  //         separatorBuilder: (BuildContext context, int index) {
  //           return Divider();
  //         },
  //       ),
  //     ),
  //     /* 장치 검색 or 검색 중지  */
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: scan,
  //       // 스캔 중이라면 stop 아이콘을, 정지상태라면 search 아이콘으로 표시
  //       child: Icon(_isScanning ? Icons.stop : Icons.search),
  //     ),
  //   );
  // }
}
