import '../../../components/navigable_page.dart';
import 'thanks_controller.dart';

/// A special page thanking the visitor for signing up for updates from Brine. This page is only shown after the user
/// submits the form used to enroll for updates. It features a very cute little frog saying, "thanks."
class ThanksRoute extends NavigablePage {
  static String get screenName => '/thanks';

  /// The first name of the visitor, as supplied in the email optin form.
  final String name;

  const ThanksRoute({
    required this.name,
    super.key,
  });

  @override
  ThanksController createState() => ThanksController();
}
