package com.example.tindahan_ko_flutter

import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

class ExcelExportPlugin(private val context: Context) : MethodChannel.MethodCallHandler {
    
    companion object {
        private const val CHANNEL = "tindahan_ko/excel_export"
        
        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(ExcelExportPlugin(context))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "saveToDownloads" -> {
                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")
                
                if (fileName != null && bytes != null) {
                    // Sanitize filename to prevent path traversal
                    val sanitizedFileName = sanitizeFileName(fileName)
                    saveToDownloads(sanitizedFileName, bytes, result)
                } else {
                    result.error("INVALID_ARGUMENTS", "fileName and bytes are required", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun saveToDownloads(fileName: String, bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val filePath = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                saveWithMediaStore(fileName, bytes)
            } else {
                saveWithFileSystem(fileName, bytes)
            }
            
            // Show toast notification with sanitized message
            Toast.makeText(context, "File saved successfully", Toast.LENGTH_LONG).show()
            
            result.success(filePath)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", "Failed to save file", null)
        }
    }

    private fun saveWithMediaStore(fileName: String, bytes: ByteArray): String {
        val resolver: ContentResolver = context.contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
        }

        val uri: Uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            ?: throw Exception("Failed to create MediaStore entry")

        resolver.openOutputStream(uri)?.use { outputStream ->
            outputStream.write(bytes)
            outputStream.flush()
        } ?: throw Exception("Failed to open output stream")

        // Trigger media scan for better compatibility
        MediaScannerConnection.scanFile(
            context,
            arrayOf(getPathFromUri(uri)),
            arrayOf("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
            null
        )

        return "Downloads/" + fileName.replace("/", "_").replace("\\", "_")
    }

    private fun saveWithFileSystem(fileName: String, bytes: ByteArray): String {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (!downloadsDir.exists()) {
            downloadsDir.mkdirs()
        }

        val file = File(downloadsDir, fileName)
        FileOutputStream(file).use { outputStream ->
            outputStream.write(bytes)
            outputStream.flush()
        }

        // Trigger media scan for file manager visibility
        MediaScannerConnection.scanFile(
            context,
            arrayOf(file.absolutePath),
            arrayOf("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
            null
        )

        return file.absolutePath
    }

    private fun sanitizeFileName(fileName: String): String {
        // Remove path traversal attempts and invalid characters
        return fileName
            .replace("..", "")
            .replace("/", "_")
            .replace("\\", "_")
            .replace(":", "_")
            .replace("*", "_")
            .replace("?", "_")
            .replace("\"", "_")
            .replace("<", "_")
            .replace(">", "_")
            .replace("|", "_")
            .take(255) // Limit filename length
    }

    private fun getPathFromUri(uri: Uri): String {
        return try {
            val cursor = context.contentResolver.query(uri, null, null, null, null)
            cursor?.use {
                if (it.moveToFirst()) {
                    val columnIndex = it.getColumnIndex(MediaStore.MediaColumns.DATA)
                    if (columnIndex >= 0) {
                        it.getString(columnIndex) ?: "Downloads"
                    } else "Downloads"
                } else "Downloads"
            } ?: "Downloads"
        } catch (e: Exception) {
            "Downloads"
        }
    }
}