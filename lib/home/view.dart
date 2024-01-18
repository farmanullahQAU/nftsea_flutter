import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nft_sea/home_controller.dart';
import 'package:web3dart/web3dart.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.uploadToPinata,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(),
      body: GetBuilder<HomeController>(builder: (_) {
        return Column(
          children: [
            GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: controller.nfts.length,
                itemBuilder: (context, index) {
                  final nft = controller.nfts[index];

                  return FutureBuilder(
                      future: controller.getMetadataFromIPFS(nft.uri),
                      builder: (context, snapshot) {
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: context.width,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: NetworkImage(
                                                "https://ipfs.io/ipfs/${snapshot.data?["imageCID"] ?? ""}"))),
                                    // child: Image.network(
                                    //   "https://ipfs.io/ipfs/${snapshot.data?["imageCID"] ?? ""}",
                                    //   width: context.width * 0.1,
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
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
                                  height: 8,
                                ),
                                Text(
                                    "${snapshot.data?["name"]} ${nft.tokenId.toString()}"),
                                Text(
                                  "Buy Now",
                                  style: context.theme.textTheme.bodySmall,
                                ),
                                Row(
                                  children: [
                                    Text(
                                        "${controller.convertWeiToEther(nft.price)} Ether"),
                                    IconButton(
                                        style: IconButton.styleFrom(
                                            visualDensity:
                                                VisualDensity.comfortable,
                                            tapTargetSize: MaterialTapTargetSize
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
                        );
                      });
                })
          ],
        );
      }),
    );
  }
}
