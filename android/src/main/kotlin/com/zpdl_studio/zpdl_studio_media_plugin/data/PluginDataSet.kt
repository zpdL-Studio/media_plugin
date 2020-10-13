package com.zpdl_studio.zpdl_studio_media_plugin.data

data class PluginDataSet<T: PluginToMap>(
    val timeMs: Long = System.currentTimeMillis(),
    val permission: Boolean = true,
    val list: MutableList<T>
) : PluginToMap {
    override fun pluginToMap(): Map<String, *> {
        val list = mutableListOf<Map<String, *>>()
        for(data in this.list) {
            list.add(data.pluginToMap())
        }
        return hashMapOf(
                "timeMs" to timeMs,
                "permission" to permission,
                "list" to list
        )
    }
}

