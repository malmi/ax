part of 'actor_consumer.dart';

typedef ActorBuilder2<S1, S2> = Widget Function(
    BuildContext context, S1 state1, S2 state2);

class ActorConsumer2<TActor1 extends Actor<TState1>, TState1,
    TActor2 extends Actor<TState2>, TState2> extends StatelessWidget {
  final ActorBuilder2<TState1, TState2> builder;
  final ActorListener<TState1> listenerOne;
  final ActorListener<TState2> listenerTwo;

  const ActorConsumer2({Key key, this.builder, this.listenerOne, this.listenerTwo})
      : assert(builder != null || listenerOne != null || listenerTwo != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActorConsumer<TActor1, TState1>(
      listener: listenerOne,
      builder: (_, state1) => ActorConsumer<TActor2, TState2>(
        listener: listenerTwo,
        builder: (context, state2) => builder(context, state1, state2),
      ),
    );
  }
}
