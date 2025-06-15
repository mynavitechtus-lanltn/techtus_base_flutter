import 'package:injectable/injectable.dart';

import '../../../../index.dart';

@Injectable()
// ignore: avoid_dynamic
class JsonArrayErrorResponseDecoder extends BaseErrorResponseDecoder<List<dynamic>> {
  @override
  // ignore: avoid_dynamic
  ServerError mapToServerError(List<dynamic>? data) {
    return ServerError(
      errors: data
              ?.map((jsonObject) => ServerErrorDetail(
                    serverStatusCode: jsonObject['code'] as int?,
                    message: jsonObject['message'] as String?,
                  ))
              .toList(growable: false) ??
          [],
    );
  }
}
