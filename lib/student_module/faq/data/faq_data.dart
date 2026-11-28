import 'package:flutter/material.dart';

import '../models/faq_item.dart';

/// The 15 FAQs of Game Edu.
/// Edit the text here, or load the same fields from Firestore later
/// (see FaqRepository).
const List<FaqItem> kFaqItems = [
  FaqItem(
    id: 'faq_01',
    category: FaqCategory.general,
    icon: Icons.school_outlined,
    question: 'What is Game Edu?',
    answer:
        'Game Edu is a career development app where you can learn through '
        'classes, connect with others, and take part in events.',
  ),
  FaqItem(
    id: 'faq_02',
    category: FaqCategory.classes,
    icon: Icons.laptop_mac_outlined,
    question: 'How do I find a class?',
    answer: 'Open the Classes section to browse available classes.',
  ),
  FaqItem(
    id: 'faq_03',
    category: FaqCategory.classes,
    icon: Icons.how_to_reg_outlined,
    question: 'How do I join a class?',
    answer:
        'Select a class to view its details and follow the joining '
        'instructions shown there.',
  ),
  FaqItem(
    id: 'faq_04',
    category: FaqCategory.classes,
    icon: Icons.video_library_outlined,
    question: 'What can I find inside a class?',
    answer:
        'A class may include videos, notes, assignments, and information '
        'about the topic.',
  ),
  FaqItem(
    id: 'faq_05',
    category: FaqCategory.classes,
    icon: Icons.play_circle_outline_rounded,
    question: 'Can I watch class videos later?',
    answer: 'Open the class and check its video section for available lessons.',
  ),
  FaqItem(
    id: 'faq_06',
    category: FaqCategory.classes,
    icon: Icons.description_outlined,
    question: 'Where can I find class notes?',
    answer: 'Open a class and tap View in the notes section.',
  ),
  FaqItem(
    id: 'faq_07',
    category: FaqCategory.classes,
    icon: Icons.assignment_outlined,
    question: 'How do I access an assignment?',
    answer: 'Open the relevant class and tap its Assignment button.',
  ),
  FaqItem(
    id: 'faq_08',
    category: FaqCategory.classes,
    icon: Icons.filter_list_rounded,
    question: 'Can I filter classes?',
    answer:
        'Yes. Use the available filters to find classes that match your '
        'interests or schedule.',
  ),
  FaqItem(
    id: 'faq_09',
    category: FaqCategory.chat,
    icon: Icons.chat_bubble_outline_rounded,
    question: 'What is the chat section for?',
    answer:
        'Chat helps you discuss topics, ask questions, and connect with '
        'other Game Edu users.',
  ),
  FaqItem(
    id: 'faq_10',
    category: FaqCategory.chat,
    icon: Icons.forum_outlined,
    question: 'How do I start chatting?',
    answer:
        'Open Community and select a conversation or group to participate '
        'in.',
  ),
  FaqItem(
    id: 'faq_11',
    category: FaqCategory.chat,
    icon: Icons.wifi_off_rounded,
    question: 'What should I do if I cannot send a message?',
    answer:
        'Check your internet connection, reopen the chat, and try again. '
        'If the problem continues, contact Help & Support.',
  ),
  FaqItem(
    id: 'faq_12',
    category: FaqCategory.events,
    icon: Icons.calendar_month_outlined,
    question: 'Where can I find upcoming events?',
    answer:
        'Open the Events section to see available events and their '
        'details.',
  ),
  FaqItem(
    id: 'faq_13',
    category: FaqCategory.events,
    icon: Icons.app_registration_rounded,
    question: 'How do I register for an event?',
    answer:
        'Open the event details and tap Register while registration is '
        'open.',
  ),
  FaqItem(
    id: 'faq_14',
    category: FaqCategory.events,
    icon: Icons.info_outline_rounded,
    question: 'What details can I see before registering for an event?',
    answer:
        'You can check the event date, venue, eligibility, description, '
        'and registration deadline.',
  ),
  FaqItem(
    id: 'faq_15',
    category: FaqCategory.events,
    icon: Icons.confirmation_number_outlined,
    question: 'How do I know if I have registered for an event?',
    answer: 'Open the event again and check its registration status.',
  ),
];
