import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:fluttermulticity/config/ps_colors.dart';
import 'package:fluttermulticity/config/ps_config.dart';
import 'package:fluttermulticity/constant/ps_dimens.dart';
import 'package:fluttermulticity/provider/language/language_provider.dart';
import 'package:fluttermulticity/repository/language_repository.dart';
import 'package:fluttermulticity/ui/common/dialog/confirm_dialog_view.dart';
import 'package:fluttermulticity/ui/common/ps_admob_banner_widget.dart';
import 'package:fluttermulticity/ui/common/ps_dropdown_base_widget.dart';
import 'package:fluttermulticity/utils/utils.dart';
import 'package:provider/provider.dart';

class LanguageSettingView extends StatefulWidget {
  const LanguageSettingView(
      {Key key,
      @required this.animationController,
      @required this.languageIsChanged})
      : super(key: key);
  final AnimationController animationController;
  final Function languageIsChanged;
  @override
  _LanguageSettingViewState createState() => _LanguageSettingViewState();
}

class _LanguageSettingViewState extends State<LanguageSettingView> {
  String currentLang = '';
  LanguageRepository repo1;

  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: widget.animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    widget.animationController.forward();
    final LanguageRepository repo1 = Provider.of<LanguageRepository>(context);

    return ChangeNotifierProvider<LanguageProvider>(
      lazy: false,
      create: (BuildContext context) {
        final LanguageProvider provider = LanguageProvider(repo: repo1);
        provider.getLanguageList();
        return provider;
      },
      child: Consumer<LanguageProvider>(builder:
          (BuildContext context, LanguageProvider provider, Widget child) {
        return AnimatedBuilder(
            animation: widget.animationController,
            child: SingleChildScrollView(
                child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    padding: const EdgeInsets.all(PsDimens.space4),
                    decoration: BoxDecoration(
                      color: Utils.isLightMode(context)
                          ? PsColors.white
                          : Colors.black12,
                      // Utils.isLightMode
                      //     ? Colors.black12
                      //     : PsColors.mainColor
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/flutter_app_icon.png',
                          width: PsDimens.space120,
                          height: PsDimens.space80,
                        ),
                        // Container(
                        //   width: 90,
                        //   height: 90,
                        //   child: Image.asset(
                        //     'assets/images/flutter_app_icon.png',
                        //   ),
                        // ),
                        const SizedBox(
                          height: PsDimens.space8,
                        ),
                        Text(
                          Utils.getString(context, 'app_name'),
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(color: PsColors.mainColor),
                        ),
                      ],
                    ),
                  ),
                  PsDropdownBaseWidget(
                      title: Utils.getString(context, ''),
                      selectedText: provider.getLanguage().name,
                      onTap: () {
                        showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(Utils.getString(
                                    context, 'language_selection__title')),
                                content: Container(
                                  width: 400.0,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: provider.languageList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              provider.languageList[index].name,
                                              textAlign: TextAlign.start,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            ),
                                            Visibility(
                                              visible:
                                                  provider.getLanguage().name ==
                                                      provider
                                                          .languageList[index]
                                                          .name,
                                              child: const Icon(
                                                AntDesign.checkcircle,
                                                color: Colors.green,
                                                size: PsDimens.space20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          print(provider
                                              .languageList[index].name);
                                          Navigator.pop(context);
                                          showDialog<dynamic>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmDialogView(
                                                    description: Utils.getString(
                                                        context,
                                                        'home__language_dialog_description'),
                                                    leftButtonText:
                                                        Utils.getString(context,
                                                            'dialog__cancel'),
                                                    rightButtonText:
                                                        Utils.getString(context,
                                                            'dialog__ok'),
                                                    onAgreeTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      provider.addLanguage(
                                                          provider.languageList[
                                                              index]);
                                                      EasyLocalization.of(
                                                                  context)
                                                              .locale =
                                                          Locale(
                                                              provider
                                                                  .languageList[
                                                                      index]
                                                                  .languageCode,
                                                              provider
                                                                  .languageList[
                                                                      index]
                                                                  .countryCode);
                                                    });
                                              });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            });
                      }),
                  const PsAdMobBannerWidget(
                    //admobBannerSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                    admobSize: NativeAdmobType.full,
                  ),
                ],
              ),
            )),
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: child));
            });
      }),
    );
  }
}
