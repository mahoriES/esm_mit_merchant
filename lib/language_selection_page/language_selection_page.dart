import 'package:flutter/material.dart';
import 'package:foore/data/bloc/app_translations_bloc.dart';
import 'package:provider/provider.dart';

class LanguageSelectionPage extends StatefulWidget {
  LanguageSelectionPage({Key key}) : super(key: key);

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  static final List<String> languagesList =
      AppTranslationsBloc.supportedLanguages;
  static final List<String> languageCodesList =
      AppTranslationsBloc.supportedLanguageCodes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: Typography.blackMountainView,
        iconTheme: IconThemeData.fallback(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black54,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Change language',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 24.0,
            letterSpacing: 1.1,
          ),
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: _buildLanguagesList(context),
      ),
    );
  }

  _buildLanguagesList(BuildContext context) {
    return ListView.builder(
      itemCount: languagesList.length,
      itemBuilder: (context, index) {
        return _buildLanguageItem(
            languagesList[index], languageCodesList[index], context);
      },
    );
  }

  _buildLanguageItem(
      String language, String languageCode, BuildContext context) {
    final appTranslationsBloc = Provider.of<AppTranslationsBloc>(context);
    return StreamBuilder<AppTranslationsState>(
        stream: appTranslationsBloc.appTranslationsStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            alignment: Alignment.bottomLeft,
            child: CheckboxListTile(
              title: Text(language),
              value:
                  snapshot.data.localeDelegate.currentLanguage == languageCode,
              onChanged: (bool value) {
                appTranslationsBloc.onLocaleChanged(Locale(languageCode));
                Navigator.pop(context);
              },
            ),
          );
        });
  }
}
