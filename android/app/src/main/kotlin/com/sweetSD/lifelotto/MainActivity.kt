package com.sweetSD.klotto

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.UnsupportedEncodingException
import java.net.URLEncoder
import java.nio.charset.Charset
import java.util.ArrayList

class MainActivity() : FlutterActivity() {
    private val CHANNEL = "_ENCODING"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
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