import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_hex_color/flutter_hex_color.dart';
// sử dụng để tạo nền cho trang cá nhân 
class ProfileBackground extends StatelessWidget {
  // nhận tham số key và tham số bắt buộc child  
  const ProfileBackground({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    // Lấy kích thước của màn hình hiện tại.
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // Stack là một widget gồm nhiều thành phần con chồng lên nhau
      body: Stack(
        alignment: Alignment.center,
        children: [
          // thành phần con đc đặt trong Positioned
          Positioned(
            top: -50,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                height: size.height * 0.60,
                width: size.height * 0.60,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color:HexColor("def3f2")),
                  borderRadius: BorderRadius.circular(152.0),
                ),
              ),
            ),
          ),
          Positioned(
            top: -90,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                height: size.height * 0.60,
                width: size.height * 0.60,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color:HexColor("def3f2")),
                  borderRadius: BorderRadius.circular(152.0),
                ),
              ),
            ),
          ),
          Positioned(
            top: -130,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                height: size.height * 0.60,
                width: size.height * 0.60,
                decoration: BoxDecoration(
                  color:HexColor("def3f2"),
                  borderRadius: BorderRadius.circular(152.0),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
