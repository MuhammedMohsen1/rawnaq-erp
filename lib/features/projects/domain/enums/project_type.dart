enum ProjectType { execution, design }

extension ProjectTypeExtension on ProjectType {
  String get apiValue => switch (this) {
    ProjectType.execution => 'EXECUTION',
    ProjectType.design => 'DESIGN',
  };

  String get arabicName => switch (this) {
    ProjectType.execution => 'تنفيذ',
    ProjectType.design => 'تصميم',
  };

  static ProjectType fromApiString(String? value) {
    return value?.toUpperCase() == 'DESIGN'
        ? ProjectType.design
        : ProjectType.execution;
  }
}
