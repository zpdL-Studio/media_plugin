package com.zpdl_studio.zpdl_studio_media_plugin.data

data class PluginImageFolder(
    val id: String,
    val displayName: String,
    val count: Int,
    val modifyTimeMs: Long
) : PluginToMap {
    override fun toMap(): Map<String, *> = hashMapOf(
            "id" to id,
            "displayName" to displayName,
            "count" to count,
            "modifyTimeMs" to modifyTimeMs,
    )
}