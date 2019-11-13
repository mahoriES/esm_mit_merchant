import 'package:flutter/material.dart';
import 'package:foore/data/bloc/app_translations_bloc.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class LanguageSelectionPage extends StatefulWidget {
  final Function() onSelectLanguage;
  LanguageSelectionPage({Key key, this.onSelectLanguage}) : super(key: key);

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
      appBar: AppBar(
        leading: widget.onSelectLanguage == null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        title: Text(
          AppTranslations.of(context)
              .text("language_selection_page_change_language"),
        ),
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
                if (widget.onSelectLanguage != null) {
                  widget.onSelectLanguage();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          );
        });
  }
}
