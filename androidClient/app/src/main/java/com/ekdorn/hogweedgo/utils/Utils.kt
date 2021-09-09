package com.ekdorn.hogweedgo.utils

import android.content.Context
import android.net.Uri
import android.text.format.DateFormat
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.ekdorn.hogweedgo.R
import com.google.android.material.textfield.TextInputLayout
import java.util.*



fun getLocalDateTime (ctx: Context, date: Date) = Pair(DateFormat.getDateFormat(ctx).format(date), DateFormat.getTimeFormat(ctx).format(date))


fun setValuesToViews (valuesAndViews: List<Pair<String?, Int>>, layout: View) {
    for ((value, viewID) in valuesAndViews) {
        layout.findViewById<TextView>(viewID).also {
            if (value.isNullOrBlank()) it.visibility = View.GONE
            else {
                it.visibility = View.VISIBLE
                it.text = value
            }
        }
    }
}

fun getValuesFromViews (viewIDs: List<Pair<Int, Boolean>>, layout: View): Map<Int, String>? {
    val map = mutableMapOf<Int, String>()
    var noErrors = true

    for ((viewID, required) in viewIDs) {
        var noError = true
        var errorText = ""

        val parent = layout.findViewById<TextInputLayout>(viewID)
        val view = parent.editText!!
        map[viewID] = view.text.toString()

        if (required) {
            noError = !view.text.isNullOrBlank()
            errorText = layout.context.applicationContext.getString(R.string.form_error_field_required)
        }
        if ((parent.counterMaxLength != -1) && (parent.counterMaxLength < view.text.length)) {
            noError = false
            errorText = layout.context.applicationContext.getString(R.string.form_error_over_counter)
        }

        if (!noError) parent.error = errorText
        else parent.error = null
        noErrors = noErrors && noError
    }

    return if (noErrors) map else null
}


fun ImageView.loadProfilePic (ctx: Context, pic: Uri?) {
    if (pic.toString().isBlank()) this.setImageResource(R.drawable.image_grey)
    else Glide.with(ctx).load(pic).circleCrop().error(R.drawable.no_image_grey).into(this)
}
