import '../../../../index.dart';

class JsonArrayResponseDecoder<T extends Object> extends BaseSuccessResponseDecoder<T, List<T>> {
  @override
  List<T>? mapToDataModel({
    // ignore: avoid_dynamic
    required dynamic response,
    Decoder<T>? decoder,
  }) {
    return decoder != null && response is List
        ? response
            .map((jsonObject) => decoder(jsonObject as Map<String, dynamic>))
            .toList(growable: false)
        : null;
  }
}
