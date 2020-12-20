import 'package:flutter/material.dart';
import 'package:airtime_data/components/call_page.dart';
import 'package:airtime_data/components/data_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
                })
          ],
          backgroundColor: Colors.lightBlueAccent,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            tabs: [
              Text('AIRTIME'),
              Text('DATA'),
            ],
          ),
          title: Text('Recharge'),
        ),
        body: TabBarView(
          children: [
            CallPage(),
            DataPage(),
          ],
        ),
      ),
    );
  }
}
