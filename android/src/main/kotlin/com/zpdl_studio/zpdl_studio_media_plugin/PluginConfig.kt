package com.zpdl_studio.zpdl_studio_media_plugin

class PluginConfig {
  companion object {
    const val CHANNEL_NAME = "zpdl_studio_media_plugin"
  }
}

enum class PlatformMethod(val method: String) {
  GET_IMAGE_FOLDER("${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FOLDER"),
  GET_IMAGE_FOLDER_COUNT("${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FOLDER_COUNT"),
  GET_IMAGE_FILES("${PluginConfig.CHANNEL_NAME}/GET_IMAGE_FILES"),
  GET_IMAGE_THUMBNAIL("${PluginConfig.CHANNEL_NAME}/GET_IMAGE_THUMBNAIL"),
  READ_IMAGE_DATA("${PluginConfig.CHANNEL_NAME}/READ_IMAGE_DATA"),
  CHECK_UPDATE("${PluginConfig.CHANNEL_NAME}/CHECK_UPDATE")
  ;

  companion object {
    fun from(method: String): PlatformMethod? {
      for(value in values()) {
        if(value.method == method) {
          return value
        }
      }
      return null
    }
  }
}
