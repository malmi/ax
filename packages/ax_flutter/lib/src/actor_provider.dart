import 'package:ax/ax.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ActorProvider<T extends IActor> extends Provider<T> {
  ActorProvider({
    Key? key,
    required Create<T> create,
    bool lazy = true,
  }) : super(
          key: key,
          lazy: lazy,
          create: create,
          dispose: (_, actor) => actor.close(),
        );

  ActorProvider.value({
    Key? key,
    required T value,
    Widget? child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  static T of<T>(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) {
        rethrow;
      }

      throw FlutterError(
        '''
        ActorProvider.of() called with a context that does not contain a repository of type $T.
        No ancestor could be found starting from the context that was passed to ActorProvider.of<$T>().
        This can happen if the context you used comes from a widget above the ActorProvider.
        The context used was: $context
        ''',
      );
    }
  }
}

class MultiActorProvider extends MultiProvider {
  MultiActorProvider({
    Key? key,
    required List<SingleChildStatelessWidget> actors,
    required Widget child,
  }) : super(key: key, providers: actors, child: child);
}
