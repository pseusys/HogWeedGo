package com.ekdorn.hogweedgo.singles

import android.content.Context
import android.content.SharedPreferences
import java.lang.RuntimeException
import kotlin.reflect.KClass



object PreferenceManager {
    private class PreferenceTypeException (type: String): RuntimeException("Type $type can not exist in SharedPreferences")
    private fun raise (type: KClass<out Any>): Nothing = throw PreferenceTypeException(type.java.name)

    private lateinit var values: SharedPreferences
    private lateinit var settings: SharedPreferences
    fun init (ctx: Context) {
        values = ctx.getSharedPreferences("values", Context.MODE_PRIVATE)
        settings = ctx.getSharedPreferences("settings", Context.MODE_PRIVATE)
    }

    private fun <T> put (prefs: SharedPreferences, key: String, value: T) {
        val editor = prefs.edit()
        if (value is Boolean) editor.putBoolean(key, value)
        else if (value is Float) editor.putFloat(key, value)
        else if (value is Int) editor.putInt(key, value)
        else if (value is Long) editor.putLong(key, value)
        else if (value is String) editor.putString(key, value)
        else if ((value is Set<*>) && (value.toTypedArray().isArrayOf<String>())) @Suppress("UNCHECKED_CAST") editor.putStringSet(key, value as Set<String>)
        else raise(value!!::class)
        editor.apply()
    }

    private fun <T> get (prefs: SharedPreferences, key: String, default: T): T {
        @Suppress("UNCHECKED_CAST")
        return if (default is Boolean) prefs.getBoolean(key, default) as T
        else if (default is Float) prefs.getFloat(key, default) as T
        else if (default is Int) prefs.getInt(key, default) as T
        else if (default is Long) prefs.getLong(key, default) as T
        else if (default is String) prefs.getString(key, default) as T
        else if ((default is Set<*>) && (default.toTypedArray().isArrayOf<String>())) prefs.getStringSet(key, default as Set<String>) as T
        else raise(default!!::class)
    }


    fun <T> putSetting (key: String, value: T) = put(settings, key, value)
    fun <T> getSetting (key: String, default: T) = get(settings, key, default)


    fun <T> putValue (key: String, value: T) = put(values, key, value)
    fun <T> getValue (key: String, default: T) = get(values, key, default)

    fun setUserId (userID: String) = putValue("USER_ID", userID)
    fun getUserId (): String? {
        val id = getValue("USER_ID", "")
        return if (id == "") null else id
    }
}
