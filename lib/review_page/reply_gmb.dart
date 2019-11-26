import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/feedback.dart';
import 'package:foore/review_page/review_page_helper.dart';
import '../app_translations.dart';
import 'google_review_item.dart';

class ReplyGmb extends StatefulWidget {
  static const routeName = '/reply-gmb';
  final FeedbackItem _feedbackItem;

  ReplyGmb(this._feedbackItem);

  @override
  ReplyGmbState createState() => ReplyGmbState();
}

class ReplyGmbState extends State<ReplyGmb> {
  final _formKey = GlobalKey<FormState>();
  String _reply = '';
  bool _isLoading = false;
  bool _isSuccess = false;
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
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                  AppTranslations.of(context).text("reply_page_reply_label"),
                  style: Theme.of(context).textTheme.subtitle,
                ),
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
                    border: OutlineInputBorder(),
                    hintText: AppTranslations.of(context)
                        .text("reply_page_reply_hint"),
                  ),
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
              SizedBox(
                height: 60.0,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FoSubmitButton(
        text: AppTranslations.of(context).text("reply_page_submit"),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            this.postReply(GmbReplyPayload(
                feedbackId: feedbackItem.feedbackId, reply: this._reply));
          }
        },
        isLoading: this._isLoading,
        isSuccess: this._isSuccess,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  postReply(GmbReplyPayload payload) {
    setState(() {
      this._isLoading = true;
      this._isSuccess = false;
    });
    var payloadString = json.encode(payload.toJson());
    this
        ._httpService
        .foPost('app/feedback/dashboard/reply/update/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        setState(() {
          this._isLoading = false;
          this._isSuccess = true;
        });
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.pop(context);
        });
      } else {
        _showFailedAlertDialog();
        setState(() {
          this._isLoading = false;
          this._isSuccess = false;
        });
      }
    }).catchError((onError) {
      _showFailedAlertDialog();
      setState(() {
        this._isLoading = false;
        this._isSuccess = false;
      });
    });
  }
}
