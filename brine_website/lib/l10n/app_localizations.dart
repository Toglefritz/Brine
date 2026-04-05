import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations returned by
/// `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's `localizationDelegates` list, and the
/// locales they support in the app's `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
/// localizationsDelegates: AppLocalizations.localizationsDelegates,
/// supportedLocales: AppLocalizations.supportedLocales,
/// home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following packages:
///
/// ```yaml
/// dependencies:
/// # Internationalization support.
/// flutter_localizations:
/// sdk: flutter
/// intl: any # Use the pinned version from flutter_localizations
///
/// # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported locales, in an Info.plist file that is built
/// into the application bundle. To configure the locales supported by your app, you’ll need to edit this file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file. Then, in the Project Navigator, open the
/// Info.plist file under the Runner project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the Editor menu, then select Localizations
/// from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each locale your application supports, add a new
/// item and select the locale you wish to add from the pop-up menu in the Value field. This list should be consistent
/// with the languages listed in the AppLocalizations.supportedLocales property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, and
  /// GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in MaterialApp. This list does not have to be used at
  /// all if a custom list of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @accessInsiderPortal.
  ///
  /// In en, this message translates to: **'Access the Insider Portal'**
  String get accessInsiderPortal;

  /// No description provided for @addTeamMember.
  ///
  /// In en, this message translates to: **'Add a Team Member'**
  String get addTeamMember;

  /// No description provided for @appStoresApproval.
  ///
  /// In en, this message translates to: **'App stores approval'**
  String get appStoresApproval;

  /// No description provided for @architecturalDesign.
  ///
  /// In en, this message translates to: **'Architectural design'**
  String get architecturalDesign;

  /// No description provided for @assemblePCBPrototypes.
  ///
  /// In en, this message translates to: **'Assemble PCB prototypes'**
  String get assemblePCBPrototypes;

  /// No description provided for @automatedTestSetup.
  ///
  /// In en, this message translates to: **'Automated test setup'**
  String get automatedTestSetup;

  /// No description provided for @backendAPIIntegration.
  ///
  /// In en, this message translates to: **'Backend API integration'**
  String get backendAPIIntegration;

  /// No description provided for @batteryExplanation.
  ///
  /// In en, this message translates to: **'Three AA batteries power Brine for up to a year.'**
  String get batteryExplanation;

  /// No description provided for @bluetoothProvisioningFlow.
  ///
  /// In en, this message translates to: **'Bluetooth provisioning flow'**
  String get bluetoothProvisioningFlow;

  /// No description provided for @buildOTASystem.
  ///
  /// In en, this message translates to: **'Build OTA system'**
  String get buildOTASystem;

  /// No description provided for @businessDevelopment.
  ///
  /// In en, this message translates to: **'Business Development'**
  String get businessDevelopment;

  /// No description provided for @brandingStrategy.
  ///
  /// In en, this message translates to: **'Branding strategy'**
  String get brandingStrategy;

  /// No description provided for @breadboardPrototypes.
  ///
  /// In en, this message translates to: **'Build breadboard prototypes'**
  String get breadboardPrototypes;

  /// No description provided for @brine.
  ///
  /// In en, this message translates to: **'Brine'**
  String get brine;

  /// No description provided for @cadPrototypes.
  ///
  /// In en, this message translates to: **'Create CAD prototypes'**
  String get cadPrototypes;

  /// No description provided for @campaignPreparation.
  ///
  /// In en, this message translates to: **'Campaign preparation'**
  String get campaignPreparation;

  /// No description provided for @cloudDevelopment.
  ///
  /// In en, this message translates to: **'Cloud Development'**
  String get cloudDevelopment;

  /// No description provided for @componentSelection.
  ///
  /// In en, this message translates to: **'Component selection'**
  String get componentSelection;

  /// No description provided for @conceptRenderings.
  ///
  /// In en, this message translates to: **'Concept 2D/3D rendering'**
  String get conceptRenderings;

  /// No description provided for @configureServices.
  ///
  /// In en, this message translates to: **'Configure services'**
  String get configureServices;

  /// No description provided for @createCloudAPIs.
  ///
  /// In en, this message translates to: **'Create cloud APIs'**
  String get createCloudAPIs;

  /// No description provided for @createWebsite.
  ///
  /// In en, this message translates to: **'Create website'**
  String get createWebsite;

  /// No description provided for @crowdfundingCampaign.
  ///
  /// In en, this message translates to: **'Crowdfunding campaign'**
  String get crowdfundingCampaign;

  /// No description provided for @currentSaltLevel.
  ///
  /// In en, this message translates to: **'The level of salt in your water softener is down to only'**
  String get currentSaltLevel;

  /// No description provided for @defineSpecs.
  ///
  /// In en, this message translates to: **'Define specs'**
  String get defineSpecs;

  /// No description provided for @designPCB.
  ///
  /// In en, this message translates to: **'Design PCB'**
  String get designPCB;

  /// No description provided for @developCoreFeatures.
  ///
  /// In en, this message translates to: **'Develop core features'**
  String get developCoreFeatures;

  /// No description provided for @device.
  ///
  /// In en, this message translates to: **'Device'**
  String get device;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to: **'Electronics'**
  String get electronics;

  /// No description provided for @emailFieldHint.
  ///
  /// In en, this message translates to: **'Email in this one'**
  String get emailFieldHint;

  /// No description provided for @emailOptinButtonText.
  ///
  /// In en, this message translates to: **'Make it so'**
  String get emailOptinButtonText;

  /// No description provided for @emailOptinDescription.
  ///
  /// In en, this message translates to: **'Brine is coming soon to a water softener near you. Sign up for updates and,
  /// you know, maybe a couple discounts as well.'**
  String get emailOptinDescription;

  /// No description provided for @enoughConfetti.
  ///
  /// In en, this message translates to: **'That\'s quite enough confetti for you, sir.'**
  String get enoughConfetti;

  /// No description provided for @exploreHardwareOptions.
  ///
  /// In en, this message translates to: **'Explore hardware options'**
  String get exploreHardwareOptions;

  /// No description provided for @finalizeDatabaseSchema.
  ///
  /// In en, this message translates to: **'Finalize database schemas'**
  String get finalizeDatabaseSchema;

  /// No description provided for @finalizeElectronicsDesign.
  ///
  /// In en, this message translates to: **'Finalize electronics design'**
  String get finalizeElectronicsDesign;

  /// No description provided for @firmwareArchitectureDesign.
  ///
  /// In en, this message translates to: **'Firmware architecture design'**
  String get firmwareArchitectureDesign;

  /// No description provided for @firmwareDevelopment.
  ///
  /// In en, this message translates to: **'Firmware development'**
  String get firmwareDevelopment;

  /// No description provided for @frameworkSetup.
  ///
  /// In en, this message translates to: **'Framework setup'**
  String get frameworkSetup;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to: **'Let\'s Go!'**
  String get getStartedButton;

  /// No description provided for @identifyServiceProvider.
  ///
  /// In en, this message translates to: **'Identify service provider'**
  String get identifyServiceProvider;

  /// No description provided for @implementAnalytics.
  ///
  /// In en, this message translates to: **'Implement analytics'**
  String get implementAnalytics;

  /// No description provided for @implementAuthentication.
  ///
  /// In en, this message translates to: **'Implement authentication'**
  String get implementAuthentication;

  /// No description provided for @incorporateCloudAPIs.
  ///
  /// In en, this message translates to: **'Incorporate cloud APIs'**
  String get incorporateCloudAPIs;

  /// No description provided for @incorporateLLC.
  ///
  /// In en, this message translates to: **'Incorporate LLC'**
  String get incorporateLLC;

  /// No description provided for @increaseCleaningEffectiveness.
  ///
  /// In en, this message translates to: **'Increase Cleaning Effectiveness'**
  String get increaseCleaningEffectiveness;

  /// No description provided for @increaseCleaningEffectivenessExplanation.
  ///
  /// In en, this message translates to: **'Hard water not only reduces the effectiveness of soap but also it makes soap
  /// betray you and turn into soap scum.'**
  String get increaseCleaningEffectivenessExplanation;

  /// No description provided for @insiderPageIntro.
  ///
  /// In en, this message translates to: **'You might not have checked in a while so your water softener may be out of
  /// salt right now. Don\'t worry though, Brine will be launching soon on Kickstarter so you will be able to get
  /// notifications right on your phone when your salt is running low.'**
  String get insiderPageIntro;

  /// No description provided for @insiderPageTitle.
  ///
  /// In en, this message translates to: **'Welcome, Brine insider!'**
  String get insiderPageTitle;

  /// No description provided for @insiderPageSubtitle.
  ///
  /// In en, this message translates to: **'It\'s good to see you again, '**
  String get insiderPageSubtitle;

  /// No description provided for @landingPageDescription.
  ///
  /// In en, this message translates to: **'Brine is an app-connected device that monitors the salt level in your water
  /// softener and sends you alerts when it\'s time to refill. With Brine, you can ensure that your water softener is
  /// always working at its best.'**
  String get landingPageDescription;

  /// No description provided for @landingPageEmailInvite.
  ///
  /// In en, this message translates to: **'Get you on the list'**
  String get landingPageEmailInvite;

  /// No description provided for @landingPageHook.
  ///
  /// In en, this message translates to: **'It\'s super important to keep your water softener filled with salt! It helps
  /// remove minerals that can harm your pipes and appliances. But sometimes it\'s easy to forget to check the salt
  /// level. That\'s where Brine comes in!'**
  String get landingPageHook;

  /// No description provided for @landingPageTitle.
  ///
  /// In en, this message translates to: **'Never forget to fill your water softener with salt'**
  String get landingPageTitle;

  /// No description provided for @legalStuff.
  ///
  /// In en, this message translates to: **'Legal stuff:'**
  String get legalStuff;

  /// No description provided for @listCoreFeatures.
  ///
  /// In en, this message translates to: **'List core features'**
  String get listCoreFeatures;

  /// No description provided for @mobileDevelopment.
  ///
  /// In en, this message translates to: **'Mobile Development'**
  String get mobileDevelopment;

  /// No description provided for @moreConfetti.
  ///
  /// In en, this message translates to: **'More confetti'**
  String get moreConfetti;

  /// No description provided for @mountingExplanation.
  ///
  /// In en, this message translates to: **'The Brine monitor mounts inside your water softener.'**
  String get mountingExplanation;

  /// No description provided for @nameFieldHint.
  ///
  /// In en, this message translates to: **'First name right here'**
  String get nameFieldHint;

  /// No description provided for @now.
  ///
  /// In en, this message translates to: **'now'**
  String get now;

  /// No description provided for @planTransports.
  ///
  /// In en, this message translates to: **'Plan transports'**
  String get planTransports;

  /// No description provided for @powerManagementSystem.
  ///
  /// In en, this message translates to: **'Power management system'**
  String get powerManagementSystem;

  /// No description provided for @preLaunchCampaign.
  ///
  /// In en, this message translates to: **'Pre-Launch campaign'**
  String get preLaunchCampaign;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to: **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @promoteHealthySkinAndHair.
  ///
  /// In en, this message translates to: **'Promote healthy skin and hair'**
  String get promoteHealthySkinAndHair;

  /// No description provided for @promoteHealthySkinAndHairExplanation.
  ///
  /// In en, this message translates to: **'Hard water can strip away natural oils from the skin and hair, leading to
  /// dryness, irritation.'**
  String get promoteHealthySkinAndHairExplanation;

  /// No description provided for @proofOfPossessionCheck.
  ///
  /// In en, this message translates to: **'Proof of possession check'**
  String get proofOfPossessionCheck;

  /// No description provided for @protectClothingAndFabrics.
  ///
  /// In en, this message translates to: **'Protect Clothing and Fabrics'**
  String get protectClothingAndFabrics;

  /// No description provided for @protectClothingAndFabricsExplanation.
  ///
  /// In en, this message translates to: **'Keep your whites white, your colors colorful, and your clothing and fabrics
  /// soft.'**
  String get protectClothingAndFabricsExplanation;

  /// No description provided for @reduceScaleBuildup.
  ///
  /// In en, this message translates to: **'Reduce scale buildup'**
  String get reduceScaleBuildup;

  /// No description provided for @reduceScaleBuildupExplanation.
  ///
  /// In en, this message translates to: **'Reduce scale buildup on fixtures and in pipes and appliances to increase
  /// their life spans and performance.'**
  String get reduceScaleBuildupExplanation;

  /// No description provided for @saltLevelLow.
  ///
  /// In en, this message translates to: **'Salt Running Low'**
  String get saltLevelLow;

  /// No description provided for @saltRemaining.
  ///
  /// In en, this message translates to: **'Salt Remaining'**
  String get saltRemaining;

  /// No description provided for @sensorExplanation.
  ///
  /// In en, this message translates to: **'Sensors detect the level of salt in your water softener and report the
  /// level.'**
  String get sensorExplanation;

  /// No description provided for @sensorCalibrationRoutines.
  ///
  /// In en, this message translates to: **'Sensor calibration routines'**
  String get sensorCalibrationRoutines;

  /// No description provided for @sensorIntegration.
  ///
  /// In en, this message translates to: **'Sensor integration'**
  String get sensorIntegration;

  /// No description provided for @setUpManufacturingFlashing.
  ///
  /// In en, this message translates to: **'Set up manufacturing flashing'**
  String get setUpManufacturingFlashing;

  /// No description provided for @smart.
  ///
  /// In en, this message translates to: **'smart'**
  String get smart;

  /// No description provided for @socialSharePrompt.
  ///
  /// In en, this message translates to: **'Want to share Brine with your friends?'**
  String get socialSharePrompt;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to: **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @testHardwarePrototypes.
  ///
  /// In en, this message translates to: **'Test hardware prototypes'**
  String get testHardwarePrototypes;

  /// No description provided for @thanksPageDescription.
  ///
  /// In en, this message translates to: **'You\'re all signed up to receive updates about Brine, which will be
  /// launching soon. You\'ll be among the first to know when Brine is available because you\'ll receive a nice discount
  /// right into your inbox.'**
  String get thanksPageDescription;

  /// No description provided for @thanksPageTitlePrefix.
  ///
  /// In en, this message translates to: **'Thanks, '**
  String get thanksPageTitlePrefix;

  /// No description provided for @validationEmailControlCharacters.
  ///
  /// In en, this message translates to: **'There are some odd characters in this email entry.'**
  String get validationEmailControlCharacters;

  /// No description provided for @validationEmailEmpty.
  ///
  /// In en, this message translates to: **'How are you supported to receive Brine news without an email?'**
  String get validationEmailEmpty;

  /// No description provided for @validationEmailHtmlCharacters.
  ///
  /// In en, this message translates to: **'This email looks a little like HTML...'**
  String get validationEmailHtmlCharacters;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to: **'This email address looks a little fishy...'**
  String get validationEmailInvalid;

  /// No description provided for @validationNameEmpty.
  ///
  /// In en, this message translates to: **'Oh \$#!%, it looks like you forgot this field.'**
  String get validationNameEmpty;

  /// No description provided for @validationNameControlCharacters.
  ///
  /// In en, this message translates to: **'This input contains some fishy characters.'**
  String get validationNameControlCharacters;

  /// No description provided for @validationNameInvalidHtml.
  ///
  /// In en, this message translates to: **'This name seems to contain some HTML. Why?'**
  String get validationNameInvalidHtml;

  /// No description provided for @wakeUpRoutines.
  ///
  /// In en, this message translates to: **'Wake-up routines'**
  String get wakeUpRoutines;

  /// No description provided for @webDevelopment.
  ///
  /// In en, this message translates to: **'Web Development'**
  String get webDevelopment;

  /// No description provided for @wireframesAndPrototypes.
  ///
  /// In en, this message translates to: **'Wireframes and prototypes'**
  String get wireframesAndPrototypes;

  /// Message displayed on the under construction page while the website is being refreshed
  ///
  /// In en, this message translates to: **'We\'re giving the site a fresh coat of paint. Check back soon!'**
  String get underConstructionMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
