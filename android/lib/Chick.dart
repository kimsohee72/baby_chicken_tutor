
import 'dart:convert';
import 'dart:typed_data';
import "package:hex/hex.dart";
import 'package:convert/convert.dart';
import 'package:ble_example/Rovoid.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Chick chick = Chick();
late BluetoothDevice dev;
late String name;
late List<int> name_change = [];
bool hello = false;
List<ScanResult> scanResultList = [];
String Name = "";
String Mac = "";
BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

class Chick extends Roboid {

  late final List devices;
  final type = Effector();
  final soundClip = Command();
  final dummy = Effector();
  final chickplay = Command();
  final play_stop = Command();
  final send = Effector();
  late List<int> chick_code = [0, 0, 0, 0, 0, 0, 0, 0];

  // for balancing slider
  bool balancing = false;
  int slider = 0;
  bool saveBalance = false;
  bool clearSettings = false;
  bool nameChange = false;
  bool reset = false;
  bool turn_to_home = false;
  bool boolReset = false;
  bool find = false;
  bool Pressed = false;
  String bleState = "";

  // motor initialization
  bool factoryMode = false;
  bool testMotorMode = false;
  int initMotorOld = 0;
  int initMotor = 0;
  int ticks = 0;
  int repeat = 0;

  // void disconnect(){
  //   super.disconnect();
  // }

  // void create() {
  //   super.create();
  //   type.value = 0x51;
  //   devices = [type, wheelLeft, wheelRight, chickSpeed, chickPosition,
  //     balance, servoOff, wheelAction, chickAction, dummy, dummy, dummy,
  //     dummy, dummy, dummy, dummy, dummy, dummy, dummy, behavior];
  // }
  // empty packet
  List<int> emptyPacket = [0x50, 0, 0, 0, 180, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  List<int> getMotoringPacket() {
    List<int> motorPacket = List.generate(20, (index) => index == 0 ? 0x20 : 0);
    if (hello) {
      motorPacket[0]=0;
      if (nameChange) {
        print("이름을 변경하고 싶어요");
        motorPacket = name_change;
        nameChange = false;
      }
      return motorPacket;
    }
    else if(!hello && nameChange){
      print("리셋을 진행합니다");
        motorPacket = name_change;
        nameChange = false;
        eventBus.fire("이름 변경 됨");

      return motorPacket;
    }
    else {
      for (int p = 0; p < 8; p++) {
        motorPacket[p + 1] = chick_code[p];
      }

      if (chickplay.value == 10) {
        if (chickplay.id % 10 == 0) chickplay.id++;
        motorPacket[10] = chickplay.id;
      }
      else {
        motorPacket[12] = (chickplay.id & 0x07) << 4 | chickplay.value;
      }
      for (int x = 0; x < 16; x ++) {
        if (x % 2 == 0)
          chick_code[(x / 2).toInt()] |= teacher_packet[x] << 4;
        else
          chick_code[(x / 2).floor()] |= teacher_packet[x];
      }
      motorPacket[9] = (1) << 4 | (play_stop.id & 0x07) << 1 | play_stop.value;
      motorPacket[11] = send.value & 0x07;
      // motorPacket[9] =  (play_stop.id&0x07) << 1 | 1;
      // motorPacket[18] = soundClip.value;
      return motorPacket;
    }
    // print("전송 패킷" + motorPacket.toString());

  }


// @override
// void reset() {
//   devices.forEach((device) {device.value = 0;});
//   type.value = 0x51;
//   soundClip.value = 0;
// }

// List<int> testMotors(List<int> packet) {
//   if(initMotor != initMotorOld) {
//     testMotorMode = true;
//     initMotorOld = initMotor;
//     repeat = 0;
//     ticks = 0;
//   }
//   if(!testMotorMode) return packet;
//
//   // config S and M port
//   ticks++;
//   packet[1] = 0x3f;
//   packet[3] = 0x05;
//
//   if(ticks < 10) {
//     packet[6] = 120;
//     packet[7] = 170;
//     packet[8] = 170;
//     packet[12] = -100;
//     packet[13] = -100;
//   }
//   else if(ticks < 20) {
//     packet[6] = 180;
//     packet[7] = 180;
//     packet[8] = 180;
//     packet[12] = 100;
//     packet[13] = 100;
//   }
//   else if(ticks >= 20) {
//     ticks = 0;
//     repeat++;
//     if(repeat > 1) {      // finish?
//       testMotorMode = false;
//       if(soundClip.id & 1 == 1) soundClip.value = 0x80 + 0x02;
//       else soundClip.value = 0x02;
//       packet[18] = soundClip.value;
//     }
//   }
//   return packet;
// }
}