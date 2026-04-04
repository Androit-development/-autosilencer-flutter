package com.example.driving_auto_silencer

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Must match the channel name in background_service.dart
    private val CHANNEL = "autosilencer/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Listen for method calls from Flutter
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "setSilentMode" -> {
                    val silent = call.argument<Boolean>("silent") ?: false
                    setSilentMode(silent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // Enable or disable silent mode
    private fun setSilentMode(silent: Boolean) {
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audio.ringerMode = if (silent) {
            AudioManager.RINGER_MODE_SILENT  // silent
        } else {
            AudioManager.RINGER_MODE_NORMAL  // restore
        }
    }
}