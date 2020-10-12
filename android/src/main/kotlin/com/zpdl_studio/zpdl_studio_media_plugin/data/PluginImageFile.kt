package com.zpdl_studio.zpdl_studio_media_plugin.data

data class PluginImageFile(
        val id: Long,
        val displayName: String,
        val orientation: Int,
        val width: Int,
        val height: Int,
        val modifyTimeMs: Long
) : PluginToMap {
    override fun toMap(): Map<String, *> = hashMapOf(
            "id" to id,
            "displayName" to displayName,
            "orientation" to orientation,
            "width" to width,
            "height" to height,
            "modifyTimeMs" to modifyTimeMs,
    )
}