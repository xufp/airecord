package com.example.recordpen

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL: String = "lib/method_channel"

    @Override
    public override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val batteryLevel = getBatteryLevel()
                        if (batteryLevel != -1) {
                            result.success(batteryLevel)
                        } else {
                            result.error("UNAVAILABLE", "Battery level not available.", null)
                        }
                    }

                    "getDeviceInfo" -> {
                        val deviceInfo: String = getDeviceInfo()
                        result.success(deviceInfo)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryLevel(): Int {
        // 实现获取电池电量的逻辑
        // ...
        return 250 // 假设的返回值
    }


    private fun getDeviceInfo(): String {
        return "hahahhahahahah";
    }
}
