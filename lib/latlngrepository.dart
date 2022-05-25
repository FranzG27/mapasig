import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class latilong{
final int FID;
final String code;
final double latitud;
final double longitud;

const latilong({
required this.FID,
required this.code,
required this.latitud,
required this.longitud,
});

factory latilong.fromJson(Map<String,dynamic> json){
  return latilong(
   FID: json['FID'] as int,
   code: json['code'] as String,
   latitud: json['latitud'] as double, 
   longitud: json['longitud'] as double,
   );
}
}