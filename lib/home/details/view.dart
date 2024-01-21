import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nft_sea/home/controller.dart';
import 'package:nft_sea/home/details/controller.dart';
import 'package:nft_sea/home_controller.dart';
import 'package:nft_sea/services/walletconnect.dart';
import 'package:web3dart/web3dart.dart';

class NftDetailsView extends StatelessWidget {
  final controller = Get.put(NftDetailsViewController());

  final walletServices = Get.find<WalletServices>();

  NftDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<NftDetailsViewController>(builder: (_) {
        return Scaffold(
            drawer: Drawer(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(controller.connectedAccountAddress()?.hex ?? "")
              ]),
            ),
            body: FutureBuilder(
              future: controller.getMetadataFromIPFS(controller.nft.uri),
              builder: (context, snapshot) {
                return CustomScrollView(
                  controller: controller.scrollController,
                  shrinkWrap: true,
                  slivers: [
                    SliverAppBar(
                      stretchTriggerOffset: 100,
                      onStretchTrigger: () {
                        // Function callback for stretch
                        print("sssssbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
                        return Future.delayed(Duration(seconds: 1));
                      },
                      stretch: true,
                      pinned: true,
                      centerTitle: true,
                      // flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        "${snapshot.data?["name"]}",
                      ),
                      //   centerTitle: false,
                      //   background: Container(
                      //     color: context.theme.primaryColor,
                      //     child: Image.network(
                      //         "https://ipfs.io/ipfs/${snapshot.data?["image"] ?? ""}"),
                      //   ),
                      // ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return GetBuilder<NftDetailsViewController>(
                              builder: (_) {
                            return Column(
                              children: [
                                Card(
                                  color: context.theme.primaryColor,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: context.width,
                                          height: 100,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: NetworkImage(
                                                      "https://ipfs.io/ipfs/${snapshot.data?["image"] ?? ""}"))),
                                          // child: Image.network(
                                          //   "https://ipfs.io/ipfs/${snapshot.data?["imageCID"] ?? ""}",
                                          //   width: context.width * 0.1,
                                          //   fit: BoxFit.cover,
                                          // ),
                                        ),
                                        // CachedNetworkImage(
                                        //   imageUrl:
                                        //       "https://ipfs.io/ipfs/${snapshot.data?["imageCID"] ?? ""}",
                                        //   placeholder: (context, url) =>
                                        //       CircularProgressIndicator(),
                                        //   errorWidget: (context, url, error) =>
                                        //       Icon(Icons.error),
                                        // ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          children: [
                                            Text("${snapshot.data?["name"]}"),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 4),
                                                decoration: BoxDecoration(
                                                    border: Border.all(),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Text(
                                                    "#${controller.nft.tokenId}"))
                                          ],
                                        ),
                                        Text(
                                          snapshot.data?["description"],
                                          style:
                                              context.theme.textTheme.bodySmall,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "${controller.convertWeiToEther(controller.nft.price)} Ether"),
                                            Spacer(),
                                            IconButton(
                                                style: IconButton.styleFrom(
                                                    visualDensity: VisualDensity
                                                        .comfortable,
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    padding: EdgeInsets.zero),
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.favorite_outline,
                                                  size: 8,
                                                ))
                                          ],
                                        ),
                                        // Text("${nft.price} ETH"),

                                        // Text("${nft.owner}")
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            );
                          });
                        },
                        childCount: 1,
                      ),
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: ElevatedButton(
                onPressed: () {
                  showSheet(context);
                },
                child: Text("Connect wallet to buy")));
      }),
    );
  }

  showSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return GetBuilder<NftDetailsViewController>(builder: (_) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: context.theme.canvasColor,
                    radius: 12,
                    child: Text("1")),
                title: Text("Connect Wallet"),
                trailing: controller.sessionData != null
                    ? Icon(
                        Icons.check_circle,
                        color: context.theme.primaryColor,
                      )
                    : null,
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: context.theme.canvasColor,
                    radius: 12,
                    child: Text("1")),
                title: Text("Sing Message"),
                trailing: Icon(
                  Icons.check_circle,
                  color: context.theme.primaryColor,
                ),
              ),
              OutlinedButton(
                  onPressed: controller.contrinue, child: Text("Continue"))
            ],
          );
        });
      },
    );
  }
}

/// Flutter code sample for [SliverAppBar].



