part of 'welcome_route.dart';

/// View for [WelcomeRoute].
class WelcomeView extends StatelessWidget {
  /// Creates an instance of [WelcomeView].
  const WelcomeView(this.state, {super.key});

  /// A controller for this view.
  final WelcomeController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        // On this screen, there are, by definition, no devices to display.
        devices: [],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Insets.medium,
            ),
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                // Welcome message
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.medium,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'test',//AppLocalizations.of(context)!.addADevice,
                      style: GoogleFonts.bungee().copyWith(
                        fontSize: 52,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Insets.small,
                    horizontal: Insets.xLarge,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      AppLocalizations.of(context)!.addDeviceInvitation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColorDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Add device button
                SliverPadding(
                  padding: const EdgeInsets.only(top: Insets.medium),
                  sliver: SliverToBoxAdapter(
                    child: AddDeviceButton(
                      onPressed: state.onAddDevicePressed,
                    ),
                  ),
                ),

                // Bottom CTA button
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.salesPrompt,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Insets.xSmall,
                        ),
                        child: LightButton(
                          text: AppLocalizations.of(context)!.getOneNow,
                          onPressed: state.onOrderButtonPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
