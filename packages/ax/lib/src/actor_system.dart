import 'actor_hydrated.dart';
import 'actor_stateless.dart';
import 'extensions/iterable.dart';

class ActorSystem {
  void Function(IActor actor, dynamic ex, StackTrace st) onError =
      (IActor actor, dynamic ex, StackTrace st) {};

  ActorSystem._();

  static ActorSystem? _instance;
  static ActorSystem get instance {
    _instance ??= ActorSystem._();
    return _instance!;
  }

  final _actors = <IActor>[];

  void add(IActor actor) => _actors.add(actor);
  void addAll(Iterable<IActor> actors) => actors.forEach(add);

  TActor? get<TActor>() {
    return _actors.firstWhereOrNull((element) => element is TActor) as TActor?;
  }

  bool remove(IActor actor) => _actors.remove(actor);

  Future<void> reload() => Future.wait(
        _actors
            // ignore: prefer_iterable_wheretype
            .where((actor) => actor is HydratedActor)
            .cast<HydratedActor>()
            .map((actor) => actor.reload()),
      );
}
