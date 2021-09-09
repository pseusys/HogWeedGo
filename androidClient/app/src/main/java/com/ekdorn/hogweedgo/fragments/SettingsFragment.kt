package com.ekdorn.hogweedgo.fragments

import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.viewModels
import androidx.preference.EditTextPreference
import com.ekdorn.hogweedgo.R
import com.ekdorn.hogweedgo.models.UserModel
import com.ekdorn.hogweedgo.utils.ResPrefFragment
import com.ekdorn.hogweedgo.views.ImagePreference

class SettingsFragment: ResPrefFragment(ActivityResultContracts.GetContent::class) {
    private val model: UserModel by viewModels({ requireActivity() })

    private lateinit var userName: EditTextPreference
    private lateinit var userPhoto: ImagePreference

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        model.getUser().observe(viewLifecycleOwner, {
            userName.text = it.name
            userPhoto.preview = it.photo
        })
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.fragment_preferences, rootKey)

        val res = this.resources
        userName = findPreference(res.getString(R.string.prefs_user_display_name_key))!!
        userPhoto = findPreference(res.getString(R.string.prefs_user_display_picture_key))!!

        userName.preferenceDataStore = model.getStorage()
        userPhoto.preferenceDataStore = model.getStorage()
        userPhoto.setupCallback(this)
    }
}
