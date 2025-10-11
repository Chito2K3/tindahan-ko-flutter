package com.example.tindahan_ko_flutter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.InputStream

class ExcelImportPlugin(
    private val activity: Activity
) : MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    
    companion object {
        private const val CHANNEL = "tindahan_ko/excel_import"
        private const val PICK_FILE_REQUEST = 1001
        private const val BROWSE_DOWNLOADS_REQUEST = 1002
        
        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val plugin = ExcelImportPlugin(activity)
            channel.setMethodCallHandler(plugin)
        }
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickExcelFile" -> {
                pendingResult = result
                pickExcelFile()
            }
            "browseDownloadsFolder" -> {
                pendingResult = result
                browseDownloadsFolder()
            }
            else -> result.notImplemented()
        }
    }

    private fun pickExcelFile() {
        try {
            android.util.Log.d("ExcelImportPlugin", "Starting file picker")
            
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "*/*"
                addCategory(Intent.CATEGORY_OPENABLE)
                putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "application/vnd.ms-excel",
                    "application/octet-stream",
                    "*/*"
                ))
                putExtra(Intent.EXTRA_TITLE, "Select Tindahan Ko Excel File")
            }
            
            val chooser = Intent.createChooser(intent, "Select Excel File")
            activity.startActivityForResult(chooser, PICK_FILE_REQUEST)
            
            android.util.Log.d("ExcelImportPlugin", "File picker started")
            
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                if (pendingResult != null) {
                    android.util.Log.w("ExcelImportPlugin", "File picker timeout")
                    pendingResult?.error("TIMEOUT", "File picker timeout - please try again", null)
                    pendingResult = null
                }
            }, 20000)
            
        } catch (e: Exception) {
            android.util.Log.e("ExcelImportPlugin", "Failed to start file picker", e)
            pendingResult?.error("PICKER_ERROR", "Failed to open file picker: ${e.message}", null)
            pendingResult = null
        }
    }

    private fun browseDownloadsFolder() {
        try {
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "*/*"
                addCategory(Intent.CATEGORY_OPENABLE)
            }
            
            activity.startActivityForResult(intent, BROWSE_DOWNLOADS_REQUEST)
            
            // Set timeout for this method too
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                if (pendingResult != null) {
                    pendingResult?.error("TIMEOUT", "Downloads browser timeout", null)
                    pendingResult = null
                }
            }, 10000) // 10 second timeout
            
        } catch (e: Exception) {
            pendingResult?.error("BROWSE_ERROR", "Failed to browse downloads", null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        android.util.Log.d("ExcelImportPlugin", "onActivityResult: requestCode=$requestCode, resultCode=$resultCode, data=$data")
        
        when (requestCode) {
            PICK_FILE_REQUEST, BROWSE_DOWNLOADS_REQUEST -> {
                val currentResult = pendingResult
                pendingResult = null // Clear immediately to prevent timeout conflicts
                
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    try {
                        val uri = data.data!!
                        android.util.Log.d("ExcelImportPlugin", "Processing URI: $uri")
                        
                        val fileName = getFileName(uri)
                        android.util.Log.d("ExcelImportPlugin", "File name: $fileName")
                        
                        val bytes = readFileFromUri(uri)
                        
                        if (bytes != null && bytes.isNotEmpty()) {
                            android.util.Log.d("ExcelImportPlugin", "File read successfully: ${bytes.size} bytes")
                            
                            if (bytes.size < 50) {
                                android.util.Log.e("ExcelImportPlugin", "File too small: ${bytes.size} bytes")
                                currentResult?.error("INVALID_FILE", "File is too small to be a valid Excel file", null)
                            } else {
                                currentResult?.success(bytes)
                                Toast.makeText(activity, "File selected: $fileName", Toast.LENGTH_SHORT).show()
                            }
                        } else {
                            android.util.Log.e("ExcelImportPlugin", "Failed to read file or file is empty")
                            currentResult?.error("READ_ERROR", "Could not read file or file is empty", null)
                        }
                    } catch (e: Exception) {
                        android.util.Log.e("ExcelImportPlugin", "Exception reading file", e)
                        currentResult?.error("read_ERROR", "Failed to read file: ${e.message}", null)
                    }
                } else {
                    android.util.Log.d("ExcelImportPlugin", "User cancelled or no data")
                    currentResult?.success(null) // User cancelled
                }
                return true
            }
        }
        return false
    }

    private fun readFileFromUri(uri: Uri): List<Int>? {
        return try {
            android.util.Log.d("ExcelImportPlugin", "Reading file from URI: $uri")
            
            activity.contentResolver.openInputStream(uri)?.use { inputStream ->
                val bytes = inputStream.readBytes()
                android.util.Log.d("ExcelImportPlugin", "Read ${bytes.size} bytes from file")
                
                if (bytes.isEmpty()) {
                    android.util.Log.e("ExcelImportPlugin", "File is empty")
                    return null
                }
                
                val firstBytes = bytes.take(8).map { String.format("%02X", it) }.joinToString(" ")
                android.util.Log.d("ExcelImportPlugin", "First bytes: $firstBytes")
                
                val result = bytes.map { it.toInt() and 0xFF }
                android.util.Log.d("ExcelImportPlugin", "Converted to ${result.size} integers")
                result
            }
        } catch (e: Exception) {
            android.util.Log.e("ExcelImportPlugin", "Error reading file", e)
            null
        }
    }
    
    private fun getFileName(uri: Uri): String? {
        return try {
            activity.contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0 && cursor.moveToFirst()) {
                    cursor.getString(nameIndex)
                } else {
                    uri.lastPathSegment
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("ExcelImportPlugin", "Error getting file name", e)
            uri.lastPathSegment
        }
    }

    private fun isValidExcelFile(bytes: ByteArray): Boolean {
        if (bytes.size < 4) return false
        
        // Check for Excel file signatures
        val signature = bytes.take(4).map { it.toInt() and 0xFF }
        
        // XLSX signature (ZIP format): 50 4B 03 04
        if (signature == listOf(0x50, 0x4B, 0x03, 0x04)) return true
        
        // XLS signature: D0 CF 11 E0
        if (signature == listOf(0xD0, 0xCF, 0x11, 0xE0)) return true
        
        return false
    }
}