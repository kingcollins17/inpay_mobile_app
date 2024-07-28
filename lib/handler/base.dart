///Note that these handlers should be accessed only by the global state manager such as ChangeNotifier
//
class Tested {
  ///The part of the code that has been tested. If the whole class has been tested
  ///the top of the class is annotated with a
  ///```dart
  /// Tested("Class")
  /// class MyClass {}
  /// ```
  final String piece;

  ///Annotates a piece of code that has been tested. Annotate a tested method thus
  const Tested(this.piece);
}

///Annotates a method that has been tested
const tested = Tested("Method");

///Represents status of operations. If status is false, an error message is most
///likely included
typedef Status = ({bool status, String message});

abstract class Handler {}
