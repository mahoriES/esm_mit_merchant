import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_login.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/http_service.dart';
import 'dart:async';

import 'package:sprintf/sprintf.dart';

class EsLoginPage extends StatefulWidget {
  static const routeName = '/esLogin';
  static const signUpRouteName = '/esSignUp';

  final isSignUp;

  EsLoginPage(this.isSignUp, {Key key}) : super(key: key);

  _EsLoginPageState createState() => _EsLoginPageState();
}

class _EsLoginPageState extends State<EsLoginPage> {
  EsLoginBloc _esLoginBloc;
  final _formKeySendCode = GlobalKey<FormState>();
  final _formKeyLoginWithOtp = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    final authBloc = Provider.of<AuthBloc>(context);
    if (this._esLoginBloc == null) {
      this._esLoginBloc = EsLoginBloc(httpService, authBloc);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._esLoginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onSendCode() {
      if (_formKeySendCode.currentState.validate()) {
        if (widget.isSignUp) {
          this._esLoginBloc.signUp(context);
        } else {
          this._esLoginBloc.sendCode();
        }
      }
    }

    onLoginWithOtp() {
      if (_formKeyLoginWithOtp.currentState.validate()) {
        this._esLoginBloc.useCode(context);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<EsLoginState>(
            stream: _esLoginBloc.esLoginStateObservable,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isShowOtp) {
                  return loginWithOtp(onLoginWithOtp, snapshot.data);
                } else
                  return sendCode(onSendCode, snapshot.data);
              }
              return Container();
            }),
      ),
    );
  }

  Container sendCode(onSendCode, EsLoginState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
      ),
      child: Form(
        key: _formKeySendCode,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(
                      'assets/es-logo-small.png',
                    ),
                  ),
                  SizedBox(width: 20),
                  Image(
                    image: AssetImage('assets/logo-black.png'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
                controller: this._esLoginBloc.phoneEditController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppTranslations.of(context)
                      .text("login_page_phone_number"),
                ),
                validator: (String value) {
                  return value.length < 1
                      ? AppTranslations.of(context)
                          .text('error_messages_required')
                      : null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ]),
            const SizedBox(height: 20),
            RaisedButton(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              onPressed: onSendCode,
              child: Container(
                width: double.infinity,
                child: state.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        AppTranslations.of(context).text("login_page_get_otp"),
                        style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Container loginWithOtp(onLoginWithOtp, EsLoginState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ),
      child: Form(
        key: _formKeyLoginWithOtp,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(
                      'assets/es-logo-small.png',
                    ),
                  ),
                  SizedBox(width: 20),
                  Image(
                    image: AssetImage('assets/logo-black.png'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              AppTranslations.of(context).text("login_page_enter_otp"),
              style: Theme.of(context).textTheme.headline,
            ),
            const SizedBox(height: 32.0),
            Text(
              AppTranslations.of(context).text("login_page_otp_sent_to") +
                  this._esLoginBloc.phoneEditController.text,
              style: Theme.of(context).textTheme.subtitle,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: this._esLoginBloc.otpEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText:
                    AppTranslations.of(context).text("login_page_enter_otp"),
              ),
              validator: (String value) {
                return value.length < 1
                    ? AppTranslations.of(context)
                        .text("error_messages_required")
                    : null;
              },
            ),
            const SizedBox(height: 20),
            RaisedButton(
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
              ),
              onPressed: onLoginWithOtp,
              child: Container(
                width: double.infinity,
                child: state.isSubmitOtp
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ))
                    : Text(
                        AppTranslations.of(context).text("login_page_login"),
                        style: Theme.of(context).textTheme.button.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
            ResendOtpComponent(onCodeRequest: () => _esLoginBloc.sendCode()),
            Expanded(
              flex: 2,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class ResendOtpComponent extends StatefulWidget {
  ///The [onCodeRequest] function is received from the caller module and executed
  ///when the Resend OTP action is performed alongwith assigning of new values to
  ///the timer, and showing a toast to user that message has been sent.
  final Function onCodeRequest;

  ResendOtpComponent({@required this.onCodeRequest});

  @override
  _ResendOtpComponentState createState() => _ResendOtpComponentState();
}

class _ResendOtpComponentState extends State<ResendOtpComponent> {
  Timer _timer;

  ///The _start value holds the time (in seconds) which should pass until the
  ///Resend OTP option is again available. For the initial attempt this is set
  ///to 30 seconds, however for every subsequent attempt the value of [_start]
  ///is bumped up by 30 seconds, so that is there is any underlying issue in the
  ///SMS service, it gets sufficient time to recover, and there are no repeated
  ///attempts which may be futile.
  int _start = 30;

  ///The [repeatCount] holds the number of times the Resend OTP function has
  ///been invoked. This is used to calculate the interval to be given between
  ///all the following resend OTP attempts.
  int repeatCount = 0;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(
          child: _start == 0
              ? GestureDetector(
                  onTap: () {
                    _start = 30 + ++repeatCount * 30;

                    ///The below line fires the action to resend the OTP.
                    widget.onCodeRequest();
                    Fluttertoast.showToast(
                        msg: AppTranslations.of(context)
                            .text('login_page_otp_sent_to_device'));
                    setState(() {
                      startTimer();
                    });
                  },
                  child: Text(
                    AppTranslations.of(context).text('login_page_resend_otp'),
                    style: TextStyle(color: AppColors.lightBlue),
                  ),
                )
              : Text(
                  sprintf(
                      AppTranslations.of(context)
                          .text('login_page_resend_otp_in_n_seconds'),
                      [_start]),
                  style: TextStyle(
                    color: AppColors.greyishText,
                  ),
                ),
        ),
      ),
    );
  }
}
