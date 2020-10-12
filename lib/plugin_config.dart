class PluginConfig {
  static const String CHANNEL_NAME = "zpdl_studio_media_plugin";
}

enum PlatformMethod {
  GET_IMAGE_FOLDER,
  GET_IMAGE_FILES,
  GET_IMAGE_THUMBNAIL,
  CHECK_UPDATE,
}

extension PlatformMethodExtension on PlatformMethod {
  String get method {
    String _method = "";
    switch(this) {
      case PlatformMethod.GET_IMAGE_FOLDER:
        _method = "${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FOLDER";
        break;
      case PlatformMethod.GET_IMAGE_FILES:
        _method = "${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FILES";
        break;
      case PlatformMethod.GET_IMAGE_THUMBNAIL:
        _method = "${PluginConfig.CHANNEL_NAME}/GET_IMAGE_THUMBNAIL";
        break;
      case PlatformMethod.CHECK_UPDATE:
        _method = "${PluginConfig.CHANNEL_NAME}/CHECK_UPDATE";
        break;
    }

    return _method;
  }
}