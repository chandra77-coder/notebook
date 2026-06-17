class QuickAddButton {
  final String label;
  final double defaultAmount;

  QuickAddButton({
    required this.label,
    required this.defaultAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'defaultAmount': defaultAmount,
    };
  }

  factory QuickAddButton.fromMap(Map<String, dynamic> map) {
    return QuickAddButton(
      label: map['label'] as String,
      defaultAmount: map['defaultAmount'] as double,
    );
  }
}

class Person {
  final String id;
  final String name;
  final String avatarColor;
  final List<QuickAddButton> quickAddButtons;

  Person({
    required this.id,
    required this.name,
    required this.avatarColor,
    this.quickAddButtons = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarColor': avatarColor,
      'quickAddButtons': quickAddButtons.map((btn) => btn.toMap()).toList(),
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarColor: map['avatarColor'] as String,
      quickAddButtons: (map['quickAddButtons'] as List?)
              ?.map((btn) => QuickAddButton.fromMap(btn as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Person copyWith({
    String? id,
    String? name,
    String? avatarColor,
    List<QuickAddButton>? quickAddButtons,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColor: avatarColor ?? this.avatarColor,
      quickAddButtons: quickAddButtons ?? this.quickAddButtons,
    );
  }
}
