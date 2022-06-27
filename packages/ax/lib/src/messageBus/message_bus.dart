import 'message.dart';

abstract class MessageBus {
  const MessageBus();

  Stream<Message> get stream;

  Future<void> dispatch<TMessage extends Message>(TMessage msg);
  Future<void> close();
}
