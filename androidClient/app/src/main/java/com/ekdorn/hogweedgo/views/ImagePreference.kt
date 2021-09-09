package com.ekdorn.hogweedgo.views

import android.content.Context
import android.net.Uri
import android.util.AttributeSet
import android.util.Log
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.view.children
import androidx.preference.Preference
import androidx.preference.PreferenceViewHolder
import com.ekdorn.hogweedgo.R
import com.ekdorn.hogweedgo.utils.ResPrefFragment
import com.ekdorn.hogweedgo.utils.loadProfilePic
import com.google.android.material.floatingactionbutton.FloatingActionButton

class ImagePreference(context: Context, attrs: AttributeSet?, defStyleAttr: Int): Preference(context, attrs, defStyleAttr) {
    constructor (context: Context, attrs: AttributeSet?): this(context, attrs, R.attr.preferenceStyle)
    constructor (context: Context): this(context, null)


    init {
        widgetLayoutResource = R.layout.preference_image
    }


    private var image: ImageView? = null

    var value: Uri = Uri.EMPTY
        set (value) {
            callChangeListener(value)
            field = value
            persistString(value.toString())
            notifyChanged()
        }
    var preview: Uri? = null
        set(value) {
            field = value
            image?.loadProfilePic(context, value)
        }

    private var click: (() -> Unit)? = null


    override fun onBindViewHolder(holder: PreferenceViewHolder?) {
        super.onBindViewHolder(holder)
        (holder?.itemView as ViewGroup).children.elementAt(2).layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT)

        image = holder.findViewById(R.id.pref_picture) as ImageView
        image!!.loadProfilePic(context, preview)

        holder.findViewById(R.id.pref_close_button).setOnClickListener {
            value = Uri.EMPTY
        }
    }

    override fun onClick() = if (click != null) click!!() else Unit

    fun setupCallback (fragment: ResPrefFragment) {
        click = {
            fragment.launch(ActivityResultContracts.GetContent::class, "image/*") { it?.apply { value = this } }
        }
    }
}
