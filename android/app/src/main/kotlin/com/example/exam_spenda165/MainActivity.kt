package com.example.exam_spenda165

import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Bundle
import android.provider.Settings
import android.view.KeyEvent
import android.view.WindowManager
import android.widget.Toast
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.exam_spenda165/alarm"
    private val CAMERA_PERMISSION_CODE = 101
    private var isKioskModeEnabled = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Prevent screenshot & recent preview
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        checkCameraPermission()
    }

    private fun checkCameraPermission() {
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA)
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.CAMERA),
                CAMERA_PERMISSION_CODE
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "triggerAlarm" -> {
                        triggerAlarm()
                        result.success(null)
                    }
                    "isOverlayEnabled" -> result.success(isOverlayEnabled())
                    "startKioskMode" -> {
                        startLockTask()
                        isKioskModeEnabled = true
                        result.success(null)
                    }
                    "stopKioskMode" -> {
                        stopLockTask()
                        isKioskModeEnabled = false
                        result.success(null)
                    }
                    "isInternetConnected" -> result.success(isInternetConnected())
                    else -> result.notImplemented()
                }
            }
    }

    // ❗ BACK DITANGANI DI SINI SAJA — Flutter tidak akan menerima event BACK
    override fun onBackPressed() {
        triggerAlarm()
        // jangan panggil super → supaya Flutter tidak pop halaman
    }

    // ❗ Tombol lain tetap dianggap pelanggaran
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (
            keyCode == KeyEvent.KEYCODE_HOME ||
            keyCode == KeyEvent.KEYCODE_APP_SWITCH ||
            keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
            keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
            keyCode == KeyEvent.KEYCODE_POWER
        ) {
            triggerAlarm()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onPause() {
        super.onPause()
        if (isKioskModeEnabled) finishAffinity()
    }

    override fun onStop() {
        super.onStop()
        if (isKioskModeEnabled) finishAffinity()
    }

    private fun triggerAlarm() {
        Toast.makeText(this, "Pelanggaran terdeteksi!", Toast.LENGTH_SHORT).show()
    }

    private fun isOverlayEnabled(): Boolean {
        return Settings.canDrawOverlays(this)
    }

    private fun isInternetConnected(): Boolean {
        val connectivityManager =
            getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork ?: return false
        val caps = connectivityManager.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }
}
