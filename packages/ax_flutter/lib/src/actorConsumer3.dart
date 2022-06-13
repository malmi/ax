part of 'actorConsumer.dart';

typedef ActorBuilder3<S1, S2, S3> = Widget Function(
    BuildContext context, S1 state1, S2 state2, S3 state3);

class ActorConsumer3<
    TActor1 extends Actor<TState1>,
    TState1,
    TActor2 extends Actor<TState2>,
    TState2,
    TActor3 extends Actor<TState3>,
    TState3> extends StatelessWidget {
  final ActorBuilder3<TState1, TState2, TState3> builder;
  final ActorListener<TState1> listenerOne;
  final ActorListener<TState2> listenerTwo;
  final ActorListener<TState3> listenerThree;

  const ActorConsumer3(
      {Key key, this.builder, this.listenerOne, this.listenerTwo, this.listenerThree})
      : assert(builder != null ||
            listenerOne != null ||
            listenerTwo != null ||
            listenerThree != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActorConsumer2<TActor1, TState1, TActor2, TState2>(
      listenerOne: listenerOne,
      listenerTwo: listenerTwo,
      builder: (_, state1, state2) => ActorConsumer<TActor3, TState3>(
        listener: listenerThree,
        builder: (context, state3) => builder(context, state1, state2, state3),
      ),
    );
  }
}
