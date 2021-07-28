package com.app.flutter_app;

import android.content.SharedPreferences;

import com.almoullim.background_location.BackgroundLocationPlugin;
import com.github.cloudwebrtc.flutter_callkeep.FlutterCallkeepPlugin;

import io.agora.agora_rtc_engine.AgoraRtcChannelPlugin;
import io.agora.agora_rtc_engine.AgoraRtcEnginePlugin;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();

        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }


    @Override
    public void registerWith(PluginRegistry registry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);

        FlutterCallkeepPlugin.registerWith(registry.registrarFor("FlutterCallKeep.Method"));
        FlutterCallkeepPlugin.registerWith(registry.registrarFor("FlutterCallKeep.Event"));

        SharedPreferencesPlugin.registerWith(
                registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));

        AgoraRtcEnginePlugin.registerWith(registry.registrarFor("agora_rtc_engine"));
        PathProviderPlugin.registerWith(registry.registrarFor("plugins.flutter.io/path_provider"));


        BackgroundLocationPlugin.registerWith(registry.registrarFor("almoullim.com/background_location"));
        FlutterCallkeepPlugin.registerWith(registry.registrarFor("com.github.cloudwebrtc.flutter_callkeep"));
//        SharedPreferencesPlugin.registerWith(registry.registrarFor("plugins.flutter.io/shared_preferences"));
//        CallKeepPlugin.registerWith(registry.registrarFor("co.doneservices/callkeep"));
    }


}

