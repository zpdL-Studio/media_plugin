package com.zpdl_studio.zpdl_studio_media_plugin

import android.content.pm.PackageManager
import android.graphics.Bitmap
import androidx.annotation.NonNull
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginBitmap
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginImageFile
import com.zpdl_studio.zpdl_studio_media_plugin.data.PluginSortOrder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

/** ZpdlStudioMediaPlugin */
class ZpdlStudioMediaPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activityPluginBinding: ActivityPluginBinding? = null
  private var pluginPermission = PluginPermission(
          { permission ->
            activityPluginBinding?.activity?.let {
              it.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
            } ?: false
          },
          { requestCode, permissions ->
            activityPluginBinding?.activity?.let {
              it.requestPermissions(permissions, requestCode)
              true
            } ?: false
          }
  )
  private val pluginMediaQuery = PluginImageQuery()

  private val requestPermissionsResultListener = PluginRegistry.RequestPermissionsResultListener { requestCode, permissions, grantResults ->
    return@RequestPermissionsResultListener pluginPermission.onRequestPermissionsResult(requestCode, permissions, grantResults)
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, PluginConfig.CHANNEL_NAME)
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(PlatformMethod.from(call.method)) {
      PlatformMethod.GET_IMAGE_FOLDER -> {
        pluginMediaQuery.getImageFolder(pluginPermission)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                  result.success(it.toMap())
                }, {
                  result.success(null)
                })
      }
      PlatformMethod.GET_IMAGE_FILES -> {
        Observable.fromCallable {
          val map: HashMap<*, *> = call.arguments as? HashMap<*, *> ?: HashMap<Any, Any>()

          pluginMediaQuery.getImageFileFromFolder(
                  map.getString("id"),
                  PluginSortOrder.from(map.getString("sortOrder")) ?: PluginSortOrder.DATE_DESC,
                  map.getInt("limit"),
          )
        }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                  val list = mutableListOf<Map<String, *>>()
                  for(pluginImageFile in it) {
                    list.add(pluginImageFile.toMap())
                  }
                  result.success(list)
                }, {
                  result.success(null)
                })
      }
      PlatformMethod.GET_IMAGE_THUMBNAIL -> {
        Observable.fromCallable<Bitmap> {
          val map: HashMap<*, *> = call.arguments as? HashMap<*, *> ?: HashMap<Any, Any>()

          map.getLong("id")?.let {
            pluginMediaQuery.getImageThumbnail(
                    it,
                    width = (map.getInt("width")) ?: 512,
                    height = (map.getInt("height")) ?: 512
            )
          }
        }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                  result.success(PluginBitmap.createARGB(it).toMap())
                }, {
                  result.success(null)
                })
      }
      PlatformMethod.CHECK_UPDATE -> {
        var timeMs: Long? = null
        if(call.arguments is Int) {
          timeMs = (call.arguments as Int).toLong()
        } else if(call.arguments is Long) {
          timeMs = call.arguments as Long
        }
        result.success(pluginMediaQuery.checkUpdate(timeMs))
      }
      null -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    activityPluginBinding?.removeRequestPermissionsResultListener(requestPermissionsResultListener)
    activityPluginBinding = null
    pluginPermission.close()
    pluginMediaQuery.close()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
    activityPluginBinding?.addRequestPermissionsResultListener(requestPermissionsResultListener)
    activityPluginBinding?.activity?.let {
      pluginMediaQuery.init(it)
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
    activityPluginBinding?.addRequestPermissionsResultListener(requestPermissionsResultListener)
    activityPluginBinding?.activity?.let {
      pluginMediaQuery.init(it)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityPluginBinding?.removeRequestPermissionsResultListener(requestPermissionsResultListener)
    activityPluginBinding = null
    pluginPermission.close()
    pluginMediaQuery.close()
  }
}

fun HashMap<*, *>?.getInt(key: Any): Int? {
  if(this == null) return null
  this[key]?.let {
    if(it is Number) {
      return it.toInt()
    }
  }
  return null
}

fun HashMap<*, *>?.getLong(key: Any): Long? {
  if(this == null) return null
  this[key]?.let {
    if(it is Number) {
      return it.toLong()
    }
  }
  return null
}

fun HashMap<*, *>?.getString(key: Any): String? {
  if(this == null) return null
  this[key]?.let {
    return if(it is String) {
      it
    } else {
      it.toString()
    }
  }
  return null
}


