package com.example.jamuin

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "com.example.jamuin/app_config"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getMapsApiKey" -> {
						try {
							val appInfo = packageManager.getApplicationInfo(
								packageName,
								PackageManager.GET_META_DATA
							)
							val key = appInfo.metaData
								?.getString("com.google.android.geo.API_KEY")
								.orEmpty()
							result.success(key)
						} catch (_: Exception) {
							result.success("")
						}
					}

					else -> result.notImplemented()
				}
			}
	}
}
