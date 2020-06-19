import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_login.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/http_service.dart';

class EsLoginPage extends StatefulWidget {
  static const routeName = '/esLogin';
  static const signUpRouteName = '/esSignUp';

  final isSignUp;

  EsLoginPage(this.isSignUp,{Key key}) : super(key: key);

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
        if(widget.isSignUp) {
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
            Container(
              width: 70.0,
              padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
              child: Image(
                image: AssetImage('assets/logo-black.png'),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              'Connect your eSamudaay account',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            // const SizedBox(height: 32.0),
            // Text(
            //   widget.isSignUp ?'Sign up with eSamudaay account':'Login with eSamudaay account',
            //   style: Theme.of(context).textTheme.subtitle,
            // ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: this._esLoginBloc.phoneEditController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone',
              ),
              validator: (String value) {
                return value.length < 1 ? 'Required' : null;
              },
            ),
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
                        'Get otp',
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
            Container(
              width: 70,
              padding: EdgeInsets.only(top: 50, bottom: 10),
              child: Image(
                image: AssetImage('assets/logo-black.png'),
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              'Enter otp',
              style: Theme.of(context).textTheme.headline,
            ),
            const SizedBox(height: 32.0),
            Text(
              'OTP sent to ' + this._esLoginBloc.phoneEditController.text,
              style: Theme.of(context).textTheme.subtitle,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: this._esLoginBloc.otpEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter otp',
              ),
              validator: (String value) {
                return value.length < 1 ? 'Required' : null;
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
                        'Login',
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
}
