package com.zpdl_studio.zpdl_studio_media_plugin.media_query

import android.Manifest
import android.content.ContentUris
import android.content.Context
import android.database.ContentObserver
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import com.zpdl_studio.zpdl_studio_media_plugin.PluginPermission
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginDataSet
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginFolder
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginImage
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginSortOrder
import io.reactivex.Observable
import io.reactivex.schedulers.Schedulers

abstract class PluginImageQuery {

    protected var context: Context? = null
    private var contentObserver: ContentObserver? = null
    private var modifyTimeMs: Long = 0L

    private val permissions = mutableListOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE)

    open fun init(context: Context) {
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

    fun getImageFolder(pluginPermission: PluginPermission, sortOrder: PluginSortOrder = PluginSortOrder.DATE_DESC): Observable<PluginDataSet<PluginFolder>> =
            pluginPermission.requestPermissionsObservable(permissions).flatMap {
                if (it) {
                    Observable.fromCallable {
                        PluginDataSet(list = getImageFolder(sortOrder))
                    }.subscribeOn(Schedulers.io())
                } else {
                    Observable.just(PluginDataSet(list = mutableListOf()))
                }
            }

    fun getImages(pluginPermission: PluginPermission, bucketId: String?, sortOrder: PluginSortOrder = PluginSortOrder.DATE_DESC, limit: Int? = null): Observable<PluginDataSet<PluginImage>> =
            if (!pluginPermission.checkSelfPermission(permissions)) {
                Observable.just(PluginDataSet(permission = false, list = mutableListOf()))
            } else {
                Observable.fromCallable {
                    getImages(bucketId, sortOrder, limit)
                }
            }

    fun checkUpdate(timeMs: Long?) =
            timeMs?.let {
                it < modifyTimeMs
            } ?: true

    fun getImageReadBytes(id: Long): ByteArray? {
        this.context?.contentResolver?.openInputStream(ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id))?.use {
            return it.readBytes()
        }

        return null
    }

    abstract fun getImageFolderCount(bucketId: String?): Int

    abstract fun getImageFolder(sortOrder: PluginSortOrder): MutableList<PluginFolder>

    abstract fun getImages(bucketId: String?, sortOrder: PluginSortOrder, limit: Int? = null): PluginDataSet<PluginImage>

    abstract fun getImageThumbnail(id: Long, width: Int, height: Int): Bitmap?
}
