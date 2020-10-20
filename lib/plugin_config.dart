class PluginConfig {
  static const String CHANNEL_NAME = 'zpdl_studio_media_plugin';
}

enum PlatformMethod {
  GET_IMAGE_FOLDER,
  GET_IMAGE_FOLDER_COUNT,
  GET_IMAGE_FILES,
  GET_IMAGE_THUMBNAIL,
  READ_IMAGE_DATA,
  CHECK_UPDATE,
  GET_IMAGE_INFO,
}

extension PlatformMethodExtension on PlatformMethod {
  String get method {
    switch(this) {
      case PlatformMethod.GET_IMAGE_FOLDER:
        return '${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FOLDER';
      case PlatformMethod.GET_IMAGE_FOLDER_COUNT:
        return '${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FOLDER_COUNT';
      case PlatformMethod.GET_IMAGE_FILES:
        return '${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FILES';
      case PlatformMethod.GET_IMAGE_THUMBNAIL:
        return '${PluginConfig.CHANNEL_NAME}/GET_IMAGE_THUMBNAIL';
      case PlatformMethod.READ_IMAGE_DATA:
        return '${PluginConfig.CHANNEL_NAME}/READ_IMAGE_DATA';
      case PlatformMethod.CHECK_UPDATE:
        return '${PluginConfig.CHANNEL_NAME}/CHECK_UPDATE';
      case PlatformMethod.GET_IMAGE_INFO:
        return '${PluginConfig.CHANNEL_NAME}/GET_IMAGE_INFO';
    }
  }
}