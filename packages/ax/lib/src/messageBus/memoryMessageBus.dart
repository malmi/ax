import 'package:rxdart/rxdart.dart';

import 'message.dart';
import 'messageBus.dart';

class MemoryMessageBus implements MessageBus {
  final _subject = PublishSubject<Message>();

  @override
  Stream<Message> get stream => _subject.stream;

  @override
  Future<void> dispatch<TMessage extends Message>(TMessage msg) async {
    if (_subject.isClosed) {
      return;
    }
    _subject.add(msg);
  }

  @override
  Future<void> close() async {
    await _subject.close();
  }
}
