package it.mondadori;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.Nullable;

import java.util.Map;
import java.util.HashMap;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.WritableMap;

import com.google.android.ump.ConsentForm;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.FormError;
import com.google.android.ump.UserMessagingPlatform;


public class RNUmpModule extends ReactContextBaseJavaModule {
    
    private final ReactApplicationContext reactContext;
    private ConsentInformation consentInformation;

    public RNUmpModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNUmp";
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();

        constants.put("CONSENT_STATUS_NOT_REQUIRED", com.google.android.ump.ConsentInformation.ConsentStatus.NOT_REQUIRED);
        constants.put("CONSENT_STATUS_OBTAINED", com.google.android.ump.ConsentInformation.ConsentStatus.OBTAINED);
        constants.put("CONSENT_STATUS_REQUIRED", com.google.android.ump.ConsentInformation.ConsentStatus.REQUIRED);
        constants.put("CONSENT_STATUS_UNKNOWN", com.google.android.ump.ConsentInformation.ConsentStatus.UNKNOWN);

        return constants;
    }

    @ReactMethod
    public void requestConsentInfoUpdate(final Promise promise) {
        try {
            ConsentRequestParameters params = new ConsentRequestParameters.Builder().build();
            // Set tag for under age of consent. Here false means users are not under age
            // params.setTagForUnderAgeOfConsent(false);
            consentInformation = UserMessagingPlatform.getConsentInformation(reactContext.getApplicationContext());
            consentInformation.requestConsentInfoUpdate(
                reactContext.getCurrentActivity(),
                params,
                new ConsentInformation.OnConsentInfoUpdateSuccessListener() {
                    @Override
                    public void onConsentInfoUpdateSuccess() {
                        int consentStatus = consentInformation.getConsentStatus();
                        boolean isConsentFormAvailable = consentInformation.isConsentFormAvailable();
                        
                        Log.d("RNUmp", "[UMP requestConsentInfoUpdate] consentStatus: " + consentStatus + " isConsentFormAvailable: " + isConsentFormAvailable);

                        WritableMap payload = Arguments.createMap();
                        payload.putInt("consentStatus", consentStatus);
                        payload.putBoolean("isConsentFormAvailable", isConsentFormAvailable);
                        
                        promise.resolve(payload);
                    }
                },
                new ConsentInformation.OnConsentInfoUpdateFailureListener() {
                    @Override
                    public void onConsentInfoUpdateFailure(FormError formError) {
                        Log.d("RNUmp", "[UMP requestConsentInfoUpdate] error: " + formError.getMessage());
                        promise.reject("" + formError.getErrorCode(), formError.getMessage());
                    }
                }
            );
        } catch (Exception e) {
            Log.d("RNUmp", "[UMP requestConsentInfoUpdate] error: " + e.getMessage());
            promise.reject(e);
        }    
    }

    @ReactMethod
    public void showConsentForm(final Promise promise) {
        try {
            final Activity activity = reactContext.getCurrentActivity();
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    UserMessagingPlatform.loadConsentForm(
                        reactContext.getApplicationContext(),
                        new UserMessagingPlatform.OnConsentFormLoadSuccessListener() {
                            @Override
                            public void onConsentFormLoadSuccess(ConsentForm consentForm) {
                                // MainActivity.this.consentForm = consentForm;
                                consentInformation = UserMessagingPlatform.getConsentInformation(reactContext.getApplicationContext());
                                consentForm.show(
                                    activity,
                                        new ConsentForm.OnConsentFormDismissedListener() {
                                            @Override
                                            public void onConsentFormDismissed(@Nullable FormError formError) {
                                                if (formError != null) {
                                                    Log.d("RNUmp", "[UMP showConsentForm] error: " + formError.getMessage());
                                                    promise.reject("" + formError.getErrorCode(), formError.getMessage());
                                                } else {
                                                    int consentStatus = consentInformation.getConsentStatus();                                                
                                                    Log.d("RNUmp", "[UMP showConsentForm] consentStatus: " + consentStatus);
                                                    promise.resolve(consentStatus);
                                                }
                                            }
                                        });

                                

                            }
                        },
                        new UserMessagingPlatform.OnConsentFormLoadFailureListener() {
                            @Override
                            public void onConsentFormLoadFailure(FormError formError) {
                                Log.d("RNUmp", "[UMP showConsentForm] error: " + formError.getMessage());
                                promise.reject("" + formError.getErrorCode(), formError.getMessage());
                            }
                        }
                    );
                }
            });
        } catch (Exception e) {
            Log.d("RNUmp", "[UMP showConsentForm] error: " + e.getMessage());
            promise.reject(e);
        }
    }

    @ReactMethod
    public void reset() {
        try {
            consentInformation = UserMessagingPlatform.getConsentInformation(reactContext.getApplicationContext());
            consentInformation.reset();
        } catch (Exception e) {
            Log.d("RNUmp", "[UMP reset] error: " + e.getMessage());
        }
    }

    @ReactMethod
    public void getTCFConsent(Promise promise) {
        try {
            SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(reactContext.getApplicationContext());
            String tcfConsent = sharedPref.getString("IABTCF_AddtlConsent", "");
            promise.resolve(tcfConsent);
        } catch(Exception e) {
            promise.reject("RNUmp getTCFConsent Error", e);
        }
    }
}
