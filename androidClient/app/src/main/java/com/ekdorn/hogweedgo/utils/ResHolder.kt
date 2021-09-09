package com.ekdorn.hogweedgo.utils

import android.os.Bundle
import androidx.activity.result.*
import androidx.activity.result.contract.ActivityResultContract
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.preference.PreferenceFragmentCompat
import java.lang.RuntimeException
import kotlin.reflect.KClass



// Use by?

open class ResActivity (vararg contracts: KClass<out ActivityResultContract<*, *>>): AppCompatActivity() {
    private val cont = contracts
    private val holder = mutableMapOf<String, Token<Any, Any>>()

    override fun onCreate(savedInstanceState: Bundle?) {
        cont.forEach { cl ->
            @Suppress("UNCHECKED_CAST")
            holder[cl.java.simpleName] = Token<Any, Any>().also {
                it.launcher = this.registerForActivityResult(cl.java.newInstance() as ActivityResultContract<Any, Any>) { result -> it.lambda.lambda(result) }
            }
        }
        super.onCreate(savedInstanceState)
    }

    internal fun <G: ActivityResultContract<P, C>, P, C> launch (cl: KClass<G>, param: P, callback: (C?) -> Unit = {}) {
        if (!holder.contains(cl.java.simpleName)) throw TokenNotRegisteredException(cl.java.simpleName, "activity")
        holder[cl.java.simpleName]?.apply {
            @Suppress("UNCHECKED_CAST")
            this.lambda.lambda = callback as (Any?) -> Unit
            if (this.launcher != null) this.launcher!!.launch(param) else throw TokenNotRegisteredException(this.toString(), "activity")
        }
    }
}

open class ResFragment (vararg contracts: KClass<out ActivityResultContract<*, *>>): Fragment() {
    private val cont = contracts
    private val holder = mutableMapOf<String, Token<Any, Any>>()

    override fun onCreate(savedInstanceState: Bundle?) {
        cont.forEach { cl ->
            @Suppress("UNCHECKED_CAST")
            holder[cl.java.simpleName] = Token<Any, Any>().also {
                it.launcher = this.registerForActivityResult(cl.java.newInstance() as ActivityResultContract<Any, Any>) { result -> it.lambda.lambda(result) }
            }
        }
        super.onCreate(savedInstanceState)
    }

    internal fun <G: ActivityResultContract<P, C>, P, C> launch (cl: KClass<G>, param: P, callback: (C?) -> Unit = {}) {
        if (!holder.contains(cl.java.simpleName)) throw TokenNotRegisteredException(cl.java.simpleName, "fragment")
        holder[cl.java.simpleName]?.apply {
            @Suppress("UNCHECKED_CAST")
            this.lambda.lambda = callback as (Any?) -> Unit
            if (this.launcher != null) this.launcher!!.launch(param) else throw TokenNotRegisteredException(this.toString(), "fragment")
        }
    }
}

abstract class ResPrefFragment (vararg contracts: KClass<out ActivityResultContract<*, *>>): PreferenceFragmentCompat() {
    private val cont = contracts
    private val holder = mutableMapOf<String, Token<Any, Any>>()

    override fun onCreate(savedInstanceState: Bundle?) {
        cont.forEach { cl ->
            @Suppress("UNCHECKED_CAST")
            holder[cl.java.simpleName] = Token<Any, Any>().also {
                it.launcher = this.registerForActivityResult(cl.java.newInstance() as ActivityResultContract<Any, Any>) { result -> it.lambda.lambda(result) }
            }
        }
        super.onCreate(savedInstanceState)
    }

    internal fun <G: ActivityResultContract<P, C>, P, C> launch (cl: KClass<G>, param: P, callback: (C?) -> Unit = {}) {
        if (!holder.contains(cl.java.simpleName)) throw TokenNotRegisteredException(cl.java.simpleName, "fragment")
        holder[cl.java.simpleName]?.apply {
            @Suppress("UNCHECKED_CAST")
            this.lambda.lambda = callback as (Any?) -> Unit
            if (this.launcher != null) this.launcher!!.launch(param) else throw TokenNotRegisteredException(this.toString(), "fragment")
        }
    }
}


internal class UnitLambdaWrapper <T> (var lambda: (T?) -> Unit = {})
internal class Token <T, L> (var launcher: ActivityResultLauncher<T>? = null, var lambda: UnitLambdaWrapper<L> = UnitLambdaWrapper())

private class TokenNotRegisteredException (token: String, instance: String): RuntimeException("Token exception: Token $token is not registered for this $instance!")
