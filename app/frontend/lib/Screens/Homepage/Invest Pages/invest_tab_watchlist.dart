// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:ui';

import 'package:smolstock/Config/api_integration.dart';
import 'package:smolstock/Config/websocket_integration.dart';
import 'package:smolstock/Models/coin_model.dart';
import 'package:smolstock/Routing/route_names.dart';
import 'package:smolstock/Screens/Utilities/Riverpod/riverpod_variables.dart';
import 'package:smolstock/Screens/Utilities/Widgets/watchlist_coin_tile_builder.dart';
import 'package:smolstock/Screens/Utilities/Widgets/log_in_button.dart';
import 'package:smolstock/Screens/Utilities/Widgets/utilities.dart';
import 'package:smolstock/Screens/Utilities/static_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toast/toast.dart';

class InvestTabWatchlist extends ConsumerWidget {
  InvestTabWatchlist({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCoinsAsyncValue = ref.watch(allCoinsSocketProvider);
    return allCoinsAsyncValue.when(
      data: (data) {
        data = data['watchlist'];
        log(data.toString());
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 194,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: data.length + 1,
                  itemBuilder: (context, index) {
                    return ((index) != (data.length))
                        ? GestureDetector(
                            onTap: () {
                              context.goNamed(RouteNames.coinPage,
                                  pathParameters: {
                                    "shortName": App.currentCoin!
                                  });
                            },
                            child: WatchlistCoinTileBuilder(
                                coin: Coin(
                                  fullName: data[index]['FullName'],
                                  shortForm: data[index]['Name'],
                                  image:
                                      "https://www.${data[index]['ImageURL']}",
                                  price: data[index]['Price'],
                                  changePercent: data[index]['ChangePct'],
                                ),
                                index: index),
                          )
                        : (index == 0)
                            ? SizedBox(
                                height: 84,
                                child: Center(
                                  child: Text(
                                    "No Watchlist Sadly   :C",
                                    style: titleMedium(),
                                  ),
                                ),
                              )
                            : Container(
                                height: 84,
                              );
                  },
                ),
                ref.watch(watchlistPopUpProvider)
                    ? SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05)),
                            child: Center(
                              child: Container(
                                color: Palette.secondaryBlackColor,
                                width: 264,
                                height: 362,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                            icon: const Icon(
                                              Icons.close_sharp,
                                              color: Palette
                                                  .secondaryOffWhiteColor,
                                            ),
                                            onPressed: () {
                                              coinPagePopupNotifier.toggle();
                                            }),
                                      ),
                                      const SizedBox(height: 9),
                                      Text(
                                        "Do You Want To Buy",
                                        style: titleMedium(),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Current Price     €${data[App.watchlistIndex]['Price'].toStringAsFixed(4)}",
                                        style: bodyLarge(),
                                      ),
                                      const SizedBox(height: 30),
                                      TextFormField(
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        onChanged: (text) {
                                          watchlistCoinControllerNotifier
                                              .setVal(text);
                                        },
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        style: bodyMedium(),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          hintStyle: bodyMedium(),
                                          labelText: "Amount",
                                          hintText: "Enter the amount",
                                          labelStyle: labelMedium(),
                                          errorBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              borderSide: BorderSide(
                                                  color: Palette
                                                      .secondaryOffWhiteColor,
                                                  width: 2)),
                                          enabledBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              borderSide: BorderSide(
                                                  color: Palette
                                                      .secondaryOffWhiteColor,
                                                  width: 2)),
                                          disabledBorder:
                                              const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                      color: Palette
                                                          .secondaryOffWhiteColor,
                                                      width: 2)),
                                          focusedBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              borderSide: BorderSide(
                                                  color: Palette
                                                      .secondaryOffWhiteColor,
                                                  width: 2)),
                                          border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12)),
                                              borderSide: BorderSide(
                                                  color: Palette
                                                      .secondaryOffWhiteColor,
                                                  width: 2)),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Total Cost   €${(data[App.watchlistIndex]['Price'] * (ref.watch(watchlistCoinControllerProvider) ?? 1)).toStringAsFixed(4)}",
                                        style: bodyLarge(),
                                      ),
                                      const SizedBox(height: 20),
                                      LogInButton(
                                        loaderProvider:
                                            watchlistButtonLoaderProvider,
                                        text: "Buy",
                                        function: () async {
                                          watchlistButtonLoaderNotifier
                                              .toggle();
                                          final output = await ApiCalls.buyCoin(
                                              ref.watch(
                                                      watchlistCoinControllerProvider) ??
                                                  1);

                                          if (output['statusCode'] == 202) {
                                            watchlistPopupNotifier.toggle;
                                            ToastContext().init(context);
                                            Toast.show(
                                                output[output.keys.first][0],
                                                duration: 5,
                                                gravity: Toast.bottom);
                                          } else {
                                            ToastContext().init(context);
                                            Toast.show(
                                                output[output.keys.first][0],
                                                duration: 5,
                                                gravity: Toast.bottom);
                                          }
                                          watchlistButtonLoaderNotifier
                                              .toggle();
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(
            child: Text(
          error.toString(),
          style: headlineLarge(),
        ));
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Palette.primaryColor),
      ),
    );
  }
}
