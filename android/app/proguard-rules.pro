# OkHttp Platform used by Firebase and other libraries
-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Keep OkHttp platform implementations
-keep class okhttp3.internal.platform.** { *; }
