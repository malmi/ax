import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import './actorConsumer.dart';

class MultiActorConsumer extends MultiProvider {
  MultiActorConsumer({
    Key key,
    @required List<ActorConsumerSingleChildWidget> consumers,
    @required Widget child,
  }) : super(key: key, providers: consumers, child: child);
}
