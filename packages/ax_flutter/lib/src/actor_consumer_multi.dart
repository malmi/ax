import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'actor_consumer.dart';

class MultiActorConsumer extends MultiProvider {
  MultiActorConsumer({
    Key? key,
    required List<ActorConsumerSingleChildWidget> consumers,
    required Widget child,
  }) : super(key: key, providers: consumers, child: child);
}
