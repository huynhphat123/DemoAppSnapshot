import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lvtn_mangxahoi/models/user.dart';
import 'package:lvtn_mangxahoi/provider/user_provider.dart';

import 'package:lvtn_mangxahoi/utils/colors.dart';
import 'package:lvtn_mangxahoi/utils/utils.dart';
import 'package:provider/provider.dart';

import '../resources/firestore_methods.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  List<String> topics = [
    'Thiên nhiên',
    'Đô thị',
    'Con người',
    'Động vật',
    'Thể thao',
    'Ẩm thực',
    'Văn hóa và lễ hội',
    'Khoa học và công nghệ',
    'Nghệ thuật',
    'Du lịch',
    'Gia đình',
    'Truyện tranh và hoạt hình'
  ];

  List<String> selectedTopics = [];

 void postImage(String uid, String username, String profImage) async {
   
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          username,
          profImage,
          selectedTopics);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bài viết của bạn đã được tải lên.'),
          ),
        );
        clearImage();
        clearSelectedTopics();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

 void clearImage() {
    setState(() {
      _file = null;
      _descriptionController.clear();
    });
  }

  void clearSelectedTopics() {
    setState(() {
      selectedTopics.clear();
    });
  }
  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => _selectImage(context),
              icon: const Icon(Icons.upload),
              color: kBlack,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Post to'),
              actions: [
                TextButton(
                  onPressed: () =>
                      postImage(user.uid, user.username, user.photoUrl),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              user.photoUrl,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child:  TextField(
                              controller: _descriptionController,
                              style: const TextStyle(color: kBlack),
                              decoration: const InputDecoration(
                                hintText: 'Viết gì đó...',
                                hintStyle: TextStyle(color: kBlack),
                                border: InputBorder.none,
                              ),
                              maxLines: 4,
                            ),
                          ),
                          SizedBox(
                            height: 45,
                            width: 45,
                            child: AspectRatio(
                              aspectRatio: 487 / 451,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(_file!),
                                    fit: BoxFit.fill,
                                    alignment: FractionalOffset.topCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                 
                                  const Text(
                                    'Chọn chủ đề của bài viết:',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                    
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Wrap(
                                    spacing: 8.0,
                                    children: topics.map((topic) {
                                      final isSelected =
                                          selectedTopics.contains(topic);

                                      return ChoiceChip(
                                        label: Text(
                                          topic,
                                          style: const TextStyle(color: kBlack),
                                        ),
                                        selected: isSelected,
                                        backgroundColor: isSelected
                                            ? const Color.fromARGB(
                                                255, 152, 203, 245)
                                            : const Color.fromARGB(
                                                255, 182, 179, 179),
                                        selectedColor: const Color.fromARGB(
                                            255, 158, 203, 240),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedTopics.add(topic);
                                            } else {
                                              selectedTopics.remove(topic);
                                            }
                                          });
                                        },
                                        );
                                    }).toList(),
                                  ),
                                 
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }
}