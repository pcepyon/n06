package com.glp1.n06

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Don't pass Kakao OAuth callback to Flutter router
        // Let Kakao SDK handle it internally
        val uri = intent.data
        if (uri != null && uri.scheme?.startsWith("kakao") == true) {
            // Just set the intent for Kakao SDK to process
            setIntent(intent)
            return
        }

        setIntent(intent)
    }
}
