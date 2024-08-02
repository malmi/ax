import 'dart:async';

import 'package:flutter/foundation.dart';

import 'actor_system.dart';
import 'message_bus.dart';

typedef MessageHandler<TEvent> = Future<void> Function(TEvent event);

abstract class IActor {
  @protected
  void onMessage<TMessage extends Message>(MessageHandler<TMessage> handler);

  @protected
  Future<void> dispatch<TMessage extends Message>(TMessage msg);

  @mustCallSuper
  Future<void> close();
}

abstract class StatelessActor implements IActor {
  final _handlers = <_Handler>[];
  final MessageBus _messageBus;
  late StreamSubscription<void> _subscription;

  StatelessActor(MessageBus messageBus) : _messageBus = messageBus {
    ActorSystem.instance.add(this);

    _subscription = _messageBus.stream
        .asyncExpand((event) => Stream.fromFuture(_onMessage(event)))
        .listen(null);
  }

  @override
  void onMessage<TMessage extends Message>(
    MessageHandler<TMessage> handler, {
    void Function(dynamic err, StackTrace stackTrace)? onError,
  }) {
    final handlerExists = _handlers.any((h) => h.type == TMessage);
    if (handlerExists) {
      throw StateError(
        'on<$TMessage> was called multiple times. There should only be a single message handler per type.',
      );
    }

    _handlers.add(_Handler(
      isType: (dynamic e) => e is TMessage,
      type: TMessage,
      handler: (msg) async {
        try {
          await handler(msg as TMessage);
        } catch (ex, st) {
          if (onError != null) {
            onError(ex, st);
          }
          ActorSystem.instance.onError(this, ex, st);
        }
      },
    ));
  }

  @override
  Future<void> dispatch<TMessage extends Message>(TMessage msg) =>
      _messageBus.dispatch(msg);

  @override
  @mustCallSuper
  Future<void> close() async {
    ActorSystem.instance.remove(this);
    _handlers.clear();
    await _subscription.cancel();
  }

  Future<void> _onMessage(Message event) async {
    // Local copy for concurrent modifications
    final localHandlers = [..._handlers];
    for (final handler in localHandlers.where((h) => h.isType(event))) {
      await handler.handler(event);
    }
  }
}

class _Handler {
  final bool Function(dynamic value) isType;
  final Type type;
  final MessageHandler<Message> handler;

  const _Handler({
    required this.isType,
    required this.type,
    required this.handler,
  });
}
