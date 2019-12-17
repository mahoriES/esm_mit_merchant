import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/bloc/sender_code.dart';
import 'package:foore/data/http_service.dart';
import 'package:provider/provider.dart';
import 'package:rake/rake.dart';

import '../app_translations.dart';

class SenderCodePage extends StatefulWidget {
  static const routeName = '/sender-code';
  @override
  SenderCodePageState createState() => SenderCodePageState();

  static Route generateRoute(RouteSettings settings, HttpService httpService) {
    return MaterialPageRoute(
        builder: (context) => Provider(
              builder: (context) => SenderCodeBloc(httpService: httpService),
              dispose: (context, value) => value.dispose(),
              child: SenderCodePage(),
            ));
  }
}

class SenderCodePageState extends State<SenderCodePage>
    with AfterLayoutMixin<SenderCodePage> {
  FocusNode _codeFocusNodeOne;
  FocusNode _codeFocusNodeTwo;
  FocusNode codeFocusNodeThree;
  FocusNode codeFocusNodeFour;
  FocusNode codeFocusNodeFive;
  FocusNode codeFocusNodeSix;
  bool isManual = false;
  final _formKey = GlobalKey<FormState>();
  List<String> suggestions = [];
  String selectedSuggestion;
  String manualSuggestionOne;
  String manualSuggestionTwo;
  String manualSuggestionThree;
  String manualSuggestionFour;
  String manualSuggestionFive;
  String manualSuggestionSix;

  @override
  void afterFirstLayout(BuildContext context) {
    var onBoardingGuard = Provider.of<OnboardingGuardBloc>(context);
    onBoardingGuard.onboardingStateObservable.listen((onboardingState) {
      setState(() {
        suggestions = [];
        if (onboardingState.smsCode != 'oFoore') {
          // this.isManual = true;
          this.suggestions.add(onboardingState.smsCode);
        } else {
          this.suggestions.add('oFoore');
          this.selectedSuggestion = 'oFoore';
        }
        if (onboardingState.locations.length > 0) {
          final storeName = onboardingState.locations[0].name ?? '';
          // final storeName = 'Foore';
          print(storeName);
          final rakeFilter = Rake(stopWords: ['']..addAll(smartEnglish));
          var wordWithoutSpaces =
              rakeFilter.run(storeName).keys.join('').toUpperCase();
          final RegExp _eliminateVowels = RegExp(r'[aeyiuo]');
          var wordWithoutVowels = wordWithoutSpaces
              .toLowerCase()
              .replaceAll(_eliminateVowels, '')
              .toUpperCase();

          if (wordWithoutSpaces.length == 4) {
            wordWithoutSpaces = 'oo' + wordWithoutSpaces;
          } else if (wordWithoutSpaces.length == 5) {
            wordWithoutSpaces = 'o' + wordWithoutSpaces;
          }

          if (wordWithoutVowels.length == 4) {
            wordWithoutVowels = 'oo' + wordWithoutVowels;
          } else if (wordWithoutVowels.length == 5) {
            wordWithoutVowels = 'o' + wordWithoutVowels;
          }

          if (wordWithoutSpaces.length >= 6) {
            suggestions.add(wordWithoutSpaces.substring(0, 6).toUpperCase());
          }

          if (wordWithoutVowels.length >= 6) {
            suggestions.add(wordWithoutVowels.substring(0, 6).toUpperCase());
          }
          print(suggestions);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _codeFocusNodeOne = FocusNode();
    _codeFocusNodeTwo = FocusNode();
    codeFocusNodeThree = FocusNode();
    codeFocusNodeFour = FocusNode();
    codeFocusNodeFive = FocusNode();
    codeFocusNodeSix = FocusNode();
  }

  @override
  void dispose() {
    _codeFocusNodeOne.dispose();
    _codeFocusNodeTwo.dispose();
    codeFocusNodeThree.dispose();
    codeFocusNodeFour.dispose();
    codeFocusNodeFive.dispose();
    codeFocusNodeSix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var senderCodeBloc = Provider.of<SenderCodeBloc>(context);
    manualCodeChange() {
      if (_formKey.currentState.validate()) {
        senderCodeBloc.proposeSenderCode(
            manualSuggestionOne +
                manualSuggestionTwo +
                manualSuggestionThree +
                manualSuggestionFour +
                manualSuggestionFive +
                manualSuggestionSix, (String proposedCode) {
          print('.............');
          print(proposedCode);
        });
      }
    }

    suggestedCodeChange() {
      if (selectedSuggestion != null) {
        senderCodeBloc.proposeSenderCode(
            selectedSuggestion, (String proposedCode) {});
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text('sender_code_page_title'),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        elevation: 0,
        brightness: Brightness.dark,
        iconTheme: IconThemeData.fallback().copyWith(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 45.0,
          ),
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  height: 250.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 50.0,
                  ),
                  child: Container(
                    height: 200.0,
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/sms-code.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
              ),
              child: Text(
                AppTranslations.of(context).text('sender_code_page_help_text'),
                style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.green,
                    ),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Visibility(
              visible: !isManual,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Column(
                      children: suggestions.map((suggestion) {
                        return CheckboxListTile(
                          title: Text(suggestion),
                          value: selectedSuggestion == suggestion,
                          onChanged: (bool value) {
                            setState(() {
                              if (value) selectedSuggestion = suggestion;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            AppTranslations.of(context)
                                .text('sender_code_page_or'),
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isManual = true;
                              });
                            },
                            child: Chip(
                              label: Text(
                                AppTranslations.of(context)
                                    .text('sender_code_page_button_manual'),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isManual,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: _codeFocusNodeOne,
                        onChanged: (String text) {
                          setState(() {
                            manualSuggestionOne = text;
                          });
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(_codeFocusNodeTwo);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: _codeFocusNodeTwo,
                        onChanged: (String text) {
                          setState(() {
                            manualSuggestionTwo = text;
                          });
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeThree);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeThree,
                        onChanged: (String text) {
                          setState(() {
                            manualSuggestionThree = text;
                          });
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeFour);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeFour,
                        onChanged: (String text) {
                          setState(() {
                            manualSuggestionFour = text;
                          });
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeFive);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeFive,
                        onChanged: (String text) {
                          setState(() {
                            manualSuggestionFive = text;
                          });
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeSix);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeSix,
                        maxLength: 1,
                        onChanged: (text) {
                          setState(() {
                            manualSuggestionSix = text;
                          });
                        },
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<SenderCodeState>(
          stream: senderCodeBloc.SenderCodeStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FoSubmitButton(
              text: AppTranslations.of(context)
                  .text("sender_code_page_button_submit"),
              onPressed: isManual ? manualCodeChange : suggestedCodeChange,
              isLoading: snapshot.data.isSubmitting,
              isSuccess: snapshot.data.isSubmitSuccess,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// stop word list from SMART (Salton, 1971)
// ftp://ftp.cs.cornell.edu/pub/smart/english.stop
const smartEnglish = [
  "a",
  "a's",
  "able",
  "about",
  "above",
  "according",
  "accordingly",
  "across",
  "actually",
  "after",
  "afterwards",
  "again",
  "against",
  "ain't",
  "all",
  "allow",
  "allows",
  "almost",
  "alone",
  "along",
  "already",
  "also",
  "although",
  "always",
  "am",
  "among",
  "amongst",
  "an",
  "and",
  "another",
  "any",
  "anybody",
  "anyhow",
  "anyone",
  "anything",
  "anyway",
  "anyways",
  "anywhere",
  "apart",
  "appear",
  "appreciate",
  "appropriate",
  "are",
  "aren't",
  "around",
  "as",
  "aside",
  "ask",
  "asking",
  "associated",
  "at",
  "available",
  "away",
  "awfully",
  "b",
  "be",
  "became",
  "because",
  "become",
  "becomes",
  "becoming",
  "been",
  "before",
  "beforehand",
  "behind",
  "being",
  "believe",
  "below",
  "beside",
  "besides",
  "best",
  "better",
  "between",
  "beyond",
  "both",
  "brief",
  "but",
  "by",
  "c",
  "c'mon",
  "c's",
  "came",
  "can",
  "can't",
  "cannot",
  "cant",
  "cause",
  "causes",
  "certain",
  "certainly",
  "changes",
  "clearly",
  "co",
  "com",
  "come",
  "comes",
  "concerning",
  "consequently",
  "consider",
  "considering",
  "contain",
  "containing",
  "contains",
  "corresponding",
  "could",
  "couldn't",
  "course",
  "currently",
  "d",
  "definitely",
  "described",
  "despite",
  "did",
  "didn't",
  "different",
  "do",
  "does",
  "doesn't",
  "doing",
  "don't",
  "done",
  "down",
  "downwards",
  "during",
  "e",
  "each",
  "edu",
  "eg",
  "eight",
  "either",
  "else",
  "elsewhere",
  "enough",
  "entirely",
  "especially",
  "et",
  "etc",
  "even",
  "ever",
  "every",
  "everybody",
  "everyone",
  "everything",
  "everywhere",
  "ex",
  "exactly",
  "example",
  "except",
  "f",
  "far",
  "few",
  "fifth",
  "first",
  "five",
  "followed",
  "following",
  "follows",
  "for",
  "former",
  "formerly",
  "forth",
  "four",
  "from",
  "further",
  "furthermore",
  "g",
  "get",
  "gets",
  "getting",
  "given",
  "gives",
  "go",
  "goes",
  "going",
  "gone",
  "got",
  "gotten",
  "greetings",
  "h",
  "had",
  "hadn't",
  "happens",
  "hardly",
  "has",
  "hasn't",
  "have",
  "haven't",
  "having",
  "he",
  "he's",
  "hello",
  "help",
  "hence",
  "her",
  "here",
  "here's",
  "hereafter",
  "hereby",
  "herein",
  "hereupon",
  "hers",
  "herself",
  "hi",
  "him",
  "himself",
  "his",
  "hither",
  "hopefully",
  "how",
  "howbeit",
  "however",
  "i",
  "i'd",
  "i'll",
  "i'm",
  "i've",
  "ie",
  "if",
  "ignored",
  "immediate",
  "in",
  "inasmuch",
  "inc",
  "indeed",
  "indicate",
  "indicated",
  "indicates",
  "inner",
  "insofar",
  "instead",
  "into",
  "inward",
  "is",
  "isn't",
  "it",
  "it'd",
  "it'll",
  "it's",
  "its",
  "itself",
  "j",
  "just",
  "k",
  "keep",
  "keeps",
  "kept",
  "know",
  "knows",
  "known",
  "l",
  "last",
  "lately",
  "later",
  "latter",
  "latterly",
  "least",
  "less",
  "lest",
  "let",
  "let's",
  "like",
  "liked",
  "likely",
  "little",
  "look",
  "looking",
  "looks",
  "ltd",
  "m",
  "mainly",
  "many",
  "may",
  "maybe",
  "me",
  "mean",
  "meanwhile",
  "merely",
  "might",
  "more",
  "moreover",
  "most",
  "mostly",
  "much",
  "must",
  "my",
  "myself",
  "n",
  "name",
  "namely",
  "nd",
  "near",
  "nearly",
  "necessary",
  "need",
  "needs",
  "neither",
  "never",
  "nevertheless",
  "new",
  "next",
  "nine",
  "no",
  "nobody",
  "non",
  "none",
  "noone",
  "nor",
  "normally",
  "not",
  "nothing",
  "novel",
  "now",
  "nowhere",
  "o",
  "obviously",
  "of",
  "off",
  "often",
  "oh",
  "ok",
  "okay",
  "old",
  "on",
  "once",
  "one",
  "ones",
  "only",
  "onto",
  "or",
  "other",
  "others",
  "otherwise",
  "ought",
  "our",
  "ours",
  "ourselves",
  "out",
  "outside",
  "over",
  "overall",
  "own",
  "p",
  "particular",
  "particularly",
  "per",
  "perhaps",
  "placed",
  "please",
  "plus",
  "possible",
  "presumably",
  "probably",
  "provides",
  "q",
  "que",
  "quite",
  "qv",
  "r",
  "rather",
  "rd",
  "re",
  "really",
  "reasonably",
  "regarding",
  "regardless",
  "regards",
  "relatively",
  "respectively",
  "right",
  "s",
  "said",
  "same",
  "saw",
  "say",
  "saying",
  "says",
  "second",
  "secondly",
  "see",
  "seeing",
  "seem",
  "seemed",
  "seeming",
  "seems",
  "seen",
  "self",
  "selves",
  "sensible",
  "sent",
  "serious",
  "seriously",
  "seven",
  "several",
  "shall",
  "she",
  "should",
  "shouldn't",
  "since",
  "six",
  "so",
  "some",
  "somebody",
  "somehow",
  "someone",
  "something",
  "sometime",
  "sometimes",
  "somewhat",
  "somewhere",
  "soon",
  "sorry",
  "specified",
  "specify",
  "specifying",
  "still",
  "sub",
  "such",
  "sup",
  "sure",
  "t",
  "t's",
  "take",
  "taken",
  "tell",
  "tends",
  "th",
  "than",
  "thank",
  "thanks",
  "thanx",
  "that",
  "that's",
  "thats",
  "the",
  "their",
  "theirs",
  "them",
  "themselves",
  "then",
  "thence",
  "there",
  "there's",
  "thereafter",
  "thereby",
  "therefore",
  "therein",
  "theres",
  "thereupon",
  "these",
  "they",
  "they'd",
  "they'll",
  "they're",
  "they've",
  "think",
  "third",
  "this",
  "thorough",
  "thoroughly",
  "those",
  "though",
  "three",
  "through",
  "throughout",
  "thru",
  "thus",
  "to",
  "together",
  "too",
  "took",
  "toward",
  "towards",
  "tried",
  "tries",
  "truly",
  "try",
  "trying",
  "twice",
  "two",
  "u",
  "un",
  "under",
  "unfortunately",
  "unless",
  "unlikely",
  "until",
  "unto",
  "up",
  "upon",
  "us",
  "use",
  "used",
  "useful",
  "uses",
  "using",
  "usually",
  "uucp",
  "v",
  "value",
  "various",
  "very",
  "via",
  "viz",
  "vs",
  "w",
  "want",
  "wants",
  "was",
  "wasn't",
  "way",
  "we",
  "we'd",
  "we'll",
  "we're",
  "we've",
  "welcome",
  "well",
  "went",
  "were",
  "weren't",
  "what",
  "what's",
  "whatever",
  "when",
  "whence",
  "whenever",
  "where",
  "where's",
  "whereafter",
  "whereas",
  "whereby",
  "wherein",
  "whereupon",
  "wherever",
  "whether",
  "which",
  "while",
  "whither",
  "who",
  "who's",
  "whoever",
  "whole",
  "whom",
  "whose",
  "why",
  "will",
  "willing",
  "wish",
  "with",
  "within",
  "without",
  "won't",
  "wonder",
  "would",
  "would",
  "wouldn't",
  "x",
  "y",
  "yes",
  "yet",
  "you",
  "you'd",
  "you'll",
  "you're",
  "you've",
  "your",
  "yours",
  "yourself",
  "yourselves",
  "z",
  "zero"
];
