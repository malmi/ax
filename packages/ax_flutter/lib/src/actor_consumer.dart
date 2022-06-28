import 'dart:async';

import 'package:ax/ax.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/single_child_widget.dart';

import 'actor_provider.dart';

part 'actor_consumer2.dart';
part 'actor_consumer3.dart';

mixin ActorConsumerSingleChildWidget on SingleChildWidget {}

typedef ActorBuilder<S> = Widget Function(BuildContext context, S state);

typedef ActorListener<S> = FutureOr<void> Function(
  BuildContext context,
  S previousState,
  S currentState,
);

class ActorConsumer<TActor extends Actor<TState>, TState>
    extends SingleChildStatefulWidget with ActorConsumerSingleChildWidget {
  final ActorBuilder<TState?>? builder;
  final ActorListener<TState?>? listener;

  const ActorConsumer({
    Key? key,
    this.builder,
    this.listener,
    Widget? child,
  })  : assert(builder != null || listener != null),
        super(key: key, child: child);

  @override
  SingleChildState<ActorConsumer<TActor, TState>> createState() =>
      _ActorConsumerState<TActor, TState>();
}

class _ActorConsumerState<TActor extends Actor<TState>, TState>
    extends SingleChildState<ActorConsumer<TActor, TState>> {
  late StreamSubscription<TState> _subscription;
  late TActor _actor;
  TState? _state;
  TState? _previousState;

  @override
  void initState() {
    super.initState();
    _actor = ActorProvider.of<TActor>(context);
    _previousState = _state = _actor.state;
    _subscribe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final actor = ActorProvider.of<TActor>(context);
    if (_actor != actor) {
      _unsubscribe();
      _actor = actor;
      _previousState = _state = _actor.state;
      _subscribe();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return widget.builder != null
        ? widget.builder!(context, _state)
        : child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _actor.states.listen((state) {
      if (widget.listener != null) {
        widget.listener!(context, _previousState, state);
      }

      setState(() {
        _previousState = _state = state;
      });
    });
  }

  void _unsubscribe() {
    _subscription.cancel();
  }
}
