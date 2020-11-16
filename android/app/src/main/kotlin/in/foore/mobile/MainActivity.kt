package `in`.foore.mobile

import android.os.Bundle


import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.content.Intent
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import org.json.JSONObject
import android.util.Log

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        setAnnoyingNotificationChannel()
    }

    override fun onStart() {
        super.onStart()
    }

    fun setAnnoyingNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channelId: String =  applicationContext.getString(R.string.annoying_channel_id)
            val channelName: String = applicationContext.getString(R.string.annoying_channel_name)
            val channelDescription: String = applicationContext.getString(R.string.annoying_channel_description)

            val soundUri: Uri = Uri.parse(
                    "android.resource://" +
                            applicationContext.packageName +
                            "/" +
                            R.raw.annoying_sound_1)

            val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()

            val channel = NotificationChannel(channelId,
                    channelName,
                    NotificationManager.IMPORTANCE_HIGH)
            channel.setSound(soundUri, audioAttributes)
            channel.description = channelDescription

            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                    .createNotificationChannel(channel)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        this.intent = intent
    }
}

