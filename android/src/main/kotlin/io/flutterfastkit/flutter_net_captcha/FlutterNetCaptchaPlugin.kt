package io.flutterfastkit.flutter_net_captcha

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.netease.nis.captcha.Captcha
import com.netease.nis.captcha.Captcha.CloseType
import com.netease.nis.captcha.CaptchaConfiguration
import com.netease.nis.captcha.CaptchaConfiguration.LangType
import com.netease.nis.captcha.CaptchaListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** FlutterNetCaptchaPlugin */
class FlutterNetCaptchaPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {

    private val CHANNEL_NAME = "flutter_net_captcha"
    private val EVENT_CHANNEL_NAME = "flutter_net_captcha/event_channel"

    private lateinit var channel: MethodChannel

    private var eventSink: EventSink? = null

    private lateinit var mContext: Context
    private var activity: Activity? = null

    private lateinit var configurationBuilder: CaptchaConfiguration.Builder

    private fun setupChannel(messenger: BinaryMessenger, context: Context) {
        mContext = context
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        val eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
        eventChannel.setStreamHandler(this)
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        setupChannel(flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "configVerifyCode" -> configVerifyCode(call, result)
            "showCaptcha" -> showCaptcha(call, result)
            "getSdkVersion" -> getSdkVersion(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * 配置验证码
     *
     * @param call
     * @param result
     */
    private fun configVerifyCode(call: MethodCall, result: Result) {
        configurationBuilder = CaptchaConfiguration.Builder()
                .captchaId(call.argument("captchaId"))
                .timeout(call.argument<Int>("timeoutInterval")!! * 1000.toLong())
                .failedMaxRetryCount(call.argument<Int>("fallBackCount")!!)
                .ipv6(call.argument<Boolean>("ipv6")!!)
                .useDefaultFallback(call.argument<Boolean>("openFallBack")!!)
                .hideCloseButton(call.argument<Boolean>("closeButtonHidden")!!)
                .touchOutsideDisappear(call.argument<Boolean>("shouldCloseByTouchBackground")!!)
                .debug(call.argument<Boolean>("enableLog")!!)
        result.success(true)
    }

    private fun showCaptcha(call: MethodCall, result: Result) {
        configurationBuilder.languageType(getLanguage(call.argument("language")))
        configurationBuilder.mode(if (call.argument<String>("mode") == "Normal") CaptchaConfiguration.ModeType.MODE_CAPTCHA else CaptchaConfiguration.ModeType.MODE_INTELLIGENT_NO_SENSE)
        configurationBuilder.listener(object : CaptchaListener {
            override fun onReady() {
                if (eventSink != null) {
                    val result: MutableMap<String, Any> = HashMap()
                    result["method"] = "onLoaded"
                    activity!!.runOnUiThread { eventSink!!.success(result) }
                }
            }

            override fun onValidate(res: String, validate: String, msg: String) {
                if (eventSink != null) {
                    val result: MutableMap<String, Any> = HashMap()
                    result["method"] = "onVerify"
                    val data: MutableMap<String, Any> = HashMap()
                    data["result"] = res.toBoolean()
                    data["validate"] = validate
                    data["msg"] = msg
                    result["data"] = data
                    activity!!.runOnUiThread { eventSink!!.success(result) }
                }
            }

            override fun onError(i: Int, s: String) {
                if (eventSink != null) {
                    val result: MutableMap<String, Any> = HashMap()
                    result["method"] = "onError"
                    result["data"] = s
                    activity!!.runOnUiThread { eventSink!!.success(result) }
                }
            }

            override fun onClose(closeType: CloseType) {
                if (eventSink != null) {
                    val result: MutableMap<String, Any> = HashMap()
                    result["method"] = "onClose"
                    result["data"] = if (closeType == CloseType.USER_CLOSE) 1 else 2
                    activity!!.runOnUiThread { eventSink!!.success(result) }
                }
            }
        })
        val captcha = Captcha.getInstance().init(configurationBuilder.build(activity))
        activity!!.runOnUiThread { captcha.validate() }
        result.success(true)
    }

    /**
     * 获取版本号
     *
     * @param call
     * @param result
     */
    private fun getSdkVersion(call: MethodCall, result: Result) {
        result.success(Captcha.SDK_VERSION)
    }

    private fun getLanguage(language: String?): LangType {
        val langType = LangType.valueOf("LANG_$language")
        return langType ?: LangType.LANG_ZH_TW
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events;
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null;
    }

    override fun onDetachedFromActivity() {
        activity = null;
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }
}
