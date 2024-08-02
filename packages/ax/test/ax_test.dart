import 'package:ax/ax.dart';
import 'package:flutter_test/flutter_test.dart';

class Actor extends StatelessActor {
  TestMessage? lastMessage;

  Actor(MessageBus messageBus) : super(messageBus) {
    onMessage((TestMessage msg) async {
      lastMessage = msg;
    });
  }
}

class TestMessage extends Message {
  final String description;

  const TestMessage({required this.description});
}

void main() {
  test('Actor Construction', () {
    final mb = MemoryMessageBus();
    final actor = Actor(mb);
    expect(actor, isNotNull);
  });

  test('Simple Dispatch', () async {
    final mb = MemoryMessageBus();
    final actor = Actor(mb);
    expect(actor.lastMessage, isNull);

    // Dispatch a message
    const msg = TestMessage(description: 'Hello');
    await actor.dispatch(msg);
    expect(actor.lastMessage, isNotNull);
  });
}
