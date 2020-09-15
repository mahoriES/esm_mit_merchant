package `in`.foore.mobile

import android.os.Bundle

import android.content.Intent
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import org.json.JSONObject
import android.util.Log

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }

  override fun onStart() {
    super.onStart()

    
  
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    this.intent = intent
  }
}

