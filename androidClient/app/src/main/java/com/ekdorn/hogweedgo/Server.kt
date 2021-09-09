package com.ekdorn.hogweedgo

import android.net.Uri
import android.util.Log
import com.ekdorn.hogweedgo.dataclasses.ReportWithID
import com.ekdorn.hogweedgo.dataclasses.Report
import com.ekdorn.hogweedgo.dataclasses.User
import com.ekdorn.hogweedgo.dataclasses.UserRole
import com.ekdorn.hogweedgo.singles.PreferenceManager
import com.google.firebase.database.ChildEventListener
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import com.google.firebase.database.ktx.database
import com.google.firebase.database.ktx.getValue
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.ktx.storage
import java.lang.RuntimeException
import java.util.*
import kotlin.collections.ArrayList



// translate errors

class Server {
    private val usersRef = Firebase.database.getReference("users")
    private val loginRef = Firebase.database.getReference("login")
    private val reportsRef = Firebase.database.getReference("reports")
    private val placesImgRef = Firebase.storage.reference.child("places")
    private val usersImgRef = Firebase.storage.reference.child("users")
    private var mapEventListener: ChildEventListener? = null

    fun setMapCallbacks (infos: ArrayList<ReportWithID>, addInfo: (ReportWithID) -> Unit, removeInfo: (String) -> Unit) {
        if (mapEventListener != null) return

        mapEventListener = object: ChildEventListener {
            override fun onChildAdded(snapshot: DataSnapshot, previousChildName: String?) {
                val info = snapshot.getValue<Report>()
                val key = snapshot.key
                if ((info != null) && (key != null)) addInfo(ReportWithID(key, info))
            }

            override fun onChildChanged(snapshot: DataSnapshot, previousChildName: String?) {
                val info = snapshot.getValue<Report>()
                val key = snapshot.key
                if ((info != null) && (key != null)) infos.first { it.key == key }.info = info
            }

            override fun onChildRemoved(snapshot: DataSnapshot) = snapshot.key.let { if (it != null) removeInfo(it) }

            override fun onChildMoved(snapshot: DataSnapshot, previousChildName: String?) = Unit
            override fun onCancelled(error: DatabaseError) = Unit
        }

        reportsRef.addChildEventListener(mapEventListener!!)
    }

    fun resetMapCallbacks () {
        if (mapEventListener != null) {
            reportsRef.removeEventListener(mapEventListener!!)
            mapEventListener = null
        }
    }


    private fun translate (fileNum: Int, uris: List<Uri>, globals: MutableList<Uri>, callback: (List<Uri>) -> Unit) {
        val fileRef = placesImgRef.child(UUID.randomUUID().toString())
        fileRef.putFile(uris[fileNum]).addOnCompleteListener {
            fileRef.downloadUrl.addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    task.result?.let { globals.add(it) }
                    if (fileNum + 1 < uris.size) translate(fileNum + 1, uris, globals, callback)
                    else callback(globals)
                } else translate(fileNum, uris, globals, callback)
            }
        }
    }

    private fun setImages(uris: List<Uri>, callback: (List<Uri>) -> Unit) {
        if (uris.isEmpty()) return callback(mutableListOf())
        else translate(0, uris, mutableListOf(), callback)
    }

    fun setImagesAndInfo (uris: List<Uri>, info: Report, callback: (success: Boolean, error: Exception?) -> Unit) {
        setImages(uris) { uploadedPhotos ->
            info.photos = uploadedPhotos.map { photos -> photos.toString() }
            reportsRef.push().setValue(info).addOnCompleteListener {
                callback(it.isSuccessful, it.exception)
            }
        }
    }



    fun createAccount(email: String, password: String, callback: (success: Boolean, error: Exception?, id: String?) -> Unit) {
        loginRef.orderByChild("email").equalTo(email).addListenerForSingleValueEvent(object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                if (snapshot.children.count() > 0) callback(false, RuntimeException("User already exists!"), null)
                else {
                    val data = User()
                    val idRef = usersRef.push()
                    idRef.apply {
                        child("role").setValue(data.role.name)
                        child("name").setValue(data.name)
                        child("photo").setValue(data.photo.toString())
                        child("verified").setValue(data.verified)
                    }
                    val key = idRef.key.toString()
                    val loginRef = loginRef.child(key)
                    loginRef.child("email").setValue(email)
                    loginRef.child("password").setValue(password)
                    callback(true, null, key)
                }
            }

            override fun onCancelled(error: DatabaseError) = Unit
        })
    }

    fun logIn(email: String, password: String, callback: (success: Boolean, error: Exception?, id: String?) -> Unit) {
        loginRef.orderByChild("email").equalTo(email).addListenerForSingleValueEvent(object: ValueEventListener{
            override fun onDataChange (snapshot: DataSnapshot) {
                if (snapshot.children.count() == 0) callback(false, RuntimeException("User does not exist!"), null)
                else {
                    val id = snapshot.children.elementAt(0).key
                    val pass = snapshot.children.elementAt(0).child("password").getValue<String>()
                    if ((id != null) && (pass == password)) callback(true, null, id)
                    else callback(false, RuntimeException("Wrong password!"), null)
                }
            }
            override fun onCancelled(error: DatabaseError) = Unit
        })
    }

    fun setUserName(name: String, callback: (success: Boolean, error: Exception?) -> Unit) {
        usersRef.child(PreferenceManager.getUserId()!!).child("name").setValue(name).addOnCompleteListener {
            callback(it.isSuccessful, it.exception)
        }
    }

    fun setUserPhoto(photo: Uri, callback: (success: Boolean, error: Exception?) -> Unit) {
        val fileRef = usersImgRef.child(PreferenceManager.getUserId()!!)
        if (photo.toString() != "") {
            fileRef.putFile(photo).addOnCompleteListener {
                fileRef.downloadUrl.addOnCompleteListener { task ->
                    if (task.isSuccessful) usersRef.child(PreferenceManager.getUserId()!!).child("photo").setValue(task.result.toString()).addOnCompleteListener {
                        callback(it.isSuccessful, it.exception)
                    } else callback(false, task.exception)
                }
            }
        } else {
            fileRef.delete().addOnCompleteListener { task ->
                if (task.isSuccessful) usersRef.child(PreferenceManager.getUserId()!!).child("photo").setValue("").addOnCompleteListener {
                    callback(it.isSuccessful, it.exception)
                } else callback(false, task.exception)
            }
        }
    }

    fun getUser(id: String, callback: (success: Boolean, error: Exception?, user: User?) -> Unit) {
        usersRef.child(id).get().addOnCompleteListener {
            callback(it.isSuccessful, it.exception, if (it.isSuccessful) it.result?.value?.let { result ->
                val json = result as Map<*, *>
                val role = UserRole.valueOf(json["role"] as String)
                val name = json["name"] as String
                val photo = Uri.parse(json["photo"] as String)
                val verified = json["verified"] as Boolean
                User(role, name, photo, verified)
            } else null)
        }
    }
}
