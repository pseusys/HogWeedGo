package com.ekdorn.hogweedgo.views

import android.content.Context
import android.content.res.ColorStateList
import android.util.AttributeSet
import android.util.Log
import com.ekdorn.hogweedgo.R
import com.google.android.material.floatingactionbutton.FloatingActionButton



class ReportButton(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : FloatingActionButton(context, attrs, defStyleAttr) {
    enum class ReportButtonState { STATE_NO_PERMISSION, STATE_NO_LOCATION, STATE_READY }


    constructor (context: Context, attrs: AttributeSet?): this(context, attrs, com.google.android.material.R.attr.floatingActionButtonStyle)
    constructor (context: Context): this(context, null)

    init {
        this.setImageResource(R.drawable.ic_report_button_no_permission)
    }

    var state: ReportButtonState = ReportButtonState.STATE_NO_PERMISSION
        set (value) {
            field = value
            when (value) {
                ReportButtonState.STATE_NO_PERMISSION -> {
                    this.setImageResource(R.drawable.ic_report_button_no_permission)
                    this.backgroundTintList = ColorStateList.valueOf(context.getColor(R.color.colorDisable))
                }
                ReportButtonState.STATE_NO_LOCATION -> {
                    this.setImageResource(R.drawable.ic_report_button_no_location)
                    this.backgroundTintList = ColorStateList.valueOf(context.getColor(R.color.colorDisable))
                }
                ReportButtonState.STATE_READY -> {
                    this.setImageResource(R.drawable.ic_report_button_ready)
                    this.backgroundTintList = ColorStateList.valueOf(context.getColor(R.color.colorAccent))
                }
            }
        }
}