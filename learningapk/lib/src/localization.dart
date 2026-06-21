import 'package:flutter/widgets.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;
  bool get isSwahili => locale.languageCode == 'sw';

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  String text(String key) {
    return (isSwahili ? _sw : _en)[key] ?? _en[key] ?? key;
  }

  static const _en = <String, String>{
    'home': 'Home',
    'learn': 'Learn',
    'community': 'Community',
    'profile': 'Profile',
    'account': 'Account',
    'start_learning': 'Start Learning — Free',
    'guest_note':
        'No login is needed for lessons. Sign in only for quizzes, progress and community chat.',
    'why_laravel': 'Why Laravel?',
    'continue_learning': 'Continue learning',
    'topics_title': 'Laravel learning paths',
    'topics_subtitle': 'Choose a path and learn by building',
    'community_title': 'Laravel Community Tanzania',
    'join_community': 'Join the community',
    'join_message':
        'Create an account to chat with the admin, ask questions and get Laravel support.',
    'sign_in_or_register': 'Register or sign in',
    'my_progress': 'My progress',
    'language': 'Language',
    'english': 'English',
    'swahili': 'Kiswahili',
    'change_photo': 'Change profile photo',
    'logout': 'Sign out',
    'app_language': 'App language',
    'profile_guest_title': 'Your learning community',
    'profile_guest_message':
        'Lessons are free without login. An account unlocks quizzes, progress and realtime admin chat.',
    'welcome_back': 'Welcome back 👋',
    'start_journey': 'Start your journey',
    'login_subtitle':
        'Sign in to take quizzes, save progress and chat with the admin.',
    'register_subtitle':
        'Join the Laravel Tanzania learning community for quizzes and support.',
    'full_name': 'Full name',
    'email_or_username': 'Email or username',
    'password': 'Password',
    'sign_in': 'Sign in',
    'create_account': 'Create account',
    'have_account': 'Already have an account? Sign in',
    'no_account': 'No account? Register here',
    'lesson': 'Lesson',
    'complete_lesson': 'Mark lesson complete',
    'take_quiz': 'Take quiz',
    'lesson_content': 'Lesson content',
    'code_example': 'Code example',
    'real_life_example': 'Real-life example',
    'minutes': 'minutes',
    'completed': 'Completed',
    'send': 'Send',
    'type_message': 'Type a message...',
    'realtime_reverb': 'Realtime via Laravel Reverb',
    'photo_updated': 'Profile picture updated.',
    'upload_failed': 'Profile picture upload failed.',
    'topic_lessons': 'Topics and lessons',
    'lesson_quiz': 'Lesson quiz',
    'quiz_unavailable': 'Quiz is not available yet',
    'quiz_unavailable_message':
        'Please return later for this lesson’s questions.',
    'submit_answers': 'Submit answers',
    'correct_answer': 'Correct answer',
    'back_to_lesson': 'Back to lesson',
    'start_first_lesson': 'Start your first lesson',
    'progress_empty': 'Lessons you open and complete will appear here.',
    'progress_title': 'My progress',
    'progress_subtitle': 'Every small step is a win',
    'answered': 'answered',
    'question': 'QUESTION',
    'answer_all': 'Answer every question before submitting.',
    'passed_message': 'Congratulations, you passed!',
    'retry_message': 'Keep learning and try again.',
    'no_conversations': 'No conversations yet',
    'contacts_appear': 'Support experts will appear here.',
  };

  static const _sw = <String, String>{
    'home': 'Nyumbani',
    'learn': 'Masomo',
    'community': 'Community',
    'profile': 'Wasifu',
    'account': 'Akaunti',
    'start_learning': 'Anza Kujifunza — Bure',
    'guest_note':
        'Huhitaji login kusoma masomo. Jisajili tu kwa quiz, progress na community chat.',
    'why_laravel': 'Kwa nini Laravel?',
    'continue_learning': 'Endelea kujifunza',
    'topics_title': 'Njia za kujifunza Laravel',
    'topics_subtitle': 'Chagua njia, kisha jifunze kwa vitendo',
    'community_title': 'Laravel Community Tanzania',
    'join_community': 'Jiunge na community',
    'join_message':
        'Jisajili ili uchate na admin, uulize maswali na kupata msaada wa Laravel.',
    'sign_in_or_register': 'Jisajili au ingia',
    'my_progress': 'Maendeleo yangu',
    'language': 'Lugha',
    'english': 'English',
    'swahili': 'Kiswahili',
    'change_photo': 'Badili picha ya wasifu',
    'logout': 'Toka kwenye akaunti',
    'app_language': 'Lugha ya app',
    'profile_guest_title': 'Learning community yako',
    'profile_guest_message':
        'Masomo ni bure bila login. Akaunti inakupa quiz, progress na realtime chat na admin.',
    'welcome_back': 'Karibu tena 👋',
    'start_journey': 'Anza safari yako',
    'login_subtitle':
        'Ingia kufanya quiz, kuhifadhi maendeleo na kuchat na admin.',
    'register_subtitle':
        'Jiunge na community ya kujifunza Laravel Tanzania kwa quiz na msaada.',
    'full_name': 'Jina kamili',
    'email_or_username': 'Email au username',
    'password': 'Nenosiri',
    'sign_in': 'Ingia',
    'create_account': 'Tengeneza akaunti',
    'have_account': 'Una akaunti tayari? Ingia',
    'no_account': 'Huna akaunti? Jisajili hapa',
    'lesson': 'Somo',
    'complete_lesson': 'Nimemaliza somo',
    'take_quiz': 'Fanya quiz',
    'lesson_content': 'Maelezo ya somo',
    'code_example': 'Code mfano',
    'real_life_example': 'Mfano wa maisha halisi',
    'minutes': 'dakika',
    'completed': 'Limekamilika',
    'send': 'Tuma',
    'type_message': 'Andika ujumbe...',
    'realtime_reverb': 'Realtime kupitia Laravel Reverb',
    'photo_updated': 'Picha ya wasifu imesasishwa.',
    'upload_failed': 'Imeshindikana kuweka picha ya wasifu.',
    'topic_lessons': 'Mada na masomo',
    'lesson_quiz': 'Quiz ya somo',
    'quiz_unavailable': 'Quiz bado haijawekwa',
    'quiz_unavailable_message': 'Rudi baadaye kwa maswali ya somo hili.',
    'submit_answers': 'Tuma majibu',
    'correct_answer': 'Jibu sahihi',
    'back_to_lesson': 'Rudi kwenye somo',
    'start_first_lesson': 'Anza somo lako la kwanza',
    'progress_empty': 'Masomo utakayofungua na kumaliza yataonekana hapa.',
    'progress_title': 'Maendeleo yangu',
    'progress_subtitle': 'Kila hatua ndogo ni ushindi',
    'answered': 'yamejibiwa',
    'question': 'SWALI',
    'answer_all': 'Jibu maswali yote kabla ya kutuma.',
    'passed_message': 'Hongera, umefaulu!',
    'retry_message': 'Endelea kujifunza, jaribu tena.',
    'no_conversations': 'Hakuna mazungumzo bado',
    'contacts_appear': 'Wataalamu wa msaada wataonekana hapa.',
  };
}

extension LocalizedText on BuildContext {
  String tr(String key) => AppStrings.of(this).text(key);
}
