package com.ekdorn.hogweedgo.models

import android.app.Application
import android.net.Uri
import android.widget.Toast
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.preference.PreferenceDataStore
import com.ekdorn.hogweedgo.R
import com.ekdorn.hogweedgo.dataclasses.User
import com.ekdorn.hogweedgo.singles.Connector
import java.lang.RuntimeException

class UserModel(private val app: Application): AndroidViewModel(app) {
    internal inner class Storage (private val nameKey: String, private val photoKey: String): PreferenceDataStore() {
        internal inner class InvalidFieldException (key: String): RuntimeException("Key $key can not exist in storage!")

        override fun putString(key: String?, value: String?) {
            when (key) {
                nameKey -> pushName(value!!)
                photoKey -> pushPhoto(Uri.parse(value))
                else -> throw InvalidFieldException(key.toString())
            }
        }

        override fun getString(key: String?, defValue: String?): String? {
            return when (key) {
                nameKey -> user.value?.name ?: defValue
                photoKey -> user.value?.photo.toString()
                else -> throw InvalidFieldException(key.toString())
            }
        }
    }


    private val user: MutableLiveData<User> by lazy {
        MutableLiveData<User>().also {
            fetchUser()
        }
    }

    private fun fetchUser () {
        Connector.getUser().catch {
            Toast.makeText(getApplication(), it.localizedMessage, Toast.LENGTH_SHORT).show()
        }.then {
            user.value = it
        }
    }


    private fun pushName (name: String) {
        Connector.setName(name).catch {
            Toast.makeText(getApplication(), it.localizedMessage, Toast.LENGTH_SHORT).show()
        }.then {
            fetchUser()
        }
    }
    private fun pushPhoto (uri: Uri) {
        Connector.setPhoto(uri).catch {
            Toast.makeText(getApplication(), it.localizedMessage, Toast.LENGTH_SHORT).show()
        }.then {
            fetchUser()
        }
    }


    @PublishedApi internal fun getStorage (): Storage {
        val res = app.resources
        return Storage(res.getString(R.string.prefs_user_display_name_key), res.getString(R.string.prefs_user_display_picture_key))
    }
    fun getUser (): LiveData<User> = user
}
