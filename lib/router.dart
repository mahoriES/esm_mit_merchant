import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/es_business_categories.dart';
import 'package:foore/data/bloc/es_business_catalogue.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_create_business.dart';
import 'package:foore/data/bloc/es_create_merchant_profile.dart';
import 'package:foore/data/bloc/es_orders.dart';
import 'package:foore/data/bloc/es_select_circle.dart';
import 'package:foore/data/bloc/es_video.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_address_picker_view/add_new_address_view.dart/add_new_address_view.dart';
import 'package:foore/es_address_picker_view/search_view/search_view.dart';
import 'package:foore/es_business_categories/es_business_categories_view.dart';
import 'package:foore/es_business_guard/es_businesses_guard.dart';
import 'package:foore/es_category_page/es_add_subcategory.dart';
import 'package:foore/es_category_page/es_subcategory_page.dart';
import 'package:foore/es_circles/es_circle_picker_view.dart';
import 'package:foore/es_circles/es_circle_search.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:foore/es_login_page/es_login_page.dart';
import 'package:foore/es_order_page/es_order_details.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/es_video_page/es_add_video.dart';
import 'package:foore/es_video_page/es_play_video.dart';
import 'package:foore/google_login_not_done_page/google_login_not_done_page.dart';
import 'package:foore/onboarding_page/location_claim.dart';
import 'package:foore/setting_page/sender_code.dart';
import 'package:foore/setting_page/settting_page.dart';
import 'package:foore/shopping_page/shopping_page.dart';
import 'package:provider/provider.dart';
import 'auth_guard/auth_guard.dart';
import 'data/bloc/app_update_bloc.dart';
import 'data/bloc/es_edit_product.dart';
import 'data/bloc/onboarding.dart';
import 'data/bloc/people.dart';
import 'data/http_service.dart';
import 'data/model/feedback.dart';
import 'data/model/unirson.dart';
import 'es_auth_guard/es_auth_guard.dart';
import 'es_business_catalogue_page/es_business_catalogue_page.dart';
import 'es_category_page/es_add_category.dart';
import 'es_category_page/es_category_page.dart';
import 'es_create_business/es_create_business.dart';
import 'es_create_merchant_profile/es_create_merchant_profile.dart';
import 'es_order_page/es_order_page.dart';
import 'es_order_page/es_order_add_item.dart';
import 'home_page/home_page.dart';
import 'intro_page/intro_page.dart';
import 'login_page/login_page.dart';
import 'menu_page/add_menu_item_page.dart';
import 'menu_page/menu_page.dart';
import 'onboarding_guard/onboarding_guard.dart';
import 'onboarding_page/location_search_page.dart';
import 'onboarding_page/location_verify.dart';
import 'onboarding_page/onboarding_page.dart';
import 'review_page/reply_gmb.dart';
import 'unirson_check_in_page/unirson_check_in_page.dart';

class AppRouter {
  static const homeRoute = '/';
  static const testRoute = MenuPage.routeName;
  final unauthenticatedHandler = (BuildContext context) => Navigator.of(context)
      .pushNamedAndRemoveUntil(
          IntroPage.routeName, (Route<dynamic> route) => false);

  final esUnauthenticatedHandler = (BuildContext context) =>
      Navigator.of(context).pushNamed(ShoppingPage.routeName);

  final esNoMerchantProfileHandler = (BuildContext context) =>
      Navigator.of(context).pushNamed(EsCreateMerchantProfilePage.routeName);

  final onboardingRequiredHandler = (BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(
          OnboardingPage.routeName, (Route<dynamic> route) => false);

  final esCreateBusinessRequiredHandler = (BuildContext context) =>
      Navigator.of(context).pushNamed(EsCreateBusinessPage.routeName);

  final HttpService httpServiceBloc;
  final AuthBloc authBloc;
  final EsBusinessesBloc esBusinessesBloc;

  AppRouter(
      {@required this.httpServiceBloc,
      @required this.authBloc,
      @required this.esBusinessesBloc});

  Route<dynamic> routeGenerator(RouteSettings settings) {
    print(settings.name);
    this.authBloc.foAnalytics.setCurrentScreen(settings.name);
    switch (settings.name) {
      case BusinessCategoriesPickerView.routeName:
        return MaterialPageRoute(
            builder: (context) => Provider<EsBusinessCategoriesBloc>(
                  create: (context) =>
                      EsBusinessCategoriesBloc(httpServiceBloc),
                  dispose: (context, bloc) => bloc.dispose(),
                  child: BusinessCategoriesPickerView(),
                ),
            settings: settings);
        break;
      case HomePage.routeName:
        return MaterialPageRoute(
          builder: (context) => AuthGuard(
            unauthenticatedPage: IntroPage(),
            child: OnboardingGuard(
              onboardingRequiredPage: Provider<OnboardingBloc>(
                builder: (context) => OnboardingBloc(httpServiceBloc),
                dispose: (context, value) => value.dispose(),
                child: OnboardingPage(),
              ),
              child: MultiProvider(
                providers: [
                  Provider<PeopleBloc>(
                    builder: (context) => PeopleBloc(httpServiceBloc),
                    dispose: (context, value) => value.dispose(),
                  ),
                ],
                child: HomePage(),
              ),
            ),
          ),
        );
        break;
      case IntroPage.routeName:
        return MaterialPageRoute(
          builder: (context) => IntroPage(),
        );
      case ReplyGmb.routeName:
        FeedbackItem feedbackItem = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => ReplyGmb(feedbackItem),
          fullscreenDialog: true,
        );
      case UnirsonCheckInPage.routeName:
        UnirsonItem unirsonItem = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => UnirsonCheckInPage(unirsonItem),
          fullscreenDialog: true,
        );
      case OnboardingPage.routeName:
        return MaterialPageRoute(
          builder: (context) => Provider<OnboardingBloc>(
            builder: (context) => OnboardingBloc(httpServiceBloc),
            dispose: (context, value) => value.dispose(),
            child: OnboardingPage(),
          ),
        );
        break;
      case LoginPage.routeName:
        return MaterialPageRoute(
          builder: (context) => LoginPage(),
        );
        break;
      case LocationSearchPage.routeName:
        bool hideNoLocations = settings.arguments ?? false;
        return MaterialPageRoute(
          builder: (context) => LocationSearchPage(
            hideNoLocations: hideNoLocations,
          ),
        );
        break;
      case LocationClaimPage.routeName:
        return LocationClaimPage.generateRoute(
          settings,
          authBloc: this.authBloc,
          httpService: this.httpServiceBloc,
        );
        break;
      case LocationVerifyPage.routeName:
        return LocationVerifyPage.generateRoute(
          settings,
          authBloc: this.authBloc,
          httpService: this.httpServiceBloc,
        );
        break;
      case GoogleLoginNotDonePage.routeName:
        return GoogleLoginNotDonePage.generateRoute(settings);
        break;
      case SettingPage.routeName:
        return SettingPage.generateRoute(settings, httpServiceBloc);
        break;
      case SenderCodePage.routeName:
        return SenderCodePage.generateRoute(settings, httpServiceBloc);
        break;
      case ShoppingPage.routeName:
        return MaterialPageRoute(
          builder: (context) => ShoppingPage(),
        );
        break;
      case EsLoginPage.routeName:
        return MaterialPageRoute(
          builder: (context) => EsLoginPage(false),
        );
        break;
      case EsLoginPage.signUpRouteName:
        return MaterialPageRoute(
          builder: (context) => EsLoginPage(true),
        );
        break;
      case homeRoute:
        return MaterialPageRoute(
          builder: (context) => Provider(
            create: (context) => EsAppUpdateBloc(),
            dispose: (context, value) => value.dispose(),
            child: EsAuthGuard(
              unauthenticatedPage: ShoppingPage(),
              noMerchantProfilePage: Provider(
                builder: (context) =>
                    EsCreateMerchantProfileBloc(httpServiceBloc, authBloc),
                dispose: (context, value) => value.dispose(),
                child: EsCreateMerchantProfilePage(),
              ),
              child: EsBusinessesGuard(
                createBusinessRequiredHandler: esCreateBusinessRequiredHandler,
                child: MultiProvider(
                  providers: [
                    Provider<PeopleBloc>(
                      builder: (context) => PeopleBloc(httpServiceBloc),
                      dispose: (context, value) => value.dispose(),
                    ),
                    Provider<EsVideoBloc>(
                      builder: (context) =>
                          EsVideoBloc(httpServiceBloc, esBusinessesBloc),
                      dispose: (context, value) => value.dispose(),
                    ),
                    Provider<EsOrdersBloc>(
                      create: (context) =>
                          EsOrdersBloc(httpServiceBloc, esBusinessesBloc),
                      dispose: (context, value) => value.dispose(),
                    ),
                  ],
                  child: EsHomePage(httpServiceBloc),
                ),
              ),
            ),
          ),
        );
        break;
      case EsCreateBusinessPage.routeName:
        return MaterialPageRoute(
          builder: (context) => Provider<EsCreateBusinessBloc>(
            builder: (context) => EsCreateBusinessBloc(httpServiceBloc),
            dispose: (context, value) => value.dispose(),
            child: EsCreateBusinessPage(),
          ),
        );
        break;
      case EsCreateMerchantProfilePage.routeName:
        return EsCreateMerchantProfilePage.generateRoute(
            settings, httpServiceBloc, authBloc);
        break;
      case MenuPage.routeName:
        return MaterialPageRoute(
          builder: (context) => Provider<OnboardingBloc>(
            builder: (context) => OnboardingBloc(httpServiceBloc),
            dispose: (context, value) => value.dispose(),
            child: MenuPage(),
          ),
        );
        break;
      case EsBusinessCataloguePage.routeName:
        return MaterialPageRoute(
          builder: (context) => Provider<EsBusinessCatalogueBloc>(
            create: (context) => EsBusinessCatalogueBloc(httpServiceBloc, esBusinessesBloc),
            dispose: (context, value) => value.dispose(),
            child: EsBusinessCataloguePage(),
          ),
        );
        break;
      case AddMenuItemPage.routeName:
        EsProduct esProduct = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => Provider<EsEditProductBloc>(
            builder: (context) =>
                EsEditProductBloc(httpServiceBloc, esBusinessesBloc),
            dispose: (context, value) => value.dispose(),
            child: AddMenuItemPage(esProduct),
          ),
        );
        break;
      case EsProductDetailPage.routeName:
        EsProductDetailPageParam esProductDetailPageParam = settings.arguments;

        return MaterialPageRoute(
          builder: (context) => Provider<EsEditProductBloc>(
            builder: (context) =>
                EsEditProductBloc(httpServiceBloc, esBusinessesBloc),
            dispose: (context, value) => value.dispose(),
            child: EsProductDetailPage(esProductDetailPageParam.currentProduct,
                openSkuAddUpfront: esProductDetailPageParam.openSkuAddUpfront),
          ),
        );
        break;
      case EsCategoryPage.routeName:
        List<int> selectedCategories = settings.arguments;
        return MaterialPageRoute(
          builder: (context) =>
              EsCategoryPage(selectedCategoryIds: selectedCategories),
        );
        break;
      case EsSubCategoryPage.routeName:
        EsSabCategoryParam categoryParam = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => EsSubCategoryPage(
              categoryParam.parentCategory, categoryParam.esCategoriesBloc),
        );
        break;
      case EsAddCategoryPage.routeName:
        return MaterialPageRoute(
          builder: (context) => EsAddCategoryPage(),
        );
        break;

      case EsAddSubCategoryPage.routeName:
        EsAddSubCategoryPageParams addSubCategoryParam = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => EsAddSubCategoryPage(
              addSubCategoryParam.parentCategoryId,
              addSubCategoryParam.parentCategoryName),
        );
        break;
      case EsOrderPage.routeName:
        return MaterialPageRoute(
          builder: (context) => EsOrderPage(),
        );
        break;
      case EsOrderDetails.routeName:
        return MaterialPageRoute(
          builder: (context) => EsOrderDetails(settings.arguments),
        );
        break;
      case EsAddVideo.routeName:
        return MaterialPageRoute(
          builder: (context) => Provider<EsVideoBloc>(
            builder: (context) =>
                EsVideoBloc(httpServiceBloc, esBusinessesBloc),
            dispose: (context, value) => value.dispose(),
            child: EsAddVideo(),
          ),
        );
        break;
      case PlayVideoPage.routeName:
        return MaterialPageRoute(
          builder: (context) => Provider<EsVideoBloc>(
            builder: (context) =>
                EsVideoBloc(httpServiceBloc, esBusinessesBloc),
            dispose: (context, value) => value.dispose(),
            child: PlayVideoPage(settings.arguments),
          ),
        );
      case EsOrderAddItem.routeName:
        return MaterialPageRoute(
          builder: (context) => EsOrderAddItem(),
        );
        break;
      case SearchAddressView.routeName:
        return MaterialPageRoute(
          builder: (context) => SearchAddressView(),
        );
        break;
      case AddNewAddressView.routeName:
        return MaterialPageRoute(
          builder: (context) => AddNewAddressView(),
        );
        break;
      case CirclePickerView.routeName:
        return MaterialPageRoute(
            builder: (context) => Provider<EsSelectCircleBloc>(
                  create: (context) => EsSelectCircleBloc(httpServiceBloc),
                  dispose: (context, bloc) => bloc.dispose(),
                  child: CirclePickerView(),
                ));
        break;
      case CircleSearchView.routeName:
        return MaterialPageRoute(
            builder: (context) => CircleSearchView(), settings: settings);
        break;
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
