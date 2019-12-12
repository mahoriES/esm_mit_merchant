import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test UPI',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future _transaction;

  Future<String> initiateTransaction(String app) async {
    UpiIndia upi = new UpiIndia(
      app: app,
      receiverUpiId: 'tester@test',
      receiverName: 'Tester',
      transactionRefId: 'TestingId',
      transactionNote: 'Not actual. Just an example.',
      amount: 1.00,
    );

    String response = await upi.startTransaction();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UPI'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: RaisedButton(
                  child: Text('PhonePe'),
                  onPressed: () {
                    _transaction = initiateTransaction(UpiIndiaApps.PhonePe,);
                    setState(() {});
                  }),
            ),
          ),
          Expanded(
            flex: 2,
            child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.data == null)
                  return Text(' ');
                else {
                  switch (snapshot.data.toString()) {
                    case UpiIndiaResponseError.APP_NOT_INSTALLED:
                      return Text(
                        'App not installed.',
                      );
                      break;
                    case UpiIndiaResponseError.INVALID_PARAMETERS:
                      return Text(
                        'App is unable to handle request.',
                      );
                      break;
                    case UpiIndiaResponseError.USER_CANCELLED:
                      return Text(
                        'It seems like you cancelled the transaction.',
                      );
                      break;
                    case UpiIndiaResponseError.NULL_RESPONSE:
                      return Text(
                        'No data received',
                      );
                      break;
                    default:
                      UpiIndiaResponse _upiResponse;
                      _upiResponse = UpiIndiaResponse(snapshot.data);
                      String txnId = _upiResponse.transactionId;
                      String resCode = _upiResponse.responseCode;
                      String txnRef = _upiResponse.transactionRefId;
                      String status = _upiResponse.status;
                      String approvalRef = _upiResponse.approvalRefNo;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text('Transaction Id: $txnId'),
                          Text('Response Code: $resCode'),
                          Text('Reference Id: $txnRef'),
                          Text('Status: $status'),
                          Text('Approval No: $approvalRef'),
                        ],
                      );
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
