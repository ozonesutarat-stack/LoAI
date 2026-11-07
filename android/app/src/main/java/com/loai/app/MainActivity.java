package com.loai.app;

import android.os.Bundle;

import androidx.annotation.NonNull;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint;
import com.facebook.react.defaults.DefaultReactActivityDelegate;

import expo.modules.ReactActivityProxy;

public class MainActivity extends ReactActivity {

  /**
   * Returns the name of the main component registered from JavaScript.
   * This is used to schedule rendering of the component.
   */
  @Override
  protected String getMainComponentName() {
    return "loai";
  }

  /**
   * Returns the instance of the {@link ReactActivityDelegate}. There the root
   * view is created and you can manage the life-cycle of your React Application.
   * @return the ReactActivityDelegate instance, if you override this method you must call
   *         the super method to have the correct behavior on the new architecture.
   */
  @Override
  protected ReactActivityDelegate createReactActivityDelegate() {
    return new ReactActivityProxy(this, 
      new DefaultReactActivityDelegate(
        this,
        getMainComponentName(),
        // If you opt-in for the New Architecture, we enable the Fabric Renderer.
        DefaultNewArchitectureEntryPoint.getFabricEnabled(),
        // If you opt-in for the New Architecture, we enable Concurrent React (aka React 18).
        DefaultNewArchitectureEntryPoint.getConcurrentReactEnabled()
      )
    );
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    // Set the theme to AppTheme before creating the activity
    setTheme(R.style.AppTheme);
    super.onCreate(null);
  }
}
