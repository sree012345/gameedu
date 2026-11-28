import '../models/faq_item.dart';
import 'faq_data.dart';

/// Where the FAQs come from. Now: the list in faq_data.dart.
/// To load them from Firestore later, change only this class.
class FaqRepository {
  const FaqRepository();

  Future<List<FaqItem>> fetchFaqs() async => kFaqItems;
}
