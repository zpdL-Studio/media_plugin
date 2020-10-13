package com.zpdl_studio.zpdl_studio_media_plugin.data

data class PluginFolder(
    val id: String,
    val displayName: String,
    val count: Int,
    val modifyTimeMs: Long
) : PluginToMap {
    override fun pluginToMap(): Map<String, *> = hashMapOf(
            "id" to id,
            "displayName" to displayName,
            "count" to count,
            "modifyTimeMs" to modifyTimeMs,
    )
}