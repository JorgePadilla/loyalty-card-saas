// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Loyalty';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonCustomer => 'Customer';

  @override
  String get commonPoints => 'points';

  @override
  String get commonPts => 'pts';

  @override
  String get navMyCard => 'My Card';

  @override
  String get navRewards => 'Rewards';

  @override
  String get navProfile => 'Profile';

  @override
  String get navScanner => 'Scanner';

  @override
  String get navVisits => 'Visits';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginInvalidCredentials => 'Invalid email or password.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailRequired => 'Email is required';

  @override
  String get loginEmailInvalid => 'Enter a valid email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Password is required';

  @override
  String get loginSignInButton => 'Sign in';

  @override
  String get loginNoAccountPrefix => 'Don\'t have an account? ';

  @override
  String get loginSignUpLink => 'Sign up';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join your favourite business';

  @override
  String get registerFailed => 'Registration failed. Please try again.';

  @override
  String get registerBusinessCodeLabel => 'Business code';

  @override
  String get registerBusinessCodeHint => 'e.g. joes-barbershop';

  @override
  String get registerBusinessCodeRequired => 'Business code is required';

  @override
  String get registerFirstNameLabel => 'First name';

  @override
  String get registerLastNameLabel => 'Last name';

  @override
  String get registerFieldRequired => 'Required';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailRequired => 'Email is required';

  @override
  String get registerEmailInvalid => 'Enter a valid email';

  @override
  String get registerPhoneLabel => 'Phone (optional)';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordRequired => 'Password is required';

  @override
  String get registerPasswordTooShort => 'At least 6 characters';

  @override
  String get registerCreateAccountButton => 'Create account';

  @override
  String get registerHasAccountPrefix => 'Already have an account? ';

  @override
  String get registerSignInLink => 'Sign in';

  @override
  String get cardTitle => 'My Card';

  @override
  String get cardLoadError => 'Could not load your card.';

  @override
  String get cardBusinessName => 'Loyalty Club';

  @override
  String get cardMemberName => 'Member';

  @override
  String get cardRecentActivity => 'Recent Activity';

  @override
  String get cardActivityLoadError => 'Could not load recent activity.';

  @override
  String get cardNoActivity =>
      'No activity yet. Visit us to start earning points!';

  @override
  String get cardStatTotalPoints => 'Total Points';

  @override
  String get cardStatVisits => 'Visits';

  @override
  String get cardStatMemberSince => 'Member Since';

  @override
  String cardTimeMinutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String cardTimeHoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String cardTimeDaysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get loyaltyCardPointsLabel => 'POINTS';

  @override
  String get loyaltyCardMemberLabel => 'MEMBER';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsLoadError => 'Could not load rewards.';

  @override
  String get rewardsEmpty => 'No rewards available yet.';

  @override
  String get rewardLoadError => 'Could not load reward.';

  @override
  String get rewardDetailTitle => 'Reward Details';

  @override
  String get rewardPointsLabel => 'points';

  @override
  String rewardRequiresTier(Object tier) {
    return 'Requires $tier tier';
  }

  @override
  String get rewardYourBalance => 'Your balance';

  @override
  String rewardBalancePts(Object points) {
    return '$points pts';
  }

  @override
  String rewardRedeemFor(Object points) {
    return 'Redeem for $points points';
  }

  @override
  String get rewardNotEnoughPoints => 'Not enough points';

  @override
  String rewardNotEnoughPointsCount(Object current, Object required) {
    return 'Not enough points ($current/$required)';
  }

  @override
  String rewardTierRequiredButton(Object tier) {
    return '$tier Tier Required';
  }

  @override
  String rewardNeedMorePoints(Object points) {
    return 'You need $points more points';
  }

  @override
  String get rewardRedeemedTitle => 'Reward Redeemed!';

  @override
  String get rewardRedeemedSubtitle =>
      'Show this to staff to claim your reward.';

  @override
  String get rewardTypeDiscount => 'Discount';

  @override
  String get rewardTypeFreeItem => 'Free Item';

  @override
  String get rewardTypeService => 'Service';

  @override
  String get rewardTypeMerchandise => 'Merchandise';

  @override
  String get rewardConfirmTitle => 'Redeem Reward';

  @override
  String rewardConfirmMessage(Object points, Object name) {
    return 'Spend $points points to redeem \"$name\"?';
  }

  @override
  String get rewardRedeemSuccess => 'Reward redeemed successfully!';

  @override
  String get rewardRedeemFailure =>
      'Could not redeem reward. Please try again.';

  @override
  String get scannerLabel => 'Scan customer QR code';

  @override
  String get scannerCheckInTitle => 'Check In Customer';

  @override
  String get scannerServiceLabel => 'Service';

  @override
  String get scannerAmountLabel => 'Amount (\$)';

  @override
  String get scannerCheckInButton => 'Check In';

  @override
  String get scannerCheckInSuccessTitle => 'Check-in Successful';

  @override
  String scannerPointsAwarded(Object points) {
    return '+$points pts';
  }

  @override
  String get scannerScanNextButton => 'Scan Next';

  @override
  String get scannerCheckInFailedTitle => 'Check-in Failed';

  @override
  String get scannerTryAgainButton => 'Try Again';

  @override
  String get visitsTitle => 'Recent Visits';

  @override
  String get visitsEmptyTitle => 'No visits yet';

  @override
  String get visitsEmptyMessage =>
      'Check-in visits will appear here.\nScan a customer QR code to get started.';

  @override
  String get visitsToday => 'Today';

  @override
  String get visitsYesterday => 'Yesterday';

  @override
  String visitsPointsEarned(Object points) {
    return '+$points pts';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileMember => 'Member';

  @override
  String get profileStaff => 'Staff';

  @override
  String get profileRoleOwner => 'Owner';

  @override
  String get profileRoleManager => 'Manager';

  @override
  String get profileRoleStaff => 'Staff';

  @override
  String get profileRoleCustomer => 'Customer';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileAbout => 'About';

  @override
  String get profilePointsHistory => 'Points History';

  @override
  String get profileHistoryLoadError => 'Could not load history.';

  @override
  String get profileNoTransactions => 'No transactions yet';

  @override
  String profileMemberSince(Object date) {
    return 'Member since $date';
  }

  @override
  String profilePtsToTier(Object points, Object tier) {
    return '$points pts to $tier';
  }

  @override
  String get profileHighestTier => 'Highest tier reached';

  @override
  String get profileTodaysActivity => 'Today\'s Activity';

  @override
  String get profileVisitsToday => 'Visits Today';

  @override
  String get profilePointsAwarded => 'Points Awarded';
}
