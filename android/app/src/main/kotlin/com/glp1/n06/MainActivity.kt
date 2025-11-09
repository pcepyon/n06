package com.glp1.n06

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

/**
 * MainActivity for Kakao OAuth.
 *
 * Changed from FlutterFragmentActivity to FlutterActivity
 * to resolve Intent handling issues with Kakao SDK.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "🔍 [HEALTH CHECK] onCreate called")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d(TAG, "🔍 [HEALTH CHECK] onNewIntent called with URI: ${intent.data}")

        // Set the intent so it's available for the engine
        setIntent(intent)
    }
}