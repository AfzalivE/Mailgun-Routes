package com.afzaln.mailgun_routes;

import android.os.Bundle;
import com.crashlytics.android.Crashlytics;
import io.fabric.sdk.android.Fabric;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Fabric.with(this, new Crashlytics());
    GeneratedPluginRegistrant.registerWith(this);

    AppCenter.start(getApplication(), "0100a0b9-c717-4b24-a7ca-f5e076fd4516",
                    Analytics.class, Crashes.class);
  }
}
