import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:game_edu/core/config/server_config.dart';

/// One video of a lesson:
///   _Video('Title', seconds, 'video link', 'thumbnail image link')
/// Leave the video link '' to use a sample test video.
/// Leave the thumbnail '' to use the YouTube thumbnail (YouTube links only).
class _Video {
  const _Video(this.title, this.seconds, [this.url = '', this.thumbnailUrl = '']);

  final String title;
  final int seconds;
  final String url;
  final String thumbnailUrl;
}

/// One lesson (= one class page):
///   _Lesson('Title', minutes, 'video link', 'About text',
///           takeaways, videos, materials, imageUrl)
///
///  * videos     : the "Lesson Videos" list. If empty, ONE video is made from
///                 the title / minutes / video link.
///  * takeaways  : the "Key Takeaways" bullets (optional).
///  * materials  : the study notes files (optional), for example
///                 {'title': 'Game Design Notes', 'url': 'https://...pdf', 'type': 'pdf'}
///                 Only written when not empty, so materials you added by hand
///                 are not touched.
class _Lesson {
  const _Lesson(
    this.title,
    this.minutes, [
    this.videoUrl = '',
    this.description = '',
    this.takeaways = const <String>[],
    this.videos = const <_Video>[],
    this.materials = const <Map<String, String>>[],
    this.imageUrl = '',
  ]);

  final String title;
  final int minutes;
  final String videoUrl;
  final String description;
  final List<String> takeaways;
  final List<_Video> videos;
  final List<Map<String, String>> materials;

  /// Picture at the top of the class page (image link). '' = course thumbnail.
  final String imageUrl;
}

/// One multiple-choice question:
///   _Q('Question text', ['A', 'B', 'C', 'D'], correctIndex, marks)
/// correctIndex: 0 = first option, 1 = second, 2 = third, 3 = fourth.
/// marks is optional (default 1).
class _Q {
  const _Q(this.text, this.options, this.correctIndex, [this.marks = 1]);

  final String text;
  final List<String> options;
  final int correctIndex;
  final int marks;
}

class _Class {
  _Class({
    required this.id,
    required this.title,
    required this.description,
    required this.mentor,
    required this.topic,
    required this.starts,
    required this.ends,
    required this.lessons,
    this.college,
    this.imageUrl = '',
  });

  final String id; // document id (same id again = overwrite, no duplicate)
  final String title;
  final String description;
  final String mentor;
  final String topic; // also used as thumbnailKey
  final DateTime starts;
  final DateTime ends;
  final String? college; // null = general (everyone)
  final List<_Lesson> lessons;

  /// Top picture for ALL lessons of this class (optional).
  /// Order: lesson image -> this image -> _defaultImageUrl.
  final String imageUrl;
}

/// IST date/time -> DateTime (stored in Firestore as a timestamp).
DateTime _ist(int year, int month, int day, int hour, [int minute = 0]) =>
    DateTime.utc(year, month, day, hour, minute)
        .subtract(const Duration(hours: 5, minutes: 30));

/// TEST ONLY: sample videos used when a lesson has no link of its own.
/// Replace them with your real lesson videos later.
const List<String> _sampleVideos = [
  'https://youtu.be/zCC0IndIyiM?si=fTRI2DmkoeI5XrXh',
  'https://www.youtube.com/live/Cmq3DFZKEGQ?si=52mJ_M8QkLqF7U-1',
  'https://youtu.be/RRubcjpTkks?si=1UeeBCqv0YaIH508',
  'https://youtu.be/allwzMI2dp0?si=EwwNTKyt98rMlj6T',
  'https://youtu.be/v5p_SUfi710?si=qXh5_pZf_lG1mSDH',
  'https://youtu.be/kArGE1-vRrw?si=zdqV_ZDwXzm6zhz4',
];

/// Picture at the TOP of every class page, when the lesson and its class have
/// no image of their own. Paste your image link here.
const String _defaultImageUrl =
    'https://res.cloudinary.com/dtz0urit6/image/upload/q_auto:best,f_jpg/cloudinary-tools-uploads/v9eyvikjmhoq8myb7tg5';

/// "Key Takeaways" of every lesson that has none of its own.
/// Replace these lines with your real text (or give a lesson its own list).
const List<String> _defaultTakeaways = [
  'Watch every lesson video to the end.',
  'Read the study notes before the assignment.',
  'Finish the assignment to complete this class.',
];

/// Study notes file (PDF link) given to every lesson that has none of its own.
/// Paste a real PDF link here. Empty = no file row is added.
const String _defaultMaterialUrl = '';
const String _defaultMaterialTitle = 'Class Notes';

// All seeded lessons use the same assignment (15 questions, 17 marks).
const List<_Q> _assignmentQuestions = [
  _Q('What is a game loop?', [
    'A menu screen',
    'Code that runs every frame',
    'A save file',
    'A level',
  ], 1, 2),
  _Q('Which are the three basic steps of a typical game loop?', [
    'Save, load, quit',
    'Menu, play, pause',
    'Input, update, render',
    'Design, test, ship',
  ], 2),
  _Q('What is a game mechanic?', [
    'The art style of a game',
    'A rule or action the player uses to interact with the game',
    'The engine used to build the game',
    'The price of the game',
  ], 1),
  _Q('Jumping in a platformer is an example of a:', [
    'Core mechanic',
    'Sound effect',
    'Loading screen',
    'Store page',
  ], 0),
  _Q('What is a core loop?', [
    'The code that loads the game',
    'The first level only',
    'The credits sequence',
    'The set of actions a player repeats again and again',
  ], 3),
  _Q('Which part of a core loop gives the player a reason to keep playing?', [
    'The loading screen',
    'The settings menu',
    'The reward',
    'The credits',
  ], 2),
  _Q('What does frame rate (FPS) measure?', [
    'How many frames the game draws every second',
    'The size of the game file',
    'The number of players online',
    'The length of a level',
  ], 0),
  _Q('A game running at 60 FPS draws about how many frames each second?', [
    '30',
    '60',
    '120',
    '6',
  ], 1),
  _Q('Why do games use delta time in the game loop?', [
    'To make the game load faster',
    'To change the art style',
    'To lock the score',
    'To keep movement speed the same on fast and slow devices',
  ], 3, 2),
  _Q('Which of these is feedback to the player?', [
    'The loading screen',
    'The developer email',
    'A sound and a flash when you collect a coin',
    'The settings menu',
  ], 2),
  _Q('What is a win condition?', [
    'What the player must achieve to win the game',
    'The price of the game',
    'The number of levels',
    'The colour palette',
  ], 0),
  _Q('Which mechanic fits a racing game best?', [
    'Casting spells in a dungeon',
    'Steering and accelerating',
    'Building a farm',
    'Solving a crossword',
  ], 1),
  _Q(
    'A risky shortcut that might crash your car but gives a faster lap is '
    'an example of:',
    ['A bug', 'A loading screen', 'A tutorial', 'Risk versus reward'],
    3,
  ),
  _Q('What happens in the update step of a game loop?', [
    'Only the music is played',
    'The game is uninstalled',
    'Positions, scores and other game state are changed',
    'The store page opens',
  ], 2),
  _Q('Why do developers playtest a game loop?', [
    'To check if the loop is fun and easy to understand',
    'To make the file bigger',
    'To remove all sound',
    'To hide bugs',
  ], 0),
];

/// Collects writes and commits them in chunks (a batch allows 500 writes).
class _BatchWriter {
  _BatchWriter(this._firestore) : _batch = _firestore.batch();

  final FirebaseFirestore _firestore;
  WriteBatch _batch;
  int _pending = 0;
  int total = 0;

  static const int _chunk = 400;

  /// merge: true => existing fields that are not listed here (for example a
  /// `materials` array you added by hand) are kept.
  Future<void> set(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    _batch.set(ref, data, SetOptions(merge: true));
    _pending++;
    total++;
    if (_pending >= _chunk) await _flush();
  }

  Future<void> _flush() async {
    if (_pending == 0) return;
    await _batch.commit();
    _batch = _firestore.batch();
    _pending = 0;
  }

  Future<void> commit() => _flush();
}

/// Inserts classes + their lessons + assignment questions. Debug builds only.
/// Remove this file after the data is in Firestore.
class ClassesSeed {
  ClassesSeed._();

  /// College classes are saved for this college. Use the SAME text as the
  /// college in your profile (compared ignoring upper/lower case).
  static const String _college = 'RGI';

  static Future<void> run() async {
    if (!kDebugMode) return;

    final firestore = FirebaseFirestore.instance;
    final col = firestore.collection(ServerConfig.classesCollection);

    // ─────────────── EDIT YOUR CLASSES + LESSONS HERE ───────────────
    final classes = <_Class>[
      // ───────── General (everyone) ─────────
      _Class(
        id: 'seed_01',
        title: 'Track Design Masterclass',
        description:
            'Learn how to design a racing track: layout, corners, elevation and flow.',
        mentor: 'Sana Iqbal',
        topic: 'track_design',
        starts: _ist(2026, 11, 25, 11),
        ends: _ist(2026, 11, 25, 12),
        lessons: const [
          _Lesson(
            'Track Layout Basics',
            15,
            '',
            'Learn how straights and corners shape a track, and where to brake, turn in, and accelerate.',
            [
              'Straights are for building speed.',
              'The apex is the inside point of a corner.',
              'Brake before the turn, then accelerate on exit.',
            ],
            [
              // video link '' = sample test video; last value = thumbnail image
              _Video(
                'Track Layout Overview',
                522,
                '',
                _defaultImageUrl,
              ),
              _Video(
                'Corners & Racing Lines',
                375,
                '',
                _defaultImageUrl,
              ),
            ],
            // study notes files (optional)
            // [
            //   {'title': 'Game Design Notes', 'url': 'https://...pdf', 'type': 'pdf'},
            // ],
            const <Map<String, String>>[],
            // picture at the TOP of the class page
            _defaultImageUrl,
          ),
          _Lesson('Corners and elevation', 15, ''),
          _Lesson('Racing line and flow', 12, ''),
          _Lesson('Testing your track', 10, ''),
        ],
      ),
      _Class(
        id: 'seed_02',
        title: 'Game Design Basics',
        description:
            'Core game design ideas: mechanics, game loops, player goals and rewards.',
        mentor: 'Arun Prakash',
        topic: 'game_design',
        starts: _ist(2026, 11, 25, 15),
        ends: _ist(2026, 11, 25, 16, 30),
        lessons: const [
          _Lesson('What makes a game fun', 10, ''),
          _Lesson('Mechanics and game loops', 15, ''),
          _Lesson('Goals and rewards', 12, ''),
          _Lesson('Playtesting', 10, ''),
        ],
      ),
      _Class(
        id: 'seed_03',
        title: 'Unity Essentials',
        description:
            'Build your first scene in Unity with GameObjects, components and prefabs.',
        mentor: 'Meera Nair',
        topic: 'unity',
        starts: _ist(2026, 11, 26, 10),
        ends: _ist(2026, 11, 26, 12),
        lessons: const [
          _Lesson('Unity editor tour', 10, ''),
          _Lesson('GameObjects and components', 15, ''),
          _Lesson('Prefabs and scenes', 15, ''),
          _Lesson('Build your first scene', 20, ''),
        ],
      ),
      _Class(
        id: 'seed_04',
        title: 'Pixel Art Starter',
        description: 'Draw sprites, animations and tilesets for 2D games.',
        mentor: 'Ananya Das',
        topic: 'pixel_art',
        starts: _ist(2026, 11, 28, 16),
        ends: _ist(2026, 11, 28, 17),
        lessons: const [
          _Lesson('Canvas and palette', 8, ''),
          _Lesson('Drawing sprites', 15, ''),
          _Lesson('Animation frames', 12, ''),
          _Lesson('Making a tileset', 12, ''),
        ],
      ),
      _Class(
        id: 'seed_05',
        title: '3D Modeling Starter',
        description: 'Model a simple game prop and prepare it for a game engine.',
        mentor: 'Vikram Shah',
        topic: 'modeling_3d',
        starts: _ist(2026, 12, 1, 15),
        ends: _ist(2026, 12, 1, 16, 30),
        lessons: const [
          _Lesson('Interface and basic shapes', 10, ''),
          _Lesson('Modeling a prop', 20, ''),
          _Lesson('UV unwrapping', 15, ''),
          _Lesson('Exporting to an engine', 10, ''),
        ],
      ),

      // ───────── College classes ─────────
      _Class(
        id: 'seed_06',
        title: 'C# for Game Developers',
        description:
            'Variables, classes and scripts used in Unity, taught for your college batch.',
        mentor: 'Rahul Verma',
        topic: 'csharp',
        college: _college,
        starts: _ist(2026, 11, 27, 11),
        ends: _ist(2026, 11, 27, 13),
        lessons: const [
          _Lesson('Variables and types', 12, ''),
          _Lesson('Classes and methods', 15, ''),
          _Lesson('Unity scripts', 15, ''),
          _Lesson('Player movement script', 20, ''),
        ],
      ),
      _Class(
        id: 'seed_07',
        title: 'Level Design Workshop',
        description:
            'Block out a playable level: pacing, player flow and difficulty curve.',
        mentor: 'Divya Menon',
        topic: 'level_design',
        college: _college,
        starts: _ist(2026, 11, 27, 14),
        ends: _ist(2026, 11, 27, 15, 30),
        lessons: const [
          _Lesson('Blocking out a level', 15, ''),
          _Lesson('Pacing and flow', 12, ''),
          _Lesson('Difficulty curve', 12, ''),
          _Lesson('Polish pass', 10, ''),
        ],
      ),
      _Class(
        id: 'seed_08',
        title: 'Unreal Engine Blueprints',
        description:
            'Make gameplay in Unreal Engine with Blueprints, no code needed.',
        mentor: 'Sana Iqbal',
        topic: 'unreal_engine',
        college: _college,
        starts: _ist(2026, 11, 30, 11),
        ends: _ist(2026, 11, 30, 12, 30),
        lessons: const [
          _Lesson('Editor basics', 10, ''),
          _Lesson('Blueprint basics', 15, ''),
          _Lesson('Gameplay logic', 20, ''),
          _Lesson('Packaging a build', 10, ''),
        ],
      ),
      _Class(
        id: 'seed_09',
        title: 'Game Audio Basics',
        description:
            'Sound effects and music for games, and how to add them in an engine.',
        mentor: 'Imran Khan',
        topic: 'game_audio',
        college: _college,
        starts: _ist(2026, 12, 2, 10, 30),
        ends: _ist(2026, 12, 2, 12),
        lessons: const [
          _Lesson('Sound basics', 8, ''),
          _Lesson('Sound effects', 12, ''),
          _Lesson('Music loops', 12, ''),
          _Lesson('Audio in the engine', 15, ''),
        ],
      ),
      _Class(
        id: 'seed_10',
        title: 'Unity 2D Platformer Project',
        description:
            'Build a small 2D platformer in Unity step by step as a college project.',
        mentor: 'Meera Nair',
        topic: 'unity',
        college: _college,
        starts: _ist(2026, 12, 4, 14),
        ends: _ist(2026, 12, 4, 16),
        lessons: const [
          _Lesson('Project setup', 10, ''),
          _Lesson('Player controller', 20, ''),
          _Lesson('Enemies and hazards', 20, ''),
          _Lesson('Finishing the game', 15, ''),
        ],
      ),
    ];
    // ─────────────────────────────────────────────────────────────────

    final writer = _BatchWriter(firestore);
    var lessonCount = 0;
    var questionCount = 0;

    for (final c in classes) {
      final classRef = col.doc(c.id);

      await writer.set(classRef, {
        'title': c.title,
        'description': c.description,
        'mentorName': c.mentor,
        'topic': c.topic,
        'thumbnailKey': c.topic,
        'audience': c.college == null ? 'general' : 'college',
        'college': c.college,
        'startsAt': Timestamp.fromDate(c.starts),
        'endsAt': Timestamp.fromDate(c.ends),
      });

      for (var i = 0; i < c.lessons.length; i++) {
        final l = c.lessons[i];
        final lessonId = 'lesson_${(i + 1).toString().padLeft(2, '0')}';
        final lessonRef = classRef.collection('lessons').doc(lessonId);

        // the videos of this lesson (own links win, otherwise sample videos)
        final videos = <Map<String, dynamic>>[];
        if (l.videos.isEmpty) {
          videos.add({
            'id': 'video_01',
            'title': l.title,
            'url': l.videoUrl.isNotEmpty
                ? l.videoUrl
                : _sampleVideos[lessonCount % _sampleVideos.length],
            'durationSeconds': l.minutes * 60,
          });
        } else {
          for (var v = 0; v < l.videos.length; v++) {
            final video = l.videos[v];
            videos.add({
              'id': 'video_${(v + 1).toString().padLeft(2, '0')}',
              'title': video.title,
              'url': video.url.isNotEmpty
                  ? video.url
                  : _sampleVideos[(lessonCount + v) % _sampleVideos.length],
              'durationSeconds': video.seconds,
              if (video.thumbnailUrl.isNotEmpty)
                'thumbnailUrl': video.thumbnailUrl,
            });
          }
        }

        // top picture: lesson image -> class image -> default image
        final image = l.imageUrl.isNotEmpty
            ? l.imageUrl
            : c.imageUrl.isNotEmpty
            ? c.imageUrl
            : _defaultImageUrl;

        // everything a class page needs: own value -> class value -> default
        final about = l.description.isNotEmpty ? l.description : c.description;
        final takeaways = l.takeaways.isNotEmpty
            ? l.takeaways
            : _defaultTakeaways;
        final materials = l.materials.isNotEmpty
            ? l.materials
            : _defaultMaterialUrl.isNotEmpty
            ? [
                {
                  'title': _defaultMaterialTitle,
                  'url': _defaultMaterialUrl,
                  'type': 'pdf',
                },
              ]
            : const <Map<String, String>>[];

        await writer.set(lessonRef, {
          'title': l.title,
          'description': about,
          'order': i + 1,
          'durationMinutes': l.minutes,
          // old single-video field = the first video (kept for old app builds)
          'videoUrl': videos.first['url'],
          'videos': videos,
          if (image.isNotEmpty) 'imageUrl': image,
          if (takeaways.isNotEmpty) 'keyTakeaways': takeaways,
          if (materials.isNotEmpty) 'materials': materials,
        });
        lessonCount++;

        for (var q = 0; q < _assignmentQuestions.length; q++) {
          final item = _assignmentQuestions[q];
          final questionId = 'q${(q + 1).toString().padLeft(2, '0')}';

          await writer.set(lessonRef.collection('questions').doc(questionId), {
            'question': item.text,
            'options': item.options,
            'correctIndex': item.correctIndex,
            'marks': item.marks,
            'order': q + 1,
          });
          questionCount++;
        }
      }
    }

    await writer.commit();
    debugPrint(
      '✅ [ClassesSeed] ${classes.length} classes, $lessonCount lessons and '
      '$questionCount questions written',
    );
  }
}