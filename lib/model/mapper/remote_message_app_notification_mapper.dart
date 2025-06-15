import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../index.dart';

final remoteMessageAppNotificationMapperProvider =
    Provider.autoDispose<RemoteMessageAppNotificationMapper>(
  (ref) => getIt.get<RemoteMessageAppNotificationMapper>(),
);

@Injectable()
class RemoteMessageAppNotificationMapper extends BaseDataMapper<RemoteMessage, AppNotification> {
  @override
  AppNotification mapToLocal(RemoteMessage? data) {
    return AppNotification(
      title: data?.notification?.title ?? '',
      message: data?.notification?.body ?? '',
      image: safeCast<String>(data?.data[Constant.fcmImage]) ?? '',
      conversationId: safeCast<String>(data?.data[Constant.fcmConversationId]) ?? '',
    );
  }
}
