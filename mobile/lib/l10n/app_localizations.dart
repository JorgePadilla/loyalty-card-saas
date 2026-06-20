import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get commonCustomer;

  /// No description provided for @commonPoints.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get commonPoints;

  /// No description provided for @commonPts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get commonPts;

  /// No description provided for @navMyCard.
  ///
  /// In en, this message translates to:
  /// **'My Card'**
  String get navMyCard;

  /// No description provided for @navRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get navRewards;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navScanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get navScanner;

  /// No description provided for @navVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get navVisits;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get loginPasswordRequired;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignInButton;

  /// No description provided for @loginNoAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccountPrefix;

  /// No description provided for @loginSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join your favourite business'**
  String get registerSubtitle;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerFailed;

  /// No description provided for @registerBusinessCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Business code'**
  String get registerBusinessCodeLabel;

  /// No description provided for @registerBusinessCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. joes-barbershop'**
  String get registerBusinessCodeHint;

  /// No description provided for @registerBusinessCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Business code is required'**
  String get registerBusinessCodeRequired;

  /// No description provided for @registerFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registerFirstNameLabel;

  /// No description provided for @registerLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registerLastNameLabel;

  /// No description provided for @registerFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get registerFieldRequired;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get registerEmailRequired;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get registerEmailInvalid;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get registerPhoneLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get registerPasswordTooShort;

  /// No description provided for @registerCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccountButton;

  /// No description provided for @registerHasAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHasAccountPrefix;

  /// No description provided for @registerSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignInLink;

  /// No description provided for @cardTitle.
  ///
  /// In en, this message translates to:
  /// **'My Card'**
  String get cardTitle;

  /// No description provided for @cardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your card.'**
  String get cardLoadError;

  /// No description provided for @cardBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Club'**
  String get cardBusinessName;

  /// No description provided for @cardMemberName.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get cardMemberName;

  /// No description provided for @cardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get cardRecentActivity;

  /// No description provided for @cardActivityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load recent activity.'**
  String get cardActivityLoadError;

  /// No description provided for @cardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet. Visit us to start earning points!'**
  String get cardNoActivity;

  /// No description provided for @cardStatTotalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get cardStatTotalPoints;

  /// No description provided for @cardStatVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get cardStatVisits;

  /// No description provided for @cardStatMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get cardStatMemberSince;

  /// No description provided for @cardTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String cardTimeMinutesAgo(Object minutes);

  /// No description provided for @cardTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String cardTimeHoursAgo(Object hours);

  /// No description provided for @cardTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String cardTimeDaysAgo(Object days);

  /// No description provided for @loyaltyCardPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get loyaltyCardPointsLabel;

  /// No description provided for @loyaltyCardMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get loyaltyCardMemberLabel;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// No description provided for @rewardsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load rewards.'**
  String get rewardsLoadError;

  /// No description provided for @rewardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rewards available yet.'**
  String get rewardsEmpty;

  /// No description provided for @rewardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load reward.'**
  String get rewardLoadError;

  /// No description provided for @rewardDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward Details'**
  String get rewardDetailTitle;

  /// No description provided for @rewardPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get rewardPointsLabel;

  /// No description provided for @rewardRequiresTier.
  ///
  /// In en, this message translates to:
  /// **'Requires {tier} tier'**
  String rewardRequiresTier(Object tier);

  /// No description provided for @rewardYourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get rewardYourBalance;

  /// No description provided for @rewardBalancePts.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String rewardBalancePts(Object points);

  /// No description provided for @rewardRedeemFor.
  ///
  /// In en, this message translates to:
  /// **'Redeem for {points} points'**
  String rewardRedeemFor(Object points);

  /// No description provided for @rewardNotEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points'**
  String get rewardNotEnoughPoints;

  /// No description provided for @rewardNotEnoughPointsCount.
  ///
  /// In en, this message translates to:
  /// **'Not enough points ({current}/{required})'**
  String rewardNotEnoughPointsCount(Object current, Object required);

  /// No description provided for @rewardTierRequiredButton.
  ///
  /// In en, this message translates to:
  /// **'{tier} Tier Required'**
  String rewardTierRequiredButton(Object tier);

  /// No description provided for @rewardNeedMorePoints.
  ///
  /// In en, this message translates to:
  /// **'You need {points} more points'**
  String rewardNeedMorePoints(Object points);

  /// No description provided for @rewardRedeemedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward Redeemed!'**
  String get rewardRedeemedTitle;

  /// No description provided for @rewardRedeemedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show this to staff to claim your reward.'**
  String get rewardRedeemedSubtitle;

  /// No description provided for @rewardTypeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get rewardTypeDiscount;

  /// No description provided for @rewardTypeFreeItem.
  ///
  /// In en, this message translates to:
  /// **'Free Item'**
  String get rewardTypeFreeItem;

  /// No description provided for @rewardTypeService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get rewardTypeService;

  /// No description provided for @rewardTypeMerchandise.
  ///
  /// In en, this message translates to:
  /// **'Merchandise'**
  String get rewardTypeMerchandise;

  /// No description provided for @rewardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem Reward'**
  String get rewardConfirmTitle;

  /// No description provided for @rewardConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Spend {points} points to redeem \"{name}\"?'**
  String rewardConfirmMessage(Object points, Object name);

  /// No description provided for @rewardRedeemSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reward redeemed successfully!'**
  String get rewardRedeemSuccess;

  /// No description provided for @rewardRedeemFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not redeem reward. Please try again.'**
  String get rewardRedeemFailure;

  /// No description provided for @scannerLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan customer QR code'**
  String get scannerLabel;

  /// No description provided for @scannerCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Check In Customer'**
  String get scannerCheckInTitle;

  /// No description provided for @scannerServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get scannerServiceLabel;

  /// No description provided for @scannerAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (\$)'**
  String get scannerAmountLabel;

  /// No description provided for @scannerCheckInButton.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get scannerCheckInButton;

  /// No description provided for @scannerCheckInSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in Successful'**
  String get scannerCheckInSuccessTitle;

  /// No description provided for @scannerPointsAwarded.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts'**
  String scannerPointsAwarded(Object points);

  /// No description provided for @scannerScanNextButton.
  ///
  /// In en, this message translates to:
  /// **'Scan Next'**
  String get scannerScanNextButton;

  /// No description provided for @scannerCheckInFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in Failed'**
  String get scannerCheckInFailedTitle;

  /// No description provided for @scannerTryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get scannerTryAgainButton;

  /// No description provided for @visitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Visits'**
  String get visitsTitle;

  /// No description provided for @visitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No visits yet'**
  String get visitsEmptyTitle;

  /// No description provided for @visitsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Check-in visits will appear here.\nScan a customer QR code to get started.'**
  String get visitsEmptyMessage;

  /// No description provided for @visitsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get visitsToday;

  /// No description provided for @visitsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get visitsYesterday;

  /// No description provided for @visitsPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts'**
  String visitsPointsEarned(Object points);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get profileMember;

  /// No description provided for @profileStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get profileStaff;

  /// No description provided for @profileRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get profileRoleOwner;

  /// No description provided for @profileRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get profileRoleManager;

  /// No description provided for @profileRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get profileRoleStaff;

  /// No description provided for @profileRoleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get profileRoleCustomer;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profilePointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Points History'**
  String get profilePointsHistory;

  /// No description provided for @profileHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load history.'**
  String get profileHistoryLoadError;

  /// No description provided for @profileNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get profileNoTransactions;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(Object date);

  /// No description provided for @profilePtsToTier.
  ///
  /// In en, this message translates to:
  /// **'{points} pts to {tier}'**
  String profilePtsToTier(Object points, Object tier);

  /// No description provided for @profileHighestTier.
  ///
  /// In en, this message translates to:
  /// **'Highest tier reached'**
  String get profileHighestTier;

  /// No description provided for @profileTodaysActivity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity'**
  String get profileTodaysActivity;

  /// No description provided for @profileVisitsToday.
  ///
  /// In en, this message translates to:
  /// **'Visits Today'**
  String get profileVisitsToday;

  /// No description provided for @profilePointsAwarded.
  ///
  /// In en, this message translates to:
  /// **'Points Awarded'**
  String get profilePointsAwarded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
