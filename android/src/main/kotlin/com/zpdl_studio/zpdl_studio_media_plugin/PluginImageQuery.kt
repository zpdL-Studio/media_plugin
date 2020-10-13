package com.zpdl_studio.zpdl_studio_media_plugin

import android.Manifest
import android.content.ContentUris
import android.content.Context
import android.database.ContentObserver
import android.graphics.Bitmap
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Size
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginDataSet
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginImage
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginFolder
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginSortOrder
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers


/** ZpdlStudioMediaPlugin */
class PluginImageQuery {

    private var context: Context? = null
    private var contentObserver: ContentObserver? = null
    private var modifyTimeMs: Long = 0L

    private val permissions = mutableListOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE)

    fun init(context: Context) {
        this.context = context
        updateModifyTimeMs()
        contentObserver?.let {
            context.contentResolver.unregisterContentObserver(it)
        }
        contentObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean) {
                super.onChange(selfChange)
                updateModifyTimeMs()
            }
        }
        context.contentResolver.registerContentObserver(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                true,
                contentObserver!!
        )
    }

    fun close() {
        contentObserver?.let {
            this.context?.contentResolver?.unregisterContentObserver(it)
        }
        contentObserver = null
        this.context = null
    }

    fun updateModifyTimeMs() {
        modifyTimeMs = System.currentTimeMillis()
    }

    private fun sortOrderQuery(sortOrder: PluginSortOrder?, limit: Int?): String {
        val sb = StringBuilder()
        sortOrder?.let {
            sb.append(when(it) {
                PluginSortOrder.DATE_DESC -> "${MediaStore.MediaColumns.DATE_MODIFIED} DESC"
                PluginSortOrder.DATE_ARC -> "${MediaStore.MediaColumns.DATE_MODIFIED} ASC"
            })
        }

        limit?.let {
            if(sb.isNotEmpty()) {
                sb.append(" ")
            }
            sb.append("LIMIT $it")
        }

        return sb.toString()
    }

    fun getImageFolderCount(bucketId: String?): Int = context?.let {
        getImageFolderCount(it, bucketId)
    } ?: 0

    private fun getImageFolderCount(context: Context, bucketId: String?): Int =
            try {
                if(bucketId != null && bucketId.isNotEmpty()) {
                    val cursor = context.contentResolver.query(
                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                            null,
                            MediaStore.Video.Media.BUCKET_ID + "=?",
                            arrayOf(bucketId),
                            null)
                    val count: Int = cursor?.count ?: 0
                    cursor?.close()
                    count
                } else {
                    val cursor = context.contentResolver.query(
                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                            null,
                            null,
                            null,
                            null)
                    val count: Int = cursor?.count ?: 0
                    cursor?.close()
                    count
                }
            } catch (e: Exception) {
                0
            }

    fun getImageFolder(pluginPermission: PluginPermission): Observable<PluginDataSet<PluginFolder>> =
            pluginPermission.requestPermissionsObservable(permissions).flatMap {
                if (it) {
                    Observable.fromCallable {
                        PluginDataSet(list = getImageFolder())
                    }.subscribeOn(Schedulers.io())
                } else {
                    Observable.just(PluginDataSet(list = mutableListOf()))
                }
            }

    private fun getImageFolder(): MutableList<PluginFolder> {
        val results: HashMap<String, PluginFolder> = HashMap()
        context?.let { context ->
            val cursor = context.contentResolver.query(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    arrayOf(
                            MediaStore.Images.Media.BUCKET_ID,
                            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                            MediaStore.Images.Media.DATE_MODIFIED
                    ),
                    null,
                    null,
                    MediaStore.MediaColumns.DATE_MODIFIED + " DESC")

            cursor?.let { _cursor ->
                val columnIndexBucketId = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_ID)
                val columnIndexBucketDisplayName = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
                val columnIndexDateModified = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_MODIFIED)

                while (_cursor.moveToNext()) {
                    val bucketId = cursor.getString(columnIndexBucketId)
                    if(!results.contains(bucketId)) {
                        results[bucketId] = PluginFolder(
                                id = bucketId,
                                displayName = cursor.getString(columnIndexBucketDisplayName),
                                count = getImageFolderCount(context, bucketId),
                                modifyTimeMs = cursor.getLong(columnIndexDateModified) * 1000
                        )
                    }
                }
            }
            cursor?.close()
        }

        return results.values.sortedByDescending { it.modifyTimeMs }.toMutableList()
    }

    private fun getImageUri(id: Long): Uri = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id)

    fun getImageThumbnail(id: Long, width: Int, height: Int): Bitmap? =
            this.context?.contentResolver?.loadThumbnail(
                    getImageUri(id),
                    Size(width, height),
                    null
            )

    fun getImages(pluginPermission: PluginPermission, bucketId: String?, sortOrder: PluginSortOrder = PluginSortOrder.DATE_DESC, limit: Int? = null): PluginDataSet<PluginImage> {
        val results = mutableListOf<PluginImage>()
        if(!pluginPermission.checkSelfPermission(permissions)) {
            return PluginDataSet(permission = false, list = results)
        }

        val id: String? = bucketId?.let { if(it.isNotEmpty()) it else null }
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
                id?.let { "${MediaStore.Video.Media.BUCKET_ID}=?" },
                id?.let { arrayOf(it) },
                sortOrderQuery(sortOrder, limit))

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

    fun checkUpdate(timeMs: Long?) =
            timeMs?.let {
                it < modifyTimeMs
            } ?: true

    fun getImageReadBytes(id: Long): ByteArray? {
        this.context?.contentResolver?.openInputStream(getImageUri(id))?.use {
            return it.readBytes()
        }

        return null
    }
}
