import 'package:rxdart/rxdart.dart';

import 'message.dart';
import 'messageBus.dart';

class CombinedMessageBus implements MessageBus {
  final Iterable<MessageBus> messageBuses;

  CombinedMessageBus(this.messageBuses);

  @override
  Stream<Message> get stream => Rx.merge(messageBuses.map((mb) => mb.stream));

  @override
  Future<void> dispatch<TMessage extends Message>(TMessage msg) {
    return Future.wait(messageBuses.map((mb) => mb.dispatch(msg)).toList());
  }

  @override
  Future<void> close() {
    return Future.wait(messageBuses.map((mb) => mb.close()).toList());
  }
}
