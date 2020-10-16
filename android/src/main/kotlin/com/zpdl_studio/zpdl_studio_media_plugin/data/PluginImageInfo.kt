package com.zpdl_studio.zpdl_studio_media_plugin.data

data class PluginImageInfo(
        val id: Long,
        val path: String,
        val displayName: String,
        val mimeType: String,
        val orientation: Int,
        val width: Int,
        val height: Int,
        val modifyTimeMs: Long
) : PluginToMap {
    override fun pluginToMap(): Map<String, *> = hashMapOf(
            "id" to id,
            "path" to path,
            "displayName" to displayName,
            "mimeType" to mimeType,
            "orientation" to orientation,
            "width" to width,
            "height" to height,
            "modifyTimeMs" to modifyTimeMs,
    )
}