import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';
import 'dart:math';

const urlToken =
    'https://pgs-sandbox.globalaccelerex.com/api/bill-payment/fe/v1/get/gastrategydept/token/admin';
const clientID = 'gastrategydept';
const clientSecret = 'CLIENT_SECRET';
String secretKey;
String transactionStatus;
int statusCode;
const urlAirtime =
    'https://pgs-sandbox.globalaccelerex.com/api/bill-payment/fe/v1/payment';
int amount;
String phoneNumber;
String networkType;
String transRef;
bool showSpinner = false;

class CallPage extends StatefulWidget {
  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  void getSecretKey() async {
    var random = Random();
    var endRef = random.nextInt(10).toString();
    var startRef = "00";
    var now = new DateTime.now().toString();
    print(now);
    var dateRef = now.replaceAll(RegExp(r'\D'), '');
    transRef = startRef + dateRef + endRef;
    print(transRef);
    try {
      http.Response response = await http.get(urlToken, headers: {
        "X_CLIENT_ID": clientID,
        "X-CLIENT-SECRET": clientSecret,
      });
      if (response.statusCode == 200) {
        String data = response.body;
        secretKey = jsonDecode(data)['secretKey'];
        //print(secretKey);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  Future getAirtime() async {
    try {
      http.Response response = await http.post(urlAirtime,
          headers: <String, String>{
            "Content-Type": "application/json",
            "X_CLIENT_ID": clientID,
            "X-CLIENT-SECRET": clientSecret,
            "X-AUTH-TOKEN": secretKey,
          },
          body: jsonEncode({
            "transRef": transRef,
            "billerCode": "gabaxibox__airtimedata__mtn",
            "paymentItemCode": "gabaxibox__mtn__ARDSCAP06",
            "paymentChannel": "CASH",
            "amount": amount,
            "attributes": [
              {
                "attributeCode": "gabaxibox__mtn__ARDSCAP06__phoneNumber",
                "attributeValue": phoneNumber,
              }
            ]
          }));
      if (response.statusCode == 200) {
        String data = response.body;
        transactionStatus = jsonDecode(data)['transactionStatus'];
        // print(response.statusCode);
        // print(transactionStatus);
      } else {
        statusCode = response.statusCode;
        print(response.statusCode);
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    void callSuccessSnackBar() {
      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text('Recharge was successful!'),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }

    void callFailureSnackBar() {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Recharge failed. Please try again.'),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }

    String dropdownValue = 'Select your network';
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: ListView(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Fill in your details below',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: kPhoneNumberFieldDecoration,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: DropdownButtonFormField(
                    decoration: kDropdownFieldDecoration,
                    value: dropdownValue,
                    style: TextStyle(color: Colors.black54, fontSize: 16.0),
                    items: <String>[
                      'Select your network',
                      'MTN',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String newValue) {
                      networkType = newValue;
                    }),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  onChanged: (value) {
                    amount = int.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: OutlinedButton(
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    getSecretKey();
                    await getAirtime();
                    if (transactionStatus == "SUCCESS") {
                      setState(() {
                        showSpinner = false;
                      });
                      callSuccessSnackBar();
                    } else {
                      setState(() {
                        showSpinner = false;
                      });
                      callFailureSnackBar();
                    }
                  },
                  child: Text(
                    'Get airtime',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.lightBlueAccent,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
