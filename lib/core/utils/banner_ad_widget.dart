// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:revocourse/core/utils/ad_helper.dart';


// class BannerAdWidget extends StatefulWidget {
//   const BannerAdWidget({super.key}); // ← removed 'final', added 'const'

//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState(); // ✅ Fixed
// }

// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   BannerAd? _bannerAd;
//   bool _isLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }

//   void _loadAd() {
  
//     if(2==4){
//   _bannerAd = BannerAd(
//       adUnitId: AdHelper.bannerAdUnitId,
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() => _isLoaded = true);
//           debugPrint('✅ Banner Ad Loaded');
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('ADMOB  ERROR CODE: ${error.code}');
//           debugPrint('ADMOB  ERROR DOMAIN: ${error.domain}');
//           debugPrint('ADMOB  ERROR MESSAGE: ${error.message}');
//           debugPrint('ADMOB  RESPONSE INFO: ${error.responseInfo}');
//           ad.dispose();
//         },
//       ),
//     )..load();
//     }
  
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded) {
//       return const SizedBox.shrink();
//     }
//     return SizedBox(
//       width: _bannerAd!.size.width.toDouble(),
//       height: _bannerAd!.size.height.toDouble(),
//       child: AdWidget(ad: _bannerAd!),
//     );
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
// }
