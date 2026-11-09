package dev.leanflutter.plugins.protocol_handler;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;

import dev.libnativeapi.nativeapi.ProtocolHandlerBridge;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Forwards ACTION_VIEW intents to nativeapi's ProtocolHandler: the intent that
 * started the activity as the launch URL, later ones from onNewIntent as
 * received URLs. The Dart API is protocol_handler's ProtocolHandler.
 */
public class ProtocolHandlerPlugin
    implements FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
  private ActivityPluginBinding activityBinding;
  // The launch intent survives activity recreation; deliver it once.
  private static Intent deliveredLaunchIntent;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    ProtocolHandlerBridge.attach(binding.getApplicationContext());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    attachActivity(binding);
    Activity activity = binding.getActivity();
    Intent intent = activity.getIntent();
    // Reopening the app from Recents replays the original VIEW intent.
    boolean fromHistory =
        intent != null && (intent.getFlags() & Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0;
    if (intent != null && intent != deliveredLaunchIntent && !fromHistory) {
      deliveredLaunchIntent = intent;
      deliver(intent, true);
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    detachActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    attachActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    detachActivity();
  }

  @Override
  public boolean onNewIntent(@NonNull Intent intent) {
    deliver(intent, false);
    // Let other listeners see the intent too.
    return false;
  }

  private void attachActivity(ActivityPluginBinding binding) {
    activityBinding = binding;
    binding.addOnNewIntentListener(this);
  }

  private void detachActivity() {
    if (activityBinding != null) {
      activityBinding.removeOnNewIntentListener(this);
      activityBinding = null;
    }
  }

  private static void deliver(Intent intent, boolean isLaunch) {
    if (Intent.ACTION_VIEW.equals(intent.getAction())) {
      ProtocolHandlerBridge.deliver(intent.getDataString(), isLaunch);
    }
  }
}
