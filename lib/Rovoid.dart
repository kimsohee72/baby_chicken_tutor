import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'Chick.dart';
import 'device_screen.dart';
import 'main.dart';
const _myService = "00009001-9c80-11e3-a5e2-0800200c9a66";
const _myChar = "0000900a-9c80-11e3-a5e2-0800200c9a66";
List<int> chick_packet = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
List<int> teacher_packet = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
bool play = false;
bool turbo = false;
bool repeat = false;
bool repeat_n = false;
// bool size = true;
int repeat_index = 0;
int x = 0;
int repeated = 0;
int st = ((chick_packet[16]>>5)&0x07);
EventBus eventBus = EventBus();
Roboid roboid = Roboid();

class Roboid{
  late BluetoothCharacteristic simulacra;
  bool isUpdated = true;
  bool sendStarted = false;
  int watchDogCount = 0;

  setBleConnectionState(BluetoothConnectionState event) {
    switch (event) {
      case BluetoothConnectionState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        connectButtonText = 'Connect';
        break;
      // case BluetoothDeviceState.disconnecting:
      //   stateText = 'Disconnecting';
      //   break;
      case BluetoothConnectionState.connected:
        stateText = 'Connected';
        // 버튼 상태 변경
        connectButtonText = 'Disconnect';
        break;
      // case BluetoothDeviceState.connecting:
      //   stateText = 'Connecting';
      //   break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    eventBus.fire("1");
  }

  /* 연결 시작 */
  Future<bool> connect() async {
    Future<bool>? returnValue;
    eventBus.fire("2");

    /*
      타임아웃을 15초(15000ms)로 설정 및 autoconnect 해제
       참고로 autoconnect가 true되어있으면 연결이 지연되는 경우가 있음.
     */
    await dev
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {
      //타임아웃 발생
      //returnValue를 false로 설정
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //연결 상태 disconnected로 변경
      setBleConnectionState(BluetoothConnectionState.disconnected);
    }).then((data) async {
      bluetoothService.clear();
      if (returnValue == null) {
        //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
        debugPrint('connection successful');
        List<BluetoothService> services = await dev.discoverServices();
        _getService(services);

        await simulacra.setNotifyValue(true);
        int a = 0;
          int i=0;
          final subscription = simulacra.value.listen((value) {
            /*print(DateTime.now().millisecond);*/

            if(value[0] == 0x10){
              chick_packet = value;
              x++;
              print("a의 값은 " + x.toString());
            }
            print("읽어오는 패킷 : "+chick_packet.toString());
            repeat_n = false;
            eventBus.fire("4");
            if((chick_packet[7]>>7)&0x01 == 1){

              if(((chick_packet[16]>>5)&0x07) != st) {
                repeat_n = true;
              }
              st = ((chick_packet[16]>>5)&0x07);

            }
            if(a != (chick_packet[7]>>7)&0x01){
              eventBus.fire("5");
            }
            a= (chick_packet[7]>>7)&0x01;

            // print("첫번째 값 :" + ((value[8]>>4)).toString());
            // print("두번째 값 :" + ((value[8]&0x07)).toString());
            // print("세번째 값 :" + ((value[9]>>4)).toString());
            // print("넷번째 값 :" + ((value[9]&0x07)).toString());
            // print("다섯번째 값 :" + ((value[10]>>4)).toString());
            // print("여섯번째 값 :" + ((value[10]&0x07)).toString());
            // print("일곱번째 값 :" + ((value[11]>>4)).toString());
            // print("여덟번째 값 :" + ((value[11]&0x07)).toString());
            // print("아홉번째 값 :" + ((value[12]>>4)).toString());
            // print("열번째 값 :" + ((value[12]&0x07)).toString());
            // print("열하나번째 값 :" + ((value[13]>>4)).toString());
            // print("열둘번째 값 :" + ((value[13]&0x07)).toString());
            // print("열세번째 값 :" + ((value[14]>>4)).toString());
            // print("열네번째 값 :" + ((value[14]&0x07)).toString());
            // print("열다섯번째 값 :" + ((value[15]>>4)).toString());
            // print("열여섯번째 값 :" + ((value[15]&0x07)).toString());
            int type = value[0];

            if((type == 0x10 || type == 0xe9) && x == 5) {  // Cheese Packet?
              List<int> packet =  chick.getMotoringPacket();
              print("전송 패킷" + packet.toString());
              simulacra.write(packet, withoutResponse: true);
              x=0;
            }

            // clear watch dog
            watchDogCount = 0;
          }
          );
        dev.cancelWhenDisconnected(subscription);
        dev.connectionState.listen((BluetoothConnectionState state) async {
          if (state == BluetoothConnectionState.disconnected) {
            chick.bleState = "Disconnected";
            eventBus.fire("connection");
            // await dev.connect();
          }
          else{
            chick.bleState = "Connected";
            eventBus.fire("connection");
          }
        });

        print('start discover service');
        List<BluetoothService> bleServices =
        await dev.discoverServices();
        // bluetoothService = bleServices;
        // 각 속성을 디버그에 출력
        for (BluetoothService service in bleServices) {
          print('============================================');
          print('Service UUID: ${service.deviceId}');
          for (BluetoothCharacteristic c in service.characteristics) {
            print('\tcharacteristic UUID: ${c.descriptors.toString()}');
            print('\t\twrite: ${c.properties.write}');
            print('\t\tread: ${c.properties.read}');
            print('\t\tnotify: ${c.properties.notify}');
            print('\t\tisNotifying: ${c.isNotifying}');
            print(
                '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
            print('\t\tindicate: ${c.properties.indicate}');
          }
        }
        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }

  /* 연결 해제 */
  void disconnect() {
    try {
      // eventBus.fire("3");
      // dev.cancelWhenDisconnected(simulacra);
      dev.disconnect();
    } catch (e) {}
  }
  bool _getService(List<BluetoothService> services) {
    for (BluetoothService s in services) {
      if (s.uuid.toString() == _myService) {
        var characteristics = s.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _myChar) {
            simulacra = c;
            return true;
          }
        }
      }
    }
    return false;
  }
}

class Effector {
  int value = 0;

  void reset(){
    value = 0;
  }
}

class Command {
  int _value = 0;
  int _id = 0;
  int _mode = 0;

  // getter and setter
  get id => _id;
  get value => _value;
  get mode => _mode;

  // setter
  set value(val) {
    _value = val;
    _id++;
  }
  set mode(mod){
    _mode = mod;
  }
  set id(i){
    _id = i;
  }

  void reset(){
    value = 0;
    id = 0;
    mode = 0;
  }
}
class eyeCommand {
  int _lid = 0;
  int _lmode = 1;
  int _rid = 0;
  int _rmode = 1;
  int _Rred =7;
  int _Rgreen = 100;
  int _Rblue = 100;
  int _Lred =7;
  int _Lgreen = 100;
  int _Lblue = 100;

  // getter and setter
  get lid => _lid;
  get lmode => _lmode;
  get rid => _rid;
  get rmode => _rmode;
  get Rred => _Rred;
  get Rblue => _Rblue;
  get Rgreen => _Rgreen;
  get Lred => _Lred;
  get Lblue => _Lblue;
  get Lgreen => _Lgreen;

  // setter
  set lmode(mod){
    _lmode = mod;
  }
  set lid(i){
    _lid = i;
  }
  set rmode(mod){
    _rmode = mod;
  }
  set rid(i){
    _rid = i;
  }
  set Rred(r){
    _Rred = r;
  }
  set Rgreen(g){
    _Rgreen = g;
  }
  set Rblue(b){
    _Rblue = b;
  }
  set Lred(r){
    _Lred = r;
  }
  set Lgreen(g){
    _Lgreen = g;
  }
  set Lblue(b){
    _Lblue = b;
  }

  void reset(){
    lid = 0;
    lmode = 1;
    rid = 0;
    rmode = 1;
    Rred =7;
    Rgreen = 100;
    Rblue = 100;
    Lred =7;
    Lgreen = 100;
    Lblue = 100;
  }

}

class RoboidInfo {
  int appearance = 0;
  int rssi = 0;
  var name = 'Cheese Stick';
  var address = '';
  var uuid = '';
  var mfg = '';
  int model = 0;
}