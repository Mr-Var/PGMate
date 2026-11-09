package com.pgmate.pg_manager

import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FlutterFragmentActivity is required by local_auth for the biometric prompt.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pgmate/whatsapp").setMethodCallHandler { call, result ->
            if (call.method != "shareFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            val phone = call.argument<String>("phone")
            if (path == null || phone == null) {
                result.success(false)
                return@setMethodCallHandler
            }
            val uri = FileProvider.getUriForFile(this, "$packageName.files", File(path))
            // Opens the tenant's own chat with the file attached; the owner taps Send.
            for (pkg in listOf("com.whatsapp", "com.whatsapp.w4b")) {
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = call.argument<String>("mime") ?: "application/pdf"
                    setPackage(pkg)
                    putExtra(Intent.EXTRA_STREAM, uri)
                    putExtra(Intent.EXTRA_TEXT, call.argument<String>("text") ?: "")
                    putExtra("jid", "$phone@s.whatsapp.net")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                try {
                    startActivity(intent)
                    result.success(true)
                    return@setMethodCallHandler
                } catch (e: ActivityNotFoundException) {
                    // Try the next WhatsApp variant.
                }
            }
            result.success(false)
        }
    }
}
