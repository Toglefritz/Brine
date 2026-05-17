part of 'scan_route.dart';

/// View for the [ScanRoute].
class ScanViewNoneFound extends StatelessWidget {
  /// Creates an instance of [ScanViewNoneFound].
  const ScanViewNoneFound(this.state, {super.key});

  /// A controller for this view.
  final ScanController state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Insets.medium,
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.small,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.noDevicesFoundMessage,
                    style: GoogleFonts.bungee().copyWith(
                      fontSize: 52,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(
                  Insets.medium,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    AppLocalizations.of(context)!.noDevicesFoundDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    LightButton(
                      text: AppLocalizations.of(context)!.tryAgain,
                      onPressed: state.onTryAgain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
