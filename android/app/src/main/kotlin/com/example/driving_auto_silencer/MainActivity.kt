package com.example.driving_auto_silencer

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "autosilencer/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // Enable or disable silent mode
                "setSilentMode" -> {
                    val silent = call.argument<Boolean>("silent") ?: false
                    setSilentMode(silent)
                    result.success(null)
                }

                // Check if we have Do Not Disturb access
                "hasDndAccess" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE)
                            as NotificationManager
                    result.success(nm.isNotificationPolicyAccessGranted)
                }

                // Open DND settings page
                "openDndSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(null)
                }

                // Driver mode: silence all except whitelisted apps
                // (simplified — uses same silent mode for now)
                "setDriverSilentMode" -> {
                    val silent = call.argument<Boolean>("silent") ?: false
                    setSilentMode(silent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setSilentMode(silent: Boolean) {
        try {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE)
                    as NotificationManager
            val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager

            if (silent) {
                // Use DND if we have access, otherwise just silent mode
                if (nm.isNotificationPolicyAccessGranted) {
                    nm.setInterruptionFilter(
                        NotificationManager.INTERRUPTION_FILTER_NONE)
                } else {
                    audio.ringerMode = AudioManager.RINGER_MODE_SILENT
                }
            } else {
                // Restore
                if (nm.isNotificationPolicyAccessGranted) {
                    nm.setInterruptionFilter(
                        NotificationManager.INTERRUPTION_FILTER_ALL)
                }
                audio.ringerMode = AudioManager.RINGER_MODE_NORMAL
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}