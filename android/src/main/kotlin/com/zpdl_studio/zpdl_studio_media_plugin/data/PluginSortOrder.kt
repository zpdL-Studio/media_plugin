package com.zpdl_studio.zpdl_studio_media_plugin.data

enum class PluginSortOrder(private val sortOrder: String) {
    DATE_DESC("DATE DESC"),
    DATE_ARC("DATE ASC"),
    ;

    companion object {
        fun from(sortOrder: String?): PluginSortOrder? {
            sortOrder?.let {
                for(value in values()) {
                    if(value.sortOrder == it) {
                        return value
                    }
                }
            }
            return null
        }
    }
}