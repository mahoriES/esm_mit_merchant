import 'package:esamudaay_app_update/app_update_banner.dart';
import 'package:esamudaay_app_update/esamudaay_app_update.dart';
import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/auth_guard/auth_guard.dart';
import 'package:foore/data/bloc/app_update_bloc.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/es_business_profile/es_business_profile.dart';
import 'package:foore/es_order_page/es_order_page.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:foore/intro_page/intro_page.dart';
import 'package:foore/es_video_page/es_video_page.dart';
import 'package:foore/menu_page/menu_page.dart';
import 'package:foore/onboarding_guard/onboarding_guard.dart';
import 'package:foore/router.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/es_select_business.dart';
import 'package:provider/provider.dart';

class EsHomePage extends StatefulWidget {
  static const routeName = '/';
  final HttpService httpServiceBloc;
  EsHomePage(this.httpServiceBloc);
  @override
  _EsHomePageState createState() => _EsHomePageState();
}

class _EsHomePageState extends State<EsHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<IconData> icons = [
    Icons.store,
    Icons.shopping_basket,
    Icons.menu,
    Icons.play_circle_outline,
    Icons.feedback,
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamed(AppRouter.homeRoute);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> title = [
      AppTranslations.of(context).text("bottom_nav_profile"),
      AppTranslations.of(context).text("bottom_nav_orders"),
      AppTranslations.of(context).text("bottom_nav_products"),
      AppTranslations.of(context).text("bottom_nav_videos"),
      AppTranslations.of(context).text("bottom_nav_reviews")
    ];
    SizeConfig().init(context);
    final List<Widget> _widgetOptions = <Widget>[
      EsBusinessProfile(),
      EsOrderPage(),
      MenuPage(),
      EsVideoPage(),
      AuthGuard(
        unauthenticatedPage: IntroPage(),
        child: OnboardingGuard(
          onboardingRequiredPage: MultiProvider(
            providers: [
              Provider<PeopleBloc>(
                builder: (context) => PeopleBloc(widget.httpServiceBloc),
                dispose: (context, value) => value.dispose(),
              ),
            ],
            child: HomePage(),
          ),
          child: MultiProvider(
            providers: [
              Provider<PeopleBloc>(
                builder: (context) => PeopleBloc(widget.httpServiceBloc),
                dispose: (context, value) => value.dispose(),
              ),
            ],
            child: HomePage(),
          ),
        ),
      ),
    ];

    return Scaffold(
      drawer: AppDrawer(),
      drawerEnableOpenDragGesture: false,
      appBar: _selectedIndex == 4
          ? AppBar(
              title: Text(
                AppTranslations.of(context).text("reviews_page_title"),
              ),
            )
          : AppBar(
              title: EsSelectBusiness(
                null,
                allowChange: _selectedIndex == 2 ? false : true,
              ),
            ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: StreamBuilder<AppUpdateState>(
              stream: Provider.of<EsAppUpdateBloc>(context)
                  .esAppUpdateStateObservable,
              builder: (context, snapshot) {
                return (snapshot.data?.isSelectedLater ?? false)
                    ? AppUpdateBanner(
                        updateMessage: AppTranslations.of(context)
                            .text('app_update_banner_msg'),
                        updateButtonText: AppTranslations.of(context)
                            .text('app_update_action')
                            .toUpperCase(),
                        customThemeData: EsamudaayTheme.of(context),
                        packageName: StringConstants.packageName,
                      )
                    : SizedBox.shrink();
              },
            ),
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: List.generate(
              title.length,
              (index) => BottomNavigationBarItem(
                icon: Icon(icons[index]),
                title: Text(
                  title[index],
                ),
              ),
            ),
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: true,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
