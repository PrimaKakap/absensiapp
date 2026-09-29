import 'dart:math';

enum LivenessAction {
  blink,
  turnLeft,
  turnRight,
  lookUp,
}

extension LivenessActionExt on LivenessAction {
  String get instruction {
    switch (this) {
      case LivenessAction.blink:return 'Kedipkan Kedua Mata';
      case LivenessAction.turnLeft:return 'Tolehkan Wajah ke Kiri';
      case LivenessAction.turnRight:return 'Tolehkan Wajah ke Kanan';
      case LivenessAction.lookUp:return 'Tengokkan Wajah ke Atas';
    }
  }
}

class ChallengeSequence {
  final List<LivenessAction> actions;
  int currentIndex = 0;

  ChallengeSequence(this.actions);

  LivenessAction? get currentAction =>
      currentIndex < actions.length ? actions[currentIndex] : null;

  bool get isCompleted => currentIndex >= actions.length;

  void next() => currentIndex++;

  static ChallengeSequence generateRandom({int count = 2}) {
    final random = Random();
    final allActions = List<LivenessAction>.from(LivenessAction.values);
    allActions.shuffle(random);
    return ChallengeSequence(allActions.take(count).toList());
  }
}