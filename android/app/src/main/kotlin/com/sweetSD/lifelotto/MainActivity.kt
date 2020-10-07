package com.sweetSD.lifelotto

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.UnsupportedEncodingException
import java.net.URLEncoder
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