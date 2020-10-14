package com.zpdl_studio.zpdl_studio_media_plugin.media_query

import android.annotation.TargetApi
import android.content.ContentResolver
import android.content.ContentUris
import android.graphics.Bitmap
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.util.Size
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginDataSet
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginFolder
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginImage
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginSortOrder

@TargetApi(Build.VERSION_CODES.Q)
class PluginImageQueryQ: PluginImageQuery() {

    override fun getImageFolder(sortOrder: PluginSortOrder): MutableList<PluginFolder> {
        val folderSet = mutableSetOf<String>()
        val results = mutableListOf<PluginFolder>()

        val cursor = context?.contentResolver?.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                arrayOf(
                        MediaStore.Images.Media.BUCKET_ID,
                        MediaStore.Images.Media.BUCKET_DISPLAY_NAME
                ),
                Bundle().apply {
                      putStringArray(
                            ContentResolver.QUERY_ARG_SORT_COLUMNS,
                            arrayOf(MediaStore.Images.Media.DATE_MODIFIED)
                    )
                    when(sortOrder) {
                        PluginSortOrder.DATE_DESC -> {
                            putInt(
                                    ContentResolver.QUERY_ARG_SORT_DIRECTION,
                                    ContentResolver.QUERY_SORT_DIRECTION_DESCENDING
                            )
                        }
                        PluginSortOrder.DATE_ARC -> {
                            putInt(
                                    ContentResolver.QUERY_ARG_SORT_DIRECTION,
                                    ContentResolver.QUERY_SORT_DIRECTION_ASCENDING
                            )
                        }
                    }
                },
                null
        )

        cursor?.let { _cursor ->
            val columnIndexBucketId = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_ID)
            val columnIndexBucketDisplayName = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)

            while (_cursor.moveToNext()) {
                val bucketId = cursor.getString(columnIndexBucketId)
                if(!folderSet.contains(bucketId)) {
                    folderSet.add(bucketId)
                    results.add(PluginFolder(
                            id = bucketId,
                            displayName = cursor.getString(columnIndexBucketDisplayName),
                            count = getImageFolderCount(bucketId),
                            modifyTimeMs = 0
                    ))
                }
            }
        }
        cursor?.close()

        return results
    }

    override fun getImages(bucketId: String?, sortOrder: PluginSortOrder, limit: Int?): PluginDataSet<PluginImage> {
        val cursor = context?.contentResolver?.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                arrayOf(
                        MediaStore.Images.Media._ID,
                        MediaStore.Images.Media.DISPLAY_NAME,
                        MediaStore.Images.Media.ORIENTATION,
                        MediaStore.Images.Media.WIDTH,
                        MediaStore.Images.Media.HEIGHT,
                        MediaStore.Images.Media.DATE_MODIFIED
                ),
                Bundle().apply {
                    if (bucketId != null && bucketId.isNotEmpty()) {
                        putString(ContentResolver.QUERY_ARG_SQL_SELECTION, "${MediaStore.Video.Media.BUCKET_ID}=?")
                        putStringArray(
                                ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS,
                                arrayOf(bucketId)
                        )
                    }
                    limit?.let {
                        putInt(ContentResolver.QUERY_ARG_LIMIT, it)
                    }
                    putStringArray(
                            ContentResolver.QUERY_ARG_SORT_COLUMNS,
                            arrayOf(MediaStore.Images.Media.DATE_MODIFIED)
                    )
                    when(sortOrder) {
                        PluginSortOrder.DATE_DESC -> {
                            putInt(
                                    ContentResolver.QUERY_ARG_SORT_DIRECTION,
                                    ContentResolver.QUERY_SORT_DIRECTION_DESCENDING
                            )
                        }
                        PluginSortOrder.DATE_ARC -> {
                            putInt(
                                    ContentResolver.QUERY_ARG_SORT_DIRECTION,
                                    ContentResolver.QUERY_SORT_DIRECTION_ASCENDING
                            )
                        }
                    }
                },
                null
        )

        val results = mutableListOf<PluginImage>()
        cursor?.let { _cursor ->
            val columnIndexID = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val columnIndexName = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val columnIndexOrientation = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.ORIENTATION)
            val columnIndexWidth = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.WIDTH)
            val columnIndexHeight = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.HEIGHT)
            val columnIndexDateModified = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_MODIFIED)

            while (_cursor.moveToNext()) {
                results.add(PluginImage(
                        id = cursor.getLong(columnIndexID),
                        displayName = cursor.getString(columnIndexName) ?: "",
                        orientation = cursor.getInt(columnIndexOrientation),
                        width = cursor.getInt(columnIndexWidth),
                        height = cursor.getInt(columnIndexHeight),
                        modifyTimeMs = cursor.getLong(columnIndexDateModified) * 1000
                ))
            }
        }
        cursor?.close()
        return PluginDataSet(list = results)
    }

    override fun getImageFolderCount(bucketId: String?): Int = try {
        val cursor = context?.contentResolver?.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                null,
                Bundle().apply {
                    if (bucketId != null && bucketId.isNotEmpty()) {
                        putString(ContentResolver.QUERY_ARG_SQL_SELECTION, "${MediaStore.Video.Media.BUCKET_ID}=?")
                        putStringArray(
                                ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS,
                                arrayOf(bucketId)
                        )
                    }
                },
                null)
        val count: Int = cursor?.count ?: 0
        cursor?.close()
        count
    } catch (e: Exception) {
        0
    }

    override fun getImageThumbnail(id: Long, width: Int, height: Int): Bitmap? =
        this.context?.contentResolver?.loadThumbnail(
                ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id),
                Size(width, height),
                null
        )
}
