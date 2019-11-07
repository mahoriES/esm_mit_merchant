import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:foore/review_page/review_page_helper.dart';
import '../app_translations.dart';
import 'google_review_item.dart';

class ReplyGmb extends StatefulWidget {
  final FeedbackItem _feedbackItem;

  ReplyGmb(this._feedbackItem);

  @override
  ReplyGmbState createState() => ReplyGmbState();
}

class ReplyGmbState extends State<ReplyGmb> {
  final _formKey = GlobalKey<FormState>();
  String _reply = '';
  bool _isLoading = false;
  HttpService _httpService;

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void didChangeDependencies() {
    this._httpService = Provider.of<HttpService>(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    this._reply = GmbReviewHelper.gmbReplyText(this.widget._feedbackItem);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FeedbackItem feedbackItem = this.widget._feedbackItem;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("reply_page_title"),
        ),
        actions: <Widget>[
          Container(
            child: Center(
              child: this._isLoading
                  ? Container(
                      padding: EdgeInsets.only(right: 30.0),
                      child: CircularProgressIndicator())
                  : FlatButton(
                      child: Text(
                        AppTranslations.of(context).text("reply_page_submit"),
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          this.postReply(GmbReplyPayload(
                              feedbackId: feedbackItem.feedbackId,
                              reply: this._reply));
                          // Process data.
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: Scrollbar(
          child: ListView(
            children: <Widget>[
              GoogleItemWidget(
                feedbackItem,
                isShowReplyButton: false,
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                    AppTranslations.of(context).text("reply_page_reply_label")),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                alignment: Alignment.bottomLeft,
                child: TextFormField(
                  maxLines: 5,
                  initialValue: GmbReviewHelper.gmbReplyText(feedbackItem),
                  autovalidate: true,
                  autofocus: true,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(80, 233, 233, 233),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            style: BorderStyle.solid,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            style: BorderStyle.solid,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            style: BorderStyle.solid,
                          )),
                      hintText: AppTranslations.of(context)
                          .text("reply_page_reply_hint"),
                      labelStyle: TextStyle(
                        color: Colors.black54,
                      )),
                  onChanged: (String value) {
                    setState(() {
                      this._reply = value;
                    });
                  },
                  validator: (String value) {
                    return value.length > 4000
                        ? AppTranslations.of(context)
                            .text("reply_page_reply_validation")
                        : null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  postReply(GmbReplyPayload payload) {
    setState(() {
      this._isLoading = true;
    });
    var payloadString = json.encode(payload.toJson());
    this
        ._httpService
        .foPost('app/feedback/dashboard/reply/update/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        setState(() {
          this._isLoading = false;
        });
        Navigator.pop(context);
      } else {
        setState(() {
          this._isLoading = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        this._isLoading = false;
      });
    });
  }
}
