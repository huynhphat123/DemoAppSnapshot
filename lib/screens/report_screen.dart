// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lvtn_mangxahoi/resources/firestore_methods.dart';


import 'package:lvtn_mangxahoi/utils/colors.dart';

class ReportScreen extends StatefulWidget {
  final String postId;
  final String postUrl;

  const ReportScreen({
    Key? key,
    required this.postId,
    required this.postUrl,
  }) : super(key: key);
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<String> reportCategories = [
    'Đây là spam',
    'Tôi không thích nội dung này',
    'Lừa đảo hoặc gian lận',
    'Thông tin sai sự thật',
    'Ảnh khỏa thân hoặc hoạt động gợi dục',
    'Vi phạm quyền sở hữu trí tuệ',
    'Bạo lực hoặc tổ chức nguy hiểm',
    'Nội dung khác',
    // Thêm các danh mục báo cáo khác ở đây
  ];

  bool shouldSubmitReport = false;
  bool isLoading = false;
  bool isSuccess = false;

  Future<void> _submitReport(String reportCategory) async {
    bool shouldSubmitReport = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kWhite,
          title: const Text(
            'Xác nhận',
            style: TextStyle(
              color: kBlack,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn báo cáo nội dung này?',
            style: TextStyle(
              color: kBlack,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Không',
                style: TextStyle(
                  color: kBlack,
                ),
              ),
              onPressed: () {
                shouldSubmitReport = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Có',
                style: TextStyle(
                  color: kBlack,
                ),
              ),
              onPressed: () {
                shouldSubmitReport = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (shouldSubmitReport) {
      setState(() {
        isLoading = true;
      });

      await FireStoreMethods.addReport(
          widget.postId, reportCategory, widget.postUrl);

      setState(() {
        isLoading = false;
        isSuccess = true;
      });

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kWhite,
            title: const Text(
              'Báo cáo thành công! ✅',
              style: TextStyle(color: kBlack),
            ),
            content: const Text(
              'Cảm ơn bạn đã cho chúng tôi biết!',
              style: TextStyle(color: kBlack),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nội dung báo cáo',
          style: TextStyle(color: kBlack),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.black, // Đặt màu cho nút quay về
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: reportCategories.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  reportCategories[index],
                  style: const TextStyle(color: kBlack),
                ),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ReportDetailScreen(
                  //       reportCategory: reportCategories[index],
                  //     ),
                  //   ),
                  // );
                  // setState(() {
                  //   isLoading = true;
                  // });
                  // FireStoreMethods.addReport(
                  //     widget.postId, reportCategories[index], widget.postUrl);
                  // setState(() {
                  //   isLoading = false;
                  //   isSuccess = true;
                  // });
                  _submitReport(reportCategories[index]);
                },
              );
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
    
  }
  
}
