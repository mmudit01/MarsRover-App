import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mar_rover/PageResizing/Variables.dart';
import 'package:mar_rover/PageResizing/WidgetResizing.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatelessWidget {
  Widget buildList() {
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (BuildContext context, int index) {
        return FutureBuilder(
          future: getImages(index), // <--- get a future
          builder: (BuildContext context, snapshot) {
            // <--- build the things.
            return snapshot.hasData
                ? snapshot.data
                : Container(
                    height: 80.0,
                    child: Text('loading..'),
                  );
          },
        );
      },
    );
  }

  static const String id = 'MainPage';

  Future<Widget> getImages(int i) async {
    final res1 = await http.get(
        'https://api.nasa.gov/mars-photos/api/v1/manifests/curiosity?api_key=Wt4YzlVLV9JQ4HDEJ0UbOEiWM9wNrjj23TJxwVq9');
    final int maxSol = (jsonDecode(res1.body))['photo_manifest']['max_sol'];

    final res = await http.get(
        'https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=${maxSol - i}&api_key=Wt4YzlVLV9JQ4HDEJ0UbOEiWM9wNrjj23TJxwVq9');
    final url = (jsonDecode(res.body))['photos'][0]['img_src'];
    final date = (jsonDecode(res.body))['photos'][0]['earth_date'];
    final sol = maxSol - i;
    print(sol);
    return Images(
      date: date,
      url: url,
      sol: sol,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    boxSizeH = SizeConfig.safeBlockHorizontal;
    boxSizeV = SizeConfig.safeBlockVertical;
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(8 * boxSizeV),
          child: AppBar(
            centerTitle: true,
            title: Text('Mars Rover Image'),
            actions: [
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Container(
                  child: Icon(Icons.exit_to_app),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          height: 100 * boxSizeV,
          width: 100 * boxSizeH,
          child: Container(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  height: 8 * boxSizeV,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(child: Text('Oppurtunity')),
                      Container(child: Text('Curiosity')),
                      Container(child: Text('Spirit')),
                    ],
                  ),
                ),
                Container(
                  height: 84 * boxSizeV,
                  //   child: AnimatedSwitcher(
                  //     duration: Duration(seconds: 1),
                  //     // child: ListView.builder(
                  //     //   itemCount: 7,
                  //     //   itemBuilder: (context, i) => FutureBuilder(
                  //     //     builder: (context, projectSnap) {
                  //     //       if (projectSnap.connectionState ==
                  //     //               ConnectionState.none &&
                  //     //           projectSnap.hasData == null) {
                  //     //         //print('project snapshot data is: ${projectSnap.data}');
                  //     //         return Container(
                  //     //           child: Text("loading"),
                  //     //         );
                  //     //       }
                  //     //       return Images(
                  //     //         url: url,
                  //     //         date: date,
                  //     //         sol: sol,
                  //     //       );
                  //     //     },
                  //     //     future: getImages(i),
                  //     //   ),
                  //     // ),

                  //     transitionBuilder: (child, animation) => FadeTransition(
                  //       opacity: animation,
                  //       child: child,
                  //     ),
                  //   ),
                  child: buildList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Images extends StatelessWidget {
  final url;
  final date;
  final sol;
  const Images({this.url, this.date, this.sol});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SOL: $sol",
              ),
              Text(
                "Date on Earth: $date",
              ),
            ],
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Image(
              width: 100 * boxSizeH,
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
