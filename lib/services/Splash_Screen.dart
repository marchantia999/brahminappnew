import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadData();

  }


  Future<Timer>loadData() async{
    return Timer(Duration(seconds: 3), onDoneLoading);
  }
  onDoneLoading() async {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      //backgroundColor: Color(0XFFffbd59),
      body: Stack(
        children: [
         /* Container(
              height: height,
              width: width,
              child: Image.asset('0.png',fit: BoxFit.fill,)),*/
          Center(
            child: Container(
              padding: EdgeInsets.all(40),
              height: height*0.5,
              width: width*0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(child: Image.asset('images/dlogo.png')),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(bottom: height*0.2),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.end,

              children: [
                Center(child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.orangeAccent),
                  child: new CircularProgressIndicator(),
                ))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: height*0.02),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.end,

              children: [
                Center(child: Text('from',style: TextStyle(color: Colors.black54),)),
                Center(child: Text('Puja Purohit',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),)),
              ],
            ),
          ),
        ],
      )
    );
  }
}