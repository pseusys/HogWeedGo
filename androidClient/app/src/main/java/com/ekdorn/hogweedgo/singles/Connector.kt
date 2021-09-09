package com.ekdorn.hogweedgo.singles

// RECYCLE!!!, string errors

import android.net.Uri
import com.ekdorn.hogweedgo.Server
import com.ekdorn.hogweedgo.dataclasses.*
import com.ekdorn.hogweedgo.utils.Promise
import kotlinx.coroutines.*
import java.lang.RuntimeException
import java.security.MessageDigest


object Connector {
    private val api = Server()


    private val info = ArrayList<ReportWithID>()

    private var addMarkerCallback: ((ReportWithID) -> Unit)? = null
    private var addMarker: (ReportWithID) -> Unit = { i ->
        info.add(i)
        addMarkerCallback?.let { it(i) }
    }

    private var removeMarkerCallback: ((String) -> Unit)? = null
    private var removeMarker: (String) -> Unit = { k ->
        removeMarkerCallback?.let { it(k) }
        info.dropWhile { it.key == k }
    }



    fun push (info: Report, photos: List<Uri> = listOf()): Promise<Void?> {
        return Promise(Dispatchers.IO) { resolve, reject ->
            api.setImagesAndInfo(photos, info) { success, message ->
                CoroutineScope(Dispatchers.Main).launch {
                    if (success) resolve(null)
                    else reject(message!!)
                }
            }
        }
    }

    fun connectMap (addMarker: ((ReportWithID) -> Unit), removeMarker: ((String) -> Unit)) {
        addMarkerCallback = addMarker
        removeMarkerCallback = removeMarker
        api.setMapCallbacks(info, Connector.addMarker, Connector.removeMarker)
    }

    fun disconnectMap () {
        addMarkerCallback = null
        removeMarkerCallback = null
        api.resetMapCallbacks()
    }


    private fun simpleHash(password: String): String {
        return MessageDigest.getInstance("SHA-1").digest(password.toByteArray()).joinToString("") { "%02x".format(it) }
    }

    fun createAccount (email: String, password: String): Promise<String> {
        return Promise(Dispatchers.IO) { resolve, reject ->
            api.createAccount(email, simpleHash(password)) { success, message, id ->
                CoroutineScope(Dispatchers.Main).launch {
                    if (success) {
                        if (id != null) resolve(id)
                        else reject(RuntimeException("Returned user id was null!"))
                    }
                    else reject(message!!)
                }
            }
        }
    }

    fun logIn (email: String, password: String): Promise<String> {
        return Promise(Dispatchers.IO) { resolve, reject ->
            api.logIn(email, simpleHash(password)) { success, message, id ->
                CoroutineScope(Dispatchers.Main).launch {
                    if (success) {
                        if (id != null) resolve(id)
                        else reject(RuntimeException("Returned user id was null!"))
                    }
                    else reject(message!!)
                }
            }
        }
    }


    fun setName (name: String): Promise<Unit?> {
        return Promise(Dispatchers.IO) { resolve, reject ->
            api.setUserName(name) { success, message ->
                CoroutineScope(Dispatchers.Main).launch {
                    if (success) resolve(null)
                    else reject(message!!)
                }
            }
        }
    }

    fun setPhoto (photo: Uri): Promise<Unit?> {
        return Promise(Dispatchers.IO) { resolve, reject ->
            api.setUserPhoto(photo) { success, message ->
                CoroutineScope(Dispatchers.Main).launch {
                    if (success) resolve(null)
                    else reject(message!!)
                }
            }
        }
    }

    fun getUser (id: String? = null): Promise<User> {
        return Promise(Dispatchers.IO) { resolve, reject ->
            api.getUser(id ?: PreferenceManager.getUserId()!!) { success, message, user ->
                CoroutineScope(Dispatchers.Main).launch {
                    if (success) resolve(user!!)
                    else reject(message!!)
                }
            }
        }
    }
}
