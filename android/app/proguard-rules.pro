# Keep Razorpay classes
-keep class com.razorpay.** {*;}
-keepclassmembers class com.razorpay.** {*;}

# Keep proguard annotations
-dontwarn proguard.annotation.**
-keep class proguard.annotation.** { *; }

# Keep Google Pay related classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# Keep UPI related classes
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }

# General rules for payment processing
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Fix for R8 full mode
-keep class **.R
-keep class **.R$* {
    <fields>;
}