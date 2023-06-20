import '../../../components/navigable_page.dart';
import 'setup_controller.dart';

/// Before the visitor can be navigated to the place where they belong, we need to determine if they are a new visitor.
/// This screen simply displays a loading indicator while this determination is made.
class SetupRoute extends NavigablePage {
  String get screenName => '/';

  const SetupRoute({
    super.key,
  });

  @override
  SetupController createState() => SetupController();
}
