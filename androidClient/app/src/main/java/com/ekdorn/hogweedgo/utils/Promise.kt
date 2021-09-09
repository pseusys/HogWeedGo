package com.ekdorn.hogweedgo.utils

import kotlinx.coroutines.*
import kotlin.coroutines.CoroutineContext

class Promise<T> private constructor (private val context: CoroutineContext = Dispatchers.Main, private val startValue: Any?,
                                      private val asynchronous: suspend (value: Any?, resolve: suspend (value: T) -> Unit, reject: suspend (error: Exception) -> Unit) -> Unit) {

    constructor (ctx: CoroutineContext = Dispatchers.Main, async: suspend (resolve: suspend (value: T) -> Unit, reject: suspend (error: Exception) -> Unit) -> Unit):
            this(ctx, null, { _, resolve, reject -> async(resolve, reject) }) {
        CoroutineScope(context).launch { asynchronous(startValue, ::callValue, ::callError) }
    }

    constructor (scope: CoroutineScope = GlobalScope, async: suspend (resolve: suspend (value: T) -> Unit, reject: suspend (error: Exception) -> Unit) -> Unit):
            this(scope.coroutineContext, null, { _, resolve, reject -> async(resolve, reject) }) {
        scope.launch { asynchronous(startValue, ::callValue, ::callError) }
    }

    private var cha: (suspend (T?, resolve: suspend (Any) -> Unit, reject: suspend (Exception) -> Unit) -> Unit)? = null
    private var nextCtx: CoroutineContext? = null
    private var next: Promise<Any>? = null

    private var res = { _: T -> }
    private var rej = { _: Exception -> }


    private suspend fun callValue (value: T): Unit = withContext(Dispatchers.Main) {
        res(value)
        callChain(value)
    }

    private suspend fun callError (error: Exception): Unit = withContext(Dispatchers.Main) {
        rej(error)
        callChain(null)
    }

    @Suppress("UNCHECKED_CAST")
    private suspend fun callChain(value: T?) = cha?.also { async ->
        Promise(nextCtx!!, value, async as suspend (Any?, suspend (T) -> Unit, suspend (Exception) -> Unit) -> Unit).also {
            it.cha = next?.cha
            it.nextCtx = next?.nextCtx
            it.next = next?.next

            it.res = next!!.res as (T) -> Unit
            it.rej = next!!.rej
        }.also {
            withContext(it.context) { it.asynchronous(it.startValue, it::callValue, it::callError) }
        }
    }


    fun catch (callback: (error: Exception) -> Unit) = this.apply {
        rej = callback
    }

    fun then (callback: (value: T) -> Unit) = this.apply {
        res = callback
    }

    fun <N> then (ctx: CoroutineContext = Dispatchers.Main, async: suspend (value: T?, resolve: suspend (value: N) -> Unit, reject: suspend (error: Exception) -> Unit) -> Unit): Promise<N> {
        @Suppress("UNCHECKED_CAST")
        return this.let {
            cha = async as suspend (T?, suspend (Any) -> Unit, suspend (Exception) -> Unit) -> Unit
            nextCtx = ctx
            next = Promise(startValue = null) { _, _, _ -> }
            next as Promise<N>
        }
    }
}
