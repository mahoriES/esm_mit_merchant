package `in`.foore.mobile

import android.os.Bundle

import android.content.Intent
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.branch.referral.Branch
import io.branch.referral.BranchError

import org.json.JSONObject
import android.util.Log

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }

  override fun onStart() {
    super.onStart()

    // Branch init
    Branch.getInstance().initSession(object : Branch.BranchReferralInitListener {
      override fun onInitFinished(referringParams: JSONObject, error: BranchError?) {
        if (error == null) {
          Log.e("BRANCH SDK", referringParams.toString())
        } else {
          Log.e("BRANCH SDK", error.message)
        }
      }
    }, this.intent.data, this)
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    this.intent = intent
  }
}

