package com.zpdl_studio.zpdl_studio_media_plugin.data

data class PluginImage(
        val id: Long,
        val fullPath: String,
        val displayName: String,
        val mimeType: String,
        val width: Int,
        val height: Int,
        val modifyTimeMs: Long
) : PluginToMap {
    override fun pluginToMap(): Map<String, *> = hashMapOf(
            "id" to id,
            "width" to width,
            "height" to height,
            "modifyTimeMs" to modifyTimeMs,
            "info" to hashMapOf(
                    "fullPath" to fullPath,
                    "displayName" to displayName,
                    "mimeType" to mimeType
            )
    )
}