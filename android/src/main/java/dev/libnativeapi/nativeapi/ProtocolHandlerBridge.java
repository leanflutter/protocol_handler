package dev.libnativeapi.nativeapi;

import android.content.Context;
import android.util.Log;

/**
 * Hands deep links to the nativeapi core library (libcnativeapi.so).
 *
 * <p>The class name and the native method signatures are a contract with
 * core/src/platform/android/protocol_handler_android.cpp; do not rename them.
 */
public final class ProtocolHandlerBridge {
  private static final String TAG = "nativeapi";
  private static boolean attached;

  private ProtocolHandlerBridge() {}

  /** Loads the core library and lets it read package information through {@code context}. */
  public static synchronized boolean attach(Context context) {
    if (attached) {
      return true;
    }
    try {
      System.loadLibrary("cnativeapi");
      nativeAttach(context.getApplicationContext());
      attached = true;
    } catch (UnsatisfiedLinkError error) {
      Log.w(TAG, "nativeapi core library unavailable; deep links are not delivered", error);
    }
    return attached;
  }

  /** Delivers one URL; {@code isLaunch} marks the URL that started the app. */
  public static synchronized void deliver(String url, boolean isLaunch) {
    if (attached && url != null && !url.isEmpty()) {
      nativeDeliver(url, isLaunch);
    }
  }

  private static native void nativeAttach(Context context);

  private static native void nativeDeliver(String url, boolean isLaunch);
}
