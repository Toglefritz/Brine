import '../../../components/navigable_page.dart';
import 'landing_controller.dart';

/// A landing page used to explain and sell the features of **HerdGPT** to visitors and includes calls to action
/// that drive visitors to start using the service. Also includes supplementary resources such as press kits,
/// resources, legal information, and other assets.
class LandingRoute extends NavigablePage {
  @override
  String get screenName => '/';

  const LandingRoute({super.key});

  @override
  LandingController createState() => LandingController();
}
