package `in`.foore.mobile

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.branch.referral.Branch
import io.branch.referral.BranchError

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }

  override fun onStart() {
    super.onStart()

    // Branch init
    Branch.getInstance().initSession(object : BranchReferralInitListener {
      override fun onInitFinished(referringParams: JSONObject, error: BranchError?) {
        if (error == null) {
          Log.e("BRANCH SDK", referringParams.toString())
          // Retrieve deeplink keys from 'referringParams' and evaluate the values to determine where to route the user
          // Check '+clicked_branch_link' before deciding whether to use your Branch routing logic
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

