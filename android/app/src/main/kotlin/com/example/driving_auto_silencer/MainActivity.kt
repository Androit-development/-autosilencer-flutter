package com.example.driving_auto_silencer

import android.app.NotificationManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {

    private val AUDIO_CHANNEL = "autosilencer/audio"
    private val DEVICE_ADMIN_CHANNEL = "autosilencer/device_admin"
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, AutoSilencerDeviceAdminReceiver::class.java)

        // Audio/Silent Mode Channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSilentMode" -> {
                    val silent = call.argument<Boolean>("silent") ?: false
                    setSilentMode(silent)
                    result.success(null)
                }
                "hasDndAccess" -> {
                    val nm = getSystemService(Context.NOTIFICATION_SERVICE)
                            as NotificationManager
                    result.success(nm.isNotificationPolicyAccessGranted)
                }
                "openDndSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(null)
                }
                "setDriverSilentMode" -> {
                    val silent = call.argument<Boolean>("silent") ?: false
                    setSilentMode(silent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Device Admin Channel for app freezing
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_ADMIN_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeviceAdminEnabled" -> {
                    result.success(isDeviceAdminEnabled())
                }
                "requestDeviceAdminAccess" -> {
                    requestDeviceAdminAccess()
                    result.success(null)
                }
                "freezeApps" -> {
                    val apps = call.argument<List<String>>("apps") ?: emptyList()
                    freezeApps(apps)
                    result.success(null)
                }
                "unfreezeAllApps" -> {
                    unfreezeAllApps()
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
            Log.e("MainActivity", "Error setting silent mode: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun isDeviceAdminEnabled(): Boolean {
        return devicePolicyManager.isAdminActive(adminComponent)
    }

    private fun requestDeviceAdminAccess() {
        try {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
            intent.putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "AutoSilencer needs device admin access to freeze apps during driving mode"
            )
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("MainActivity", "Error requesting device admin: ${e.message}")
        }
    }

    private fun freezeApps(apps: List<String>) {
        try {
            if (!isDeviceAdminEnabled()) {
                Log.w("MainActivity", "Device admin not enabled, requesting access")
                requestDeviceAdminAccess()
                return
            }

            Log.d("MainActivity", "Freezing apps: $apps")
            for (app in apps) {
                try {
                    // Note: App hiding/unfreezing is limited by Android's Device Admin API
                    // For full freezing, we would need Device Owner or System app permissions
                    // This is a placeholder for future implementation
                    Log.d("MainActivity", "Attempted to freeze: $app")
                } catch (e: Exception) {
                    Log.e("MainActivity", "Failed to freeze $app: ${e.message}")
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error in freezeApps: ${e.message}")
        }
    }

    private fun unfreezeAllApps() {
        try {
            if (!isDeviceAdminEnabled()) {
                Log.w("MainActivity", "Device admin not enabled")
                return
            }

            Log.d("MainActivity", "Unfreezing all apps")
            // Placeholder for app unfreezing logic
        } catch (e: Exception) {
            Log.e("MainActivity", "Error in unfreezeAllApps: ${e.message}")
        }
    }
}