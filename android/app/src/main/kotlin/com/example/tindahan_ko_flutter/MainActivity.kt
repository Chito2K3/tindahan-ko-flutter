package com.example.tindahan_ko_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var importPlugin: ExcelImportPlugin? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            ExcelExportPlugin.registerWith(flutterEngine, this)
            importPlugin = ExcelImportPlugin(this)
            ExcelImportPlugin.registerWith(flutterEngine, this)
            android.util.Log.d("MainActivity", "Plugins registered successfully")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to register plugins", e)
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?) {
        android.util.Log.d("MainActivity", "onActivityResult called: requestCode=$requestCode, resultCode=$resultCode")
        super.onActivityResult(requestCode, resultCode, data)
        
        try {
            val handled = importPlugin?.onActivityResult(requestCode, resultCode, data) ?: false
            android.util.Log.d("MainActivity", "Import plugin handled result: $handled")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error handling activity result", e)
        }
    }
}
