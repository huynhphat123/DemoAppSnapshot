import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lvtn_mangxahoi/resources/firestore_method.dart';
import 'package:lvtn_mangxahoi/resources/firestore_methods.dart';
import 'package:lvtn_mangxahoi/screens/profile_screen.dart';
import 'package:lvtn_mangxahoi/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lvtn_mangxahoi/utils/global_variables.dart';

import 'detail_post_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
              
                padding: EdgeInsets.only(left: 10),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 193, 190, 190)),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: TextFormField(
                  controller: searchController,
                  style: TextStyle(color: Colors.black),
                  decoration:
                      const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search for a user...',
                        hintStyle: TextStyle(color: Colors.black,fontSize: 16),
                        ),
                  onFieldSubmitted: (String _) {
                    setState(() {
                      isShowUsers = true;
                    });
                    print(_);
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 74, 0, 0),
                borderRadius: BorderRadius.circular(40)
              ),
              child: Icon(Icons.search,color: Color.fromARGB(255, 9, 172, 241),size: 27,))
          ],
        ),
      ),
//để xác định xem liệu danh sách người dùng sẽ được hiển thị hay danh sách bài viết sẽ được hiển thị
// Nếu là true, danh sách người dùng sẽ được hiển thị
// Nếu là false, danh sách bài viết sẽ được hiển thị
      body: isShowUsers
      // future được sd để lấy ds người dùng firebase
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  ).limit(5)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              // được sử dụng để hiển thị danh sách người dùng
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    // Mỗi bài viết là một ảnh được hiển thị trong một InkWell
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ),
                      // chứa thông tin như tên người dùng và ảnh đại diện
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['username'],style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              // future: FirebaseFirestore.instance
              //     .collection('posts')
              //     .orderBy('datePublished')
              //     .get(),
              future: FireStoreMethods.getPostsByUserTopics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return StaggeredGridView.countBuilder(
                  crossAxisCount: 3,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return detailPost(
                                          snap: snapshot.data!.docs[index],
                                          idpost: snapshot.data!.docs[index]['postId'],
                                        );
                                      },
                                    ));
                    },
                    child: Image.network(
                      (snapshot.data! as dynamic).docs[index]['postUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),


                  
                  staggeredTileBuilder: (index) => MediaQuery.of(context)
                              .size
                              .width >
                          webScreenSize
                      ? StaggeredTile.count(
                          (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                      : StaggeredTile.count(
                          (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                );
              },
            ),
    );
  }
}