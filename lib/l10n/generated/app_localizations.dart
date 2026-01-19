import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// The app name
  ///
  /// In en, this message translates to:
  /// **'GeoMaster'**
  String get appName;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GeoMaster'**
  String get appTitle;

  /// The app tagline
  ///
  /// In en, this message translates to:
  /// **'Explore the World'**
  String get appTagline;

  /// Welcome message with user's name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeMessage(String name);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to continue.'**
  String get welcomeBack;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get signingOut;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy'**
  String get termsAgreement;

  /// No description provided for @termsCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get termsCheckbox;

  /// No description provided for @termsOfServiceLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceLink;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andText;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms of Service and Privacy Policy to continue'**
  String get pleaseAcceptTerms;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guestModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Try the app without signing in'**
  String get guestModeDescription;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Journey'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Learn geography the fun way!'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Interactive Learning'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Answer questions, earn rewards'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Powered by AI'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Your personal geography tutor'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Watch yourself become a geography master'**
  String get onboardingSubtitle4;

  /// No description provided for @onboardingExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the World'**
  String get onboardingExploreTitle;

  /// No description provided for @onboardingExploreDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover fascinating facts about every country on Earth'**
  String get onboardingExploreDescription;

  /// No description provided for @onboardingQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Your Knowledge'**
  String get onboardingQuizTitle;

  /// No description provided for @onboardingQuizDescription.
  ///
  /// In en, this message translates to:
  /// **'Challenge yourself with fun quizzes on capitals, flags, and more'**
  String get onboardingQuizDescription;

  /// No description provided for @onboardingAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Learning'**
  String get onboardingAiTitle;

  /// No description provided for @onboardingAiDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized help from your AI geography tutor'**
  String get onboardingAiDescription;

  /// No description provided for @onboardingAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn Achievements'**
  String get onboardingAchievementsTitle;

  /// No description provided for @onboardingAchievementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock badges, climb leaderboards, and track your progress'**
  String get onboardingAchievementsDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @whatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get whatsYourName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @geographyLevel.
  ///
  /// In en, this message translates to:
  /// **'What\'s your current geography level?'**
  String get geographyLevel;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelBeginnerDescription.
  ///
  /// In en, this message translates to:
  /// **'0-20% world knowledge'**
  String get levelBeginnerDescription;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelIntermediateDescription.
  ///
  /// In en, this message translates to:
  /// **'20-60% world knowledge'**
  String get levelIntermediateDescription;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @levelAdvancedDescription.
  ///
  /// In en, this message translates to:
  /// **'60%+ world knowledge'**
  String get levelAdvancedDescription;

  /// No description provided for @whatInterestsYou.
  ///
  /// In en, this message translates to:
  /// **'What interests you most?'**
  String get whatInterestsYou;

  /// No description provided for @interestHistory.
  ///
  /// In en, this message translates to:
  /// **'History & Culture'**
  String get interestHistory;

  /// No description provided for @interestLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get interestLanguages;

  /// No description provided for @interestTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & Tourism'**
  String get interestTravel;

  /// No description provided for @interestPolitics.
  ///
  /// In en, this message translates to:
  /// **'Politics & Economics'**
  String get interestPolitics;

  /// No description provided for @interestNature.
  ///
  /// In en, this message translates to:
  /// **'Nature & Climate'**
  String get interestNature;

  /// No description provided for @setLearningGoal.
  ///
  /// In en, this message translates to:
  /// **'Set your learning goal'**
  String get setLearningGoal;

  /// No description provided for @minutes5PerDay.
  ///
  /// In en, this message translates to:
  /// **'5 minutes/day'**
  String get minutes5PerDay;

  /// No description provided for @minutes15PerDay.
  ///
  /// In en, this message translates to:
  /// **'15 minutes/day'**
  String get minutes15PerDay;

  /// No description provided for @minutes30PerDay.
  ///
  /// In en, this message translates to:
  /// **'30 minutes/day'**
  String get minutes30PerDay;

  /// No description provided for @customGoal.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customGoal;

  /// No description provided for @personalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Personalize Your Experience'**
  String get personalizeExperience;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one topic'**
  String get selectAtLeastOne;

  /// No description provided for @interestCapitals.
  ///
  /// In en, this message translates to:
  /// **'Capitals'**
  String get interestCapitals;

  /// No description provided for @interestFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get interestFlags;

  /// No description provided for @interestGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get interestGeography;

  /// No description provided for @interestCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get interestCulture;

  /// No description provided for @chooseDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Difficulty'**
  String get chooseDifficulty;

  /// No description provided for @canChangeAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in settings'**
  String get canChangeAnytime;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyEasyDescription.
  ///
  /// In en, this message translates to:
  /// **'Perfect for beginners'**
  String get difficultyEasyDescription;

  /// No description provided for @difficultyMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'For intermediate learners'**
  String get difficultyMediumDescription;

  /// No description provided for @difficultyHardDescription.
  ///
  /// In en, this message translates to:
  /// **'For geography experts'**
  String get difficultyHardDescription;

  /// No description provided for @setYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Your Learning Goal'**
  String get setYourGoal;

  /// No description provided for @howMuchTimePerDay.
  ///
  /// In en, this message translates to:
  /// **'How much time do you want to spend learning each day?'**
  String get howMuchTimePerDay;

  /// No description provided for @goalCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get goalCasual;

  /// No description provided for @goalCasualDescription.
  ///
  /// In en, this message translates to:
  /// **'5 mins/day'**
  String get goalCasualDescription;

  /// No description provided for @goalRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get goalRegular;

  /// No description provided for @goalRegularDescription.
  ///
  /// In en, this message translates to:
  /// **'15 mins/day'**
  String get goalRegularDescription;

  /// No description provided for @goalSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get goalSerious;

  /// No description provided for @goalSeriousDescription.
  ///
  /// In en, this message translates to:
  /// **'30 mins/day'**
  String get goalSeriousDescription;

  /// No description provided for @goalIntense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get goalIntense;

  /// No description provided for @goalIntenseDescription.
  ///
  /// In en, this message translates to:
  /// **'60 mins/day'**
  String get goalIntenseDescription;

  /// No description provided for @letsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go!'**
  String get letsGo;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications?'**
  String get enableNotifications;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @achievementUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocks'**
  String get achievementUnlocks;

  /// No description provided for @friendChallenges.
  ///
  /// In en, this message translates to:
  /// **'Friend challenges'**
  String get friendChallenges;

  /// No description provided for @letsStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start!'**
  String get letsStart;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @dailyChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s challenge to earn bonus XP!'**
  String get dailyChallengeDescription;

  /// No description provided for @startChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start Challenge'**
  String get startChallenge;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get quickQuiz;

  /// No description provided for @countryOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Country of the Day'**
  String get countryOfTheDay;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @recentProgress.
  ///
  /// In en, this message translates to:
  /// **'Recent Progress'**
  String get recentProgress;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak!'**
  String dayStreak(int count);

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up! You\'re on fire!'**
  String get keepItUp;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left: {time}'**
  String timeLeft(String time);

  /// No description provided for @claimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim Reward'**
  String get claimReward;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @xpAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} XP'**
  String xpAmount(int amount);

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelNumber(int number);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Complete'**
  String progressPercent(int percent);

  /// No description provided for @exploreWorld.
  ///
  /// In en, this message translates to:
  /// **'Explore World'**
  String get exploreWorld;

  /// No description provided for @worldMap.
  ///
  /// In en, this message translates to:
  /// **'World Map'**
  String get worldMap;

  /// No description provided for @continents.
  ///
  /// In en, this message translates to:
  /// **'Continents'**
  String get continents;

  /// No description provided for @countries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countries;

  /// No description provided for @africa.
  ///
  /// In en, this message translates to:
  /// **'Africa'**
  String get africa;

  /// No description provided for @asia.
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get asia;

  /// No description provided for @europe.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get europe;

  /// No description provided for @northAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America'**
  String get northAmerica;

  /// No description provided for @southAmerica.
  ///
  /// In en, this message translates to:
  /// **'South America'**
  String get southAmerica;

  /// No description provided for @oceania.
  ///
  /// In en, this message translates to:
  /// **'Oceania'**
  String get oceania;

  /// No description provided for @antarctica.
  ///
  /// In en, this message translates to:
  /// **'Antarctica'**
  String get antarctica;

  /// No description provided for @tapToExplore.
  ///
  /// In en, this message translates to:
  /// **'Tap to explore'**
  String get tapToExplore;

  /// No description provided for @capital.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get capital;

  /// No description provided for @population.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get population;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @subregion.
  ///
  /// In en, this message translates to:
  /// **'Subregion'**
  String get subregion;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @currencies.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currencies;

  /// No description provided for @timezones.
  ///
  /// In en, this message translates to:
  /// **'Timezones'**
  String get timezones;

  /// No description provided for @borders.
  ///
  /// In en, this message translates to:
  /// **'Borders'**
  String get borders;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flag;

  /// No description provided for @coatOfArms.
  ///
  /// In en, this message translates to:
  /// **'Coat of Arms'**
  String get coatOfArms;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @officialName.
  ///
  /// In en, this message translates to:
  /// **'Official Name'**
  String get officialName;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country Code'**
  String get countryCode;

  /// No description provided for @unMember.
  ///
  /// In en, this message translates to:
  /// **'UN Member'**
  String get unMember;

  /// No description provided for @landlocked.
  ///
  /// In en, this message translates to:
  /// **'Landlocked'**
  String get landlocked;

  /// No description provided for @drivingSide.
  ///
  /// In en, this message translates to:
  /// **'Driving Side'**
  String get drivingSide;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// No description provided for @countryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Country not found'**
  String get countryNotFound;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current Weather'**
  String get currentWeather;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather data unavailable'**
  String get weatherUnavailable;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clouds.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get clouds;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get rain;

  /// No description provided for @drizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get drizzle;

  /// No description provided for @thunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get thunderstorm;

  /// No description provided for @snow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get snow;

  /// No description provided for @mist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get mist;

  /// No description provided for @haze.
  ///
  /// In en, this message translates to:
  /// **'Haze'**
  String get haze;

  /// No description provided for @searchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search countries...'**
  String get searchCountries;

  /// No description provided for @noCountriesFound.
  ///
  /// In en, this message translates to:
  /// **'No countries found'**
  String get noCountriesFound;

  /// No description provided for @filterByRegion.
  ///
  /// In en, this message translates to:
  /// **'Filter by region'**
  String get filterByRegion;

  /// No description provided for @allRegions.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get allRegions;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapView;

  /// No description provided for @learningModes.
  ///
  /// In en, this message translates to:
  /// **'Learning Modes'**
  String get learningModes;

  /// No description provided for @quickQuizDescription.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get quickQuizDescription;

  /// No description provided for @aiTutor.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor'**
  String get aiTutor;

  /// No description provided for @aiTutorDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat with your tutor'**
  String get aiTutorDescription;

  /// No description provided for @challengeMode.
  ///
  /// In en, this message translates to:
  /// **'Challenge Mode'**
  String get challengeMode;

  /// No description provided for @challengeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Test your skills'**
  String get challengeModeDescription;

  /// No description provided for @storyTime.
  ///
  /// In en, this message translates to:
  /// **'Story Time'**
  String get storyTime;

  /// No description provided for @storyTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn through stories'**
  String get storyTimeDescription;

  /// No description provided for @audioLearning.
  ///
  /// In en, this message translates to:
  /// **'Audio Learning'**
  String get audioLearning;

  /// No description provided for @audioLearningDescription.
  ///
  /// In en, this message translates to:
  /// **'Listen and learn'**
  String get audioLearningDescription;

  /// No description provided for @quizModes.
  ///
  /// In en, this message translates to:
  /// **'Quiz Modes'**
  String get quizModes;

  /// No description provided for @capitalsQuiz.
  ///
  /// In en, this message translates to:
  /// **'Capitals'**
  String get capitalsQuiz;

  /// No description provided for @flagsQuiz.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get flagsQuiz;

  /// No description provided for @mapsQuiz.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get mapsQuiz;

  /// No description provided for @populationQuiz.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get populationQuiz;

  /// No description provided for @currenciesQuiz.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get currenciesQuiz;

  /// No description provided for @languagesQuiz.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesQuiz;

  /// No description provided for @mixedQuiz.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedQuiz;

  /// No description provided for @selectQuizMode.
  ///
  /// In en, this message translates to:
  /// **'Select Quiz Mode'**
  String get selectQuizMode;

  /// No description provided for @quizModeCapitals.
  ///
  /// In en, this message translates to:
  /// **'Capitals Quiz'**
  String get quizModeCapitals;

  /// No description provided for @quizModeCapitalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Name the capitals of countries'**
  String get quizModeCapitalsDescription;

  /// No description provided for @quizModeFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags Quiz'**
  String get quizModeFlags;

  /// No description provided for @quizModeFlagsDescription.
  ///
  /// In en, this message translates to:
  /// **'Identify flags from around the world'**
  String get quizModeFlagsDescription;

  /// No description provided for @quizModeMap.
  ///
  /// In en, this message translates to:
  /// **'Map Quiz'**
  String get quizModeMap;

  /// No description provided for @quizModeMapDescription.
  ///
  /// In en, this message translates to:
  /// **'Find countries on the map'**
  String get quizModeMapDescription;

  /// No description provided for @quizModePopulation.
  ///
  /// In en, this message translates to:
  /// **'Population Quiz'**
  String get quizModePopulation;

  /// No description provided for @quizModePopulationDescription.
  ///
  /// In en, this message translates to:
  /// **'Compare country populations'**
  String get quizModePopulationDescription;

  /// No description provided for @quizModeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency Quiz'**
  String get quizModeCurrency;

  /// No description provided for @quizModeCurrencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Match currencies to countries'**
  String get quizModeCurrencyDescription;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionNumber(int current, int total);

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @theAnswerWas.
  ///
  /// In en, this message translates to:
  /// **'The answer was: {answer}'**
  String theAnswerWas(String answer);

  /// No description provided for @quizComplete.
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @scoreResult.
  ///
  /// In en, this message translates to:
  /// **'{correct} out of {total}'**
  String scoreResult(int correct, int total);

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctAnswers;

  /// No description provided for @timeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time Taken'**
  String get timeTaken;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'XP Earned'**
  String get xpEarned;

  /// No description provided for @perfectScore.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score!'**
  String get perfectScore;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @askAiTutor.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Tutor'**
  String get askAiTutor;

  /// No description provided for @typeYourQuestion.
  ///
  /// In en, this message translates to:
  /// **'Type your question...'**
  String get typeYourQuestion;

  /// No description provided for @suggestedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Questions'**
  String get suggestedQuestions;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get aiThinking;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @viewAllAchievements.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllAchievements;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get yourRank;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @weeklyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly Stats'**
  String get weeklyStats;

  /// No description provided for @countriesLearned.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countriesLearned;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions Answered'**
  String get questionsAnswered;

  /// No description provided for @accuracyRate.
  ///
  /// In en, this message translates to:
  /// **'Accuracy Rate'**
  String get accuracyRate;

  /// No description provided for @quizzesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesCompleted;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// No description provided for @geographyExplorer.
  ///
  /// In en, this message translates to:
  /// **'Geography Explorer'**
  String get geographyExplorer;

  /// No description provided for @toNextLevel.
  ///
  /// In en, this message translates to:
  /// **'to next level'**
  String get toNextLevel;

  /// No description provided for @progressByRegion.
  ///
  /// In en, this message translates to:
  /// **'Progress by Region'**
  String get progressByRegion;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @learningPreferences.
  ///
  /// In en, this message translates to:
  /// **'Learning Preferences'**
  String get learningPreferences;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @minutesPerDay.
  ///
  /// In en, this message translates to:
  /// **'minutes/day'**
  String get minutesPerDay;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and remove ads'**
  String get unlockAllFeatures;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @unlimitedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Quizzes'**
  String get unlimitedQuizzes;

  /// No description provided for @unlimitedAiChat.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Chat'**
  String get unlimitedAiChat;

  /// No description provided for @offlineAccess.
  ///
  /// In en, this message translates to:
  /// **'Offline Access'**
  String get offlineAccess;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAds;

  /// No description provided for @streakFreeze.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze'**
  String get streakFreeze;

  /// No description provided for @exclusiveAchievements.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Achievements'**
  String get exclusiveAchievements;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @subscriptionManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get subscriptionManagement;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get freeTrial;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNoInternet;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnknown;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please sign in again.'**
  String get errorAuthFailed;

  /// No description provided for @whatCapitalOf.
  ///
  /// In en, this message translates to:
  /// **'What is the capital of {country}?'**
  String whatCapitalOf(String country);

  /// No description provided for @whichFlagBelongsTo.
  ///
  /// In en, this message translates to:
  /// **'Which flag belongs to {country}?'**
  String whichFlagBelongsTo(String country);

  /// No description provided for @whereIsCountryLocated.
  ///
  /// In en, this message translates to:
  /// **'Where is {country} located?'**
  String whereIsCountryLocated(String country);

  /// No description provided for @whichCountryHasLargerPopulation.
  ///
  /// In en, this message translates to:
  /// **'Which country has a larger population?'**
  String get whichCountryHasLargerPopulation;

  /// No description provided for @whichCurrencyUsedIn.
  ///
  /// In en, this message translates to:
  /// **'Which currency is used in {country}?'**
  String whichCurrencyUsedIn(String country);

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @enterDetailsToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started'**
  String get enterDetailsToGetStarted;

  /// No description provided for @enterCredentialsToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to sign in'**
  String get enterCredentialsToSignIn;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get resetEmailSent;

  /// No description provided for @failedToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email. Please try again.'**
  String get failedToSendResetEmail;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Shown on splash screen while loading
  ///
  /// In en, this message translates to:
  /// **'Loading your journey...'**
  String get loadingJourney;

  /// Title for the interactive map feature
  ///
  /// In en, this message translates to:
  /// **'Interactive Map'**
  String get interactiveMap;

  /// Placeholder text for map feature
  ///
  /// In en, this message translates to:
  /// **'Google Maps integration coming soon'**
  String get mapComingSoon;

  /// Badge text for premium features
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// All option in filters
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Americas continent name
  ///
  /// In en, this message translates to:
  /// **'Americas'**
  String get americas;

  /// Continue button text with language
  ///
  /// In en, this message translates to:
  /// **'Continue in {language}'**
  String continueInLanguage(String language);

  /// Subtitle on language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseYourLanguage;

  /// Label for quizzes count
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesLabel;

  /// Label for countries count
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countriesLabel;

  /// Label for XP points
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xpLabel;

  /// Default name for user
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorer;

  /// Motivational text on home screen
  ///
  /// In en, this message translates to:
  /// **'Ready to explore the world?'**
  String get readyToExplore;

  /// Title for streak section
  ///
  /// In en, this message translates to:
  /// **'Expedition Streak'**
  String get expeditionStreak;

  /// Message when streak is 0
  ///
  /// In en, this message translates to:
  /// **'Start your expedition today!'**
  String get startStreak;

  /// Days label for streak
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Title for world progress section
  ///
  /// In en, this message translates to:
  /// **'World Progress'**
  String get worldProgress;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sun;

  /// Title for quiz screen
  ///
  /// In en, this message translates to:
  /// **'Challenge Arena'**
  String get challengeArena;

  /// Subtitle for quiz mode selection
  ///
  /// In en, this message translates to:
  /// **'Select Your Challenge'**
  String get selectChallenge;

  /// Title for stats section
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get yourStats;

  /// Title for difficulty section
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// Title for explore screen
  ///
  /// In en, this message translates to:
  /// **'World Atlas'**
  String get worldAtlas;

  /// Subtitle for explore screen
  ///
  /// In en, this message translates to:
  /// **'Discover Countries'**
  String get discoverCountries;

  /// Title for stats screen
  ///
  /// In en, this message translates to:
  /// **'Explorer\'s Journal'**
  String get explorerJournal;

  /// Subtitle for stats screen
  ///
  /// In en, this message translates to:
  /// **'Journey Progress'**
  String get journeyProgress;

  /// Title for profile screen
  ///
  /// In en, this message translates to:
  /// **'My Passport'**
  String get passportTitle;

  /// Section title in profile
  ///
  /// In en, this message translates to:
  /// **'Traveler Info'**
  String get travelerInfo;

  /// Label for total countries stat
  ///
  /// In en, this message translates to:
  /// **'Total Countries'**
  String get totalCountries;

  /// Label for average accuracy
  ///
  /// In en, this message translates to:
  /// **'Avg. Accuracy'**
  String get avgAccuracy;

  /// Label for best streak
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// Section title for achievements
  ///
  /// In en, this message translates to:
  /// **'Recent Achievements'**
  String get recentAchievements;

  /// Regions tab/section
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get regions;

  /// Section title for discovered countries
  ///
  /// In en, this message translates to:
  /// **'Discovered Countries'**
  String get discoveredCountries;

  /// Description for easy difficulty
  ///
  /// In en, this message translates to:
  /// **'Relaxed exploration'**
  String get easyDescription;

  /// Description for medium difficulty
  ///
  /// In en, this message translates to:
  /// **'Balanced challenge'**
  String get mediumDescription;

  /// Description for hard difficulty
  ///
  /// In en, this message translates to:
  /// **'Expert expedition'**
  String get hardDescription;

  /// Subtitle for passport header
  ///
  /// In en, this message translates to:
  /// **'World Explorer ID'**
  String get travelerIdSubtitle;

  /// Label for traveler name in passport
  ///
  /// In en, this message translates to:
  /// **'Traveler Name'**
  String get travelerName;

  /// Label for contact email in passport
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactEmail;

  /// Label for countries visited count
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countriesVisited;

  /// Title for journey stats card
  ///
  /// In en, this message translates to:
  /// **'Journey Stats'**
  String get journeyStats;

  /// Label for day streak count
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreakLabel;

  /// Greeting with user's first name
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// Motivational message for progress
  ///
  /// In en, this message translates to:
  /// **'Great progress, {name}! Keep going!'**
  String motivationalProgress(String name);

  /// Motivational message for streak
  ///
  /// In en, this message translates to:
  /// **'Amazing streak, {name}! You\'re on fire!'**
  String motivationalStreak(String name);

  /// Motivational message for learning
  ///
  /// In en, this message translates to:
  /// **'Keep exploring, {name}! The world awaits!'**
  String motivationalLearning(String name);

  /// Motivational message after quiz
  ///
  /// In en, this message translates to:
  /// **'You\'re getting smarter, {name}!'**
  String motivationalQuiz(String name);

  /// Motivational welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}! Ready to explore?'**
  String motivationalWelcome(String name);

  /// Motivational message for achievements
  ///
  /// In en, this message translates to:
  /// **'Well done, {name}! You\'re a star!'**
  String motivationalAchievement(String name);

  /// No description provided for @worldMapTitle.
  ///
  /// In en, this message translates to:
  /// **'World Map'**
  String get worldMapTitle;

  /// No description provided for @exploreTheWorld.
  ///
  /// In en, this message translates to:
  /// **'Explore the World'**
  String get exploreTheWorld;

  /// No description provided for @searchCountriesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search countries...'**
  String get searchCountriesPlaceholder;

  /// No description provided for @randomCountry.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get randomCountry;

  /// No description provided for @findingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get findingLocation;

  /// No description provided for @view3D.
  ///
  /// In en, this message translates to:
  /// **'3D View Feature'**
  String get view3D;

  /// No description provided for @mapLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get mapLegend;

  /// No description provided for @legendMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get legendMastered;

  /// No description provided for @legendAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get legendAdvanced;

  /// No description provided for @legendIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get legendIntermediate;

  /// No description provided for @legendBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get legendBeginner;

  /// No description provided for @legendStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get legendStarted;

  /// No description provided for @legendNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get legendNotStarted;

  /// No description provided for @mapFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get mapFilterAll;

  /// No description provided for @mapFilterComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get mapFilterComplete;

  /// No description provided for @mapFilterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get mapFilterInProgress;

  /// No description provided for @mapFilterNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get mapFilterNotStarted;

  /// No description provided for @mapFilterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get mapFilterFavorites;

  /// No description provided for @mapStatsCountries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get mapStatsCountries;

  /// No description provided for @mapStatsExplored.
  ///
  /// In en, this message translates to:
  /// **'Explored'**
  String get mapStatsExplored;

  /// No description provided for @mapStatsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get mapStatsFavorites;

  /// No description provided for @continentExplorer.
  ///
  /// In en, this message translates to:
  /// **'Continent Explorer'**
  String get continentExplorer;

  /// No description provided for @continentProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get continentProgress;

  /// No description provided for @continentCountries.
  ///
  /// In en, this message translates to:
  /// **'{count} Countries'**
  String continentCountries(int count);

  /// No description provided for @continueExploring.
  ///
  /// In en, this message translates to:
  /// **'Continue Exploring'**
  String get continueExploring;

  /// No description provided for @startExploring.
  ///
  /// In en, this message translates to:
  /// **'Start Exploring'**
  String get startExploring;

  /// No description provided for @tabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tabOverview;

  /// No description provided for @tabGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get tabGeography;

  /// No description provided for @tabCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get tabCulture;

  /// No description provided for @tabTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get tabTravel;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @liveInfo.
  ///
  /// In en, this message translates to:
  /// **'Live Info'**
  String get liveInfo;

  /// No description provided for @currentTime.
  ///
  /// In en, this message translates to:
  /// **'Current Time'**
  String get currentTime;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @timeDifference.
  ///
  /// In en, this message translates to:
  /// **'Time Difference'**
  String get timeDifference;

  /// No description provided for @quickFacts.
  ///
  /// In en, this message translates to:
  /// **'Quick Facts'**
  String get quickFacts;

  /// No description provided for @flagMeaning.
  ///
  /// In en, this message translates to:
  /// **'Flag Meaning'**
  String get flagMeaning;

  /// No description provided for @flagHistory.
  ///
  /// In en, this message translates to:
  /// **'Flag History'**
  String get flagHistory;

  /// No description provided for @neighboringCountries.
  ///
  /// In en, this message translates to:
  /// **'Neighboring Countries'**
  String get neighboringCountries;

  /// No description provided for @noNeighbors.
  ///
  /// In en, this message translates to:
  /// **'Island nation - no land borders'**
  String get noNeighbors;

  /// No description provided for @terrain.
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get terrain;

  /// No description provided for @terrainBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Terrain Breakdown'**
  String get terrainBreakdown;

  /// No description provided for @climate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get climate;

  /// No description provided for @climateZones.
  ///
  /// In en, this message translates to:
  /// **'Climate Zones'**
  String get climateZones;

  /// No description provided for @naturalHazards.
  ///
  /// In en, this message translates to:
  /// **'Natural Hazards'**
  String get naturalHazards;

  /// No description provided for @noHazards.
  ///
  /// In en, this message translates to:
  /// **'No major natural hazards'**
  String get noHazards;

  /// No description provided for @administrativeRegions.
  ///
  /// In en, this message translates to:
  /// **'Administrative Regions'**
  String get administrativeRegions;

  /// No description provided for @traditionalFoods.
  ///
  /// In en, this message translates to:
  /// **'Traditional Foods'**
  String get traditionalFoods;

  /// No description provided for @traditionalArts.
  ///
  /// In en, this message translates to:
  /// **'Traditional Arts'**
  String get traditionalArts;

  /// No description provided for @festivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals & Celebrations'**
  String get festivals;

  /// No description provided for @unescoSites.
  ///
  /// In en, this message translates to:
  /// **'UNESCO World Heritage Sites'**
  String get unescoSites;

  /// No description provided for @famousPeople.
  ///
  /// In en, this message translates to:
  /// **'Famous People'**
  String get famousPeople;

  /// No description provided for @funFacts.
  ///
  /// In en, this message translates to:
  /// **'Fun Facts'**
  String get funFacts;

  /// No description provided for @topPlacesToVisit.
  ///
  /// In en, this message translates to:
  /// **'Top Places to Visit'**
  String get topPlacesToVisit;

  /// No description provided for @travelEssentials.
  ///
  /// In en, this message translates to:
  /// **'Travel Essentials'**
  String get travelEssentials;

  /// No description provided for @visa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @visaRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get visaRequired;

  /// No description provided for @visaNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Not Required'**
  String get visaNotRequired;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// No description provided for @plugType.
  ///
  /// In en, this message translates to:
  /// **'Plug Type'**
  String get plugType;

  /// No description provided for @essentialPhrases.
  ///
  /// In en, this message translates to:
  /// **'Essential Phrases'**
  String get essentialPhrases;

  /// No description provided for @travelTips.
  ///
  /// In en, this message translates to:
  /// **'Travel Tips'**
  String get travelTips;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @countryQuiz.
  ///
  /// In en, this message translates to:
  /// **'Country Quiz'**
  String get countryQuiz;

  /// No description provided for @testYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get testYourKnowledge;

  /// No description provided for @learningModules.
  ///
  /// In en, this message translates to:
  /// **'Learning Modules'**
  String get learningModules;

  /// No description provided for @aiTutorChat.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor Chat'**
  String get aiTutorChat;

  /// No description provided for @chatAboutCountry.
  ///
  /// In en, this message translates to:
  /// **'Chat about this country'**
  String get chatAboutCountry;

  /// No description provided for @historicalTimeline.
  ///
  /// In en, this message translates to:
  /// **'Historical Timeline'**
  String get historicalTimeline;

  /// No description provided for @compareWithOther.
  ///
  /// In en, this message translates to:
  /// **'Compare with Another Country'**
  String get compareWithOther;

  /// No description provided for @bookmarkedFacts.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Facts'**
  String get bookmarkedFacts;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarked facts yet'**
  String get noBookmarks;

  /// No description provided for @mediaGallery.
  ///
  /// In en, this message translates to:
  /// **'Media Gallery'**
  String get mediaGallery;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @placeTypeLandmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get placeTypeLandmark;

  /// No description provided for @placeTypeNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get placeTypeNature;

  /// No description provided for @placeTypeMuseum.
  ///
  /// In en, this message translates to:
  /// **'Museum'**
  String get placeTypeMuseum;

  /// No description provided for @placeTypeHistoric.
  ///
  /// In en, this message translates to:
  /// **'Historic'**
  String get placeTypeHistoric;

  /// No description provided for @placeTypeReligious.
  ///
  /// In en, this message translates to:
  /// **'Religious'**
  String get placeTypeReligious;

  /// No description provided for @placeTypePark.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get placeTypePark;

  /// No description provided for @placeTypeBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get placeTypeBeach;

  /// No description provided for @placeTypeMountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get placeTypeMountain;

  /// No description provided for @placeTypeLake.
  ///
  /// In en, this message translates to:
  /// **'Lake'**
  String get placeTypeLake;

  /// No description provided for @placeTypeWaterfall.
  ///
  /// In en, this message translates to:
  /// **'Waterfall'**
  String get placeTypeWaterfall;

  /// No description provided for @placeTypeCastle.
  ///
  /// In en, this message translates to:
  /// **'Castle'**
  String get placeTypeCastle;

  /// No description provided for @placeTypePalace.
  ///
  /// In en, this message translates to:
  /// **'Palace'**
  String get placeTypePalace;

  /// No description provided for @placeTypeTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get placeTypeTemple;

  /// No description provided for @placeTypeMonument.
  ///
  /// In en, this message translates to:
  /// **'Monument'**
  String get placeTypeMonument;

  /// No description provided for @placeTypeBridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get placeTypeBridge;

  /// No description provided for @placeTypeTower.
  ///
  /// In en, this message translates to:
  /// **'Tower'**
  String get placeTypeTower;

  /// No description provided for @placeTypeMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get placeTypeMarket;

  /// No description provided for @placeTypeNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get placeTypeNeighborhood;

  /// No description provided for @placeTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get placeTypeOther;

  /// No description provided for @progressNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get progressNotStarted;

  /// No description provided for @progressStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get progressStarted;

  /// No description provided for @progressBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get progressBeginner;

  /// No description provided for @progressIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get progressIntermediate;

  /// No description provided for @progressAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get progressAdvanced;

  /// No description provided for @progressMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get progressMastered;

  /// No description provided for @exploreCountry.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreCountry;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @shareCountry.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareCountry;

  /// No description provided for @percentExplored.
  ///
  /// In en, this message translates to:
  /// **'{percent}% explored'**
  String percentExplored(int percent);

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @searchForCountry.
  ///
  /// In en, this message translates to:
  /// **'Search for any country in the world'**
  String get searchForCountry;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
