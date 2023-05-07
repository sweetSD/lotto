package com.sweetSD.klotto

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import io.flutter.plugins.GeneratedPluginRegistrant
import java.net.URLEncoder 
import java.nio.charset.Charset
import java.io.UnsupportedEncodingException
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private val CHANNEL = "_ENCODING"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,CHANNEL).setMethodCallHandler { call, result ->
            if(call.method == "encode") {
                val arguments = (call.arguments as ArrayList<String>)
                val res = encode(arguments[0], arguments[1])
                if(res != null) result.success(res)
                else result.error("UnsupportedEncodingException", "UnsupportedEncodingException was occured.", null)
            }
            if(call.method == "decode") {
                val arguments = (call.arguments as ArrayList<String>)
                val res = decode(arguments[0], arguments[1])
                if(res != null) result.success(res)
                else result.error("UnsupportedEncodingException", "UnsupportedEncodingException was occured.", null)
            }
            if(call.method == "encodeByte") {
                val arguments = (call.arguments as ArrayList<String>)
                val res = (arguments[0] as String).toByteArray(Charset.forName(arguments[1] as String))
                if(res != null) result.success(res)
                else result.error("UnsupportedEncodingException", "UnsupportedEncodingException was occured.", null)
            }
            if(call.method == "decodeByte") {
                val arguments = (call.arguments as ArrayList<Any>)
                val res = String(arguments[0] as ByteArray, charset(arguments[1] as String))
                if(res != null) result.success(res)
                else result.error("UnsupportedEncodingException", "UnsupportedEncodingException was occured.", null)
            }
        }
    }

    fun encode(data: String, encode: String): String? {
        val res: String? = try {
            URLEncoder.encode(data, encode)
        } catch (e: UnsupportedEncodingException) {
            null
        }
        return res;
    }

    fun decode(data: String, encode: String): String? {
        val res: String? = try {
            URLEncoder.encode(data, encode)
        } catch (e: UnsupportedEncodingException) {
            null
        }
        return res;
    }
}
