import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/cart_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/app_constants.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/screens/menu/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebMenuBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    bool _showJoin =
        (Get.find<SplashController>().configModel?.toggleDmRegistration ==
                    true ||
                Get.find<SplashController>()
                        .configModel
                        ?.toggleRestaurantRegistration ==
                    true) &&
            ResponsiveHelper.isDesktop(context);
    List<PopupMenuEntry<int>> _entryList = [];
    if (Get.find<SplashController>().configModel?.toggleDmRegistration ==
        true) {
      _entryList.add(PopupMenuItem(
          child: Text('join_as_a_delivery_man'.tr),
          onTap: () async {
            if (await canLaunchUrlString(
                '${AppConstants.BASE_URL}/deliveryman/apply')) {
              launchUrlString('${AppConstants.BASE_URL}/deliveryman/apply',
                  mode: LaunchMode.externalApplication);
            }
          }));
    }
    if (Get.find<SplashController>()
            .configModel
            ?.toggleRestaurantRegistration ==
        true) {
      _entryList.add(PopupMenuItem(
          child: Text('join_as_a_restaurant'.tr),
          onTap: () async {
            if (await canLaunchUrlString(
                '${AppConstants.BASE_URL}/restaurant/apply')) {
              launchUrlString('${AppConstants.BASE_URL}/restaurant/apply',
                  mode: LaunchMode.externalApplication);
            }
          }));
    }

    return Center(
        child: Container(
      width: Dimensions.WEB_MAX_WIDTH,
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      child: Row(children: [
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getInitialRoute()),
          child: Image.asset(Images.logo, height: 50, width: 50),
        ),
        Get.find<LocationController>().getUserAddress() != null
            ? Expanded(
                child: InkWell(
                onTap: () =>
                    Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: GetBuilder<LocationController>(
                      builder: (locationController) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          locationController.getUserAddress()?.addressType ==
                                  'home'
                              ? Icons.home_filled
                              : locationController
                                          .getUserAddress()
                                          ?.addressType ==
                                      'office'
                                  ? Icons.work
                                  : Icons.location_on,
                          size: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        Flexible(
                          child: Text(
                            locationController
                                    .getUserAddress()
                                    ?.address
                                    .toString() ??
                                '',
                            style: robotoRegular.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: Theme.of(context).primaryColor),
                      ],
                    );
                  }),
                ),
              ))
            : Expanded(child: SizedBox()),
        MenuButton(
            icon: Icons.home,
            title: 'home'.tr,
            onTap: () => Get.toNamed(RouteHelper.getInitialRoute())),
        SizedBox(width: 20),
        MenuButton(
            icon: Icons.search,
            title: 'search'.tr,
            onTap: () => Get.toNamed(RouteHelper.getSearchRoute())),
        SizedBox(width: 20),
        MenuButton(
            icon: Icons.notifications,
            title: 'notification'.tr,
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute())),
        SizedBox(width: 20),
        MenuButton(
            icon: Icons.favorite_outlined,
            title: 'favourite'.tr,
            onTap: () => Get.toNamed(RouteHelper.getMainRoute('favourite'))),
        SizedBox(width: 20),
        MenuButton(
            icon: Icons.shopping_cart,
            title: 'my_cart'.tr,
            isCart: true,
            onTap: () => Get.toNamed(RouteHelper.getCartRoute())),
        SizedBox(width: 20),
        MenuButton(
            icon: Icons.menu,
            title: 'menu'.tr,
            onTap: () {
              Get.bottomSheet(MenuScreen(),
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true);
            }),
        SizedBox(width: 20),
        GetBuilder<AuthController>(builder: (authController) {
          return MenuButton(
            icon: authController.isLoggedIn() ? Icons.shopping_bag : Icons.lock,
            title: authController.isLoggedIn() ? 'my_orders'.tr : 'sign_in'.tr,
            onTap: () => Get.toNamed(authController.isLoggedIn()
                ? RouteHelper.getMainRoute('order')
                : RouteHelper.getSignInRoute(RouteHelper.main)),
          );
        }),
        SizedBox(width: _showJoin ? 20 : 0),
        _showJoin
            ? PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => _entryList,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_SMALL,
                      vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  ),
                  child: Row(children: [
                    Text('join_us'.tr,
                        style: robotoMedium.copyWith(color: Colors.white)),
                    Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
                  ]),
                ),
              )
            : SizedBox(),
      ]),
    ));
  }

  @override
  Size get preferredSize => Size(Dimensions.WEB_MAX_WIDTH, 70);
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isCart;
  final void Function() onTap;
  MenuButton(
      {required this.icon,
      required this.title,
      this.isCart = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(children: [
        Stack(clipBehavior: Clip.none, children: [
          Icon(icon, size: 20),
          isCart
              ? GetBuilder<CartController>(builder: (cartController) {
                  return cartController.cartList.length > 0
                      ? Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            height: 15,
                            width: 15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor),
                            child: Text(
                              cartController.cartList.length.toString(),
                              style: robotoRegular.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).cardColor),
                            ),
                          ),
                        )
                      : SizedBox();
                })
              : SizedBox(),
        ]),
        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        Text(title,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
      ]),
    );
  }
}
