package com.embedforge.academy

import android.content.Context
import android.os.Build
import android.os.Process
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "embedforge/diagnostics"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "log" -> {
                    val text = call.arguments as? String ?: ""
                    writeDiagnostic("DART " + text)
                    result.success(true)
                }

                "version" -> {
                    try {
                        val vi = packageManager.getPackageInfo(packageName, 0)
                        result.success(vi.versionName)
                    } catch (t: Throwable) {
                        result.success("?")
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    /**
     * Journal de diagnostic stocké dans le répertoire PRIVÉ de l'application
     * (Context.filesDir) : aucune permission, invisible des autres applications,
     * supprimé à la désinstallation. Taille plafonnée par rotation.
     */
    companion object {
        const val TAG = "EmbedForge"

        private const val FILE_NAME = "embedforge_crash.log"
        private const val MAX_BYTES = 256L * 1024L

        /** Une seule file d'écriture : ordre préservé, pas de thread par ligne. */
        private val writer = Executors.newSingleThreadExecutor { r ->
            Thread(r, "embedforge-diag").apply { isDaemon = true }
        }

        @Volatile
        private var logFile: File? = null

        fun init(context: Context) {
            if (logFile == null) {
                logFile = File(context.applicationContext.filesDir, FILE_NAME)
            }
        }

        @JvmStatic
        fun writeDiagnostic(text: String) {
            val line = Thread.currentThread().name + " | " + timestamp() + " | " + text + "\n"
            try {
                writer.execute { append(line) }
            } catch (t: Throwable) {
                Log.e(TAG, "diagnostic enqueue failed", t)
            }
        }

        /** Écriture synchrone : utilisée quand le processus est sur le point de mourir. */
        fun writeCrash(thread: Thread, throwable: Throwable) {
            val sw = java.io.StringWriter()
            throwable.printStackTrace(java.io.PrintWriter(sw))
            append(
                thread.name + " | " + timestamp() + " | JAVA CRASH proc=" +
                    Process.myPid() + "\n" + sw + "\n"
            )
        }

        @Synchronized
        private fun append(line: String) {
            val file = logFile ?: return
            try {
                if (file.exists() && file.length() > MAX_BYTES) {
                    val old = File(file.parentFile, "$FILE_NAME.1")
                    old.delete()
                    file.renameTo(old)
                }
                file.appendText(line, Charsets.UTF_8)
            } catch (t: Throwable) {
                Log.e(TAG, "append failed", t)
            }
        }

        private fun timestamp(): String =
            SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US).format(Date())
    }

    override fun attachBaseContext(context: Context) {
        super.attachBaseContext(context)
        Companion.init(context)
        try {
            val default = Thread.getDefaultUncaughtExceptionHandler()
            Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
                try {
                    Companion.writeCrash(thread, throwable)
                } catch (t: Throwable) {
                    // nothing else we can do
                }
                default?.uncaughtException(thread, throwable)
            }
        } catch (t: Throwable) {
            Log.e(TAG, "attachBaseContext failed", t)
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        Companion.writeDiagnostic(
            "JAVA onCreate sdk=" + Build.VERSION.SDK_INT
        )
    }
}
