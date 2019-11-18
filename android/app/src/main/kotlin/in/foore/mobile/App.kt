package `in`.foore.mobile

import io.flutter.app.FlutterApplication
import android.content.Context
import androidx.multidex.MultiDex

import io.branch.referral.Branch


class App : FlutterApplication() {

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun onCreate() {
        super.onCreate()

        // Branch logging for debugging
        Branch.enableDebugMode()

        // Branch object initialization
        Branch.getAutoInstance(this)
    }

}