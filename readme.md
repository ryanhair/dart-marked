#DartMarked

A Dart port of the fantastic `marked` javascript library.
See https://github.com/chjj/marked for more details

##Quick Use

For simplest usage, import `dart-marked` and use `marked` function, like below:

```dart
import 'package:dart_marked/dart_marked.dart';

main() {
    marked('#Some markdown here').then((response) => print(response));
}
```
