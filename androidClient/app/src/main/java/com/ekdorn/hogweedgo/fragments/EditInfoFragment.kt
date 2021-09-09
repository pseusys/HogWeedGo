package com.ekdorn.hogweedgo.fragments

import android.os.Bundle
import android.text.SpannableString
import android.text.format.DateFormat.is24HourFormat
import android.text.style.UnderlineSpan
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.fragment.app.FragmentManager
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.RecyclerView
import com.ekdorn.hogweedgo.*
import com.ekdorn.hogweedgo.activities.MainActivity
import com.ekdorn.hogweedgo.dataclasses.Report
import com.ekdorn.hogweedgo.dataclasses.ReportStatus
import com.ekdorn.hogweedgo.singles.Connector
import com.ekdorn.hogweedgo.singles.PreferenceManager
import com.ekdorn.hogweedgo.utils.ResFragment
import com.ekdorn.hogweedgo.utils.getLocalDateTime
import com.ekdorn.hogweedgo.utils.getValuesFromViews
import com.ekdorn.hogweedgo.utils.setValuesToViews
import com.ekdorn.hogweedgo.views.checkout
import com.ekdorn.hogweedgo.views.finalize
import com.ekdorn.hogweedgo.views.setup
import com.google.android.material.datepicker.MaterialDatePicker
import com.google.android.material.timepicker.MaterialTimePicker
import com.google.android.material.timepicker.TimeFormat
import java.util.*



class EditInfoFragment: ResFragment(ActivityResultContracts.TakePicture::class, ActivityResultContracts.StartActivityForResult::class, ActivityResultContracts.GetContent::class), View.OnClickListener {
    private val args: EditInfoFragmentArgs by navArgs()
    private var calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))

    private lateinit var pictures: RecyclerView

    private lateinit var root: View
    private lateinit var dateView: TextView
    private lateinit var timeView: TextView
    private lateinit var sendButton: Button

    override fun onCreateView (inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        root = inflater.inflate(R.layout.fragment_edit_info, container, false)

        dateView = root.findViewById(R.id.edit_info_date)
        dateView.setOnClickListener { showDatePickerDialog(childFragmentManager) }
        timeView = root.findViewById(R.id.edit_info_time)
        timeView.setOnClickListener { showTimePickerDialog(childFragmentManager) }

        sendButton = root.findViewById(R.id.edit_info_send_button)
        sendButton.setOnClickListener(this)

        refreshDateTime()
        setValuesToViews(arrayOf(getString(R.string.app_default_tag)).zip(arrayOf(R.id.edit_info_tag)), root)

        pictures = root.findViewById(R.id.edit_info_pictures_layout)
        pictures.setup(this, null, true)

        (requireActivity() as MainActivity).showNavigation(false)

        return root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        (requireActivity() as MainActivity).showNavigation(true)
    }


    private fun refreshDateTime () {
        val (date, time) = getLocalDateTime(requireContext(), calendar.time)
        dateView.text = SpannableString(date).apply { this.setSpan(UnderlineSpan(), 0, this.length, 0) }
        timeView.text = SpannableString(time).apply { this.setSpan(UnderlineSpan(), 0, this.length, 0) }
    }

    private fun showDatePickerDialog (fragmentManager: FragmentManager) {
        val picker = MaterialDatePicker.Builder.datePicker()
            .setSelection(MaterialDatePicker.todayInUtcMilliseconds())
            .setInputMode(MaterialDatePicker.INPUT_MODE_CALENDAR)
            .build()
        picker.addOnPositiveButtonClickListener { time ->
            val newCalendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            newCalendar.timeInMillis = time
            calendar.set(newCalendar.get(Calendar.YEAR), newCalendar.get(Calendar.MONTH), newCalendar.get(Calendar.DATE))
            refreshDateTime()
        }
        picker.show(fragmentManager, "DATE_PICKER_DIALOG")
    }

    private fun showTimePickerDialog (fragmentManager: FragmentManager) {
        val picker = MaterialTimePicker.Builder()
            .setHour(calendar.get(Calendar.HOUR))
            .setMinute(calendar.get(Calendar.MINUTE))
            .setInputMode(MaterialTimePicker.INPUT_MODE_CLOCK)
            .setTimeFormat(if (is24HourFormat(requireContext())) TimeFormat.CLOCK_24H else TimeFormat.CLOCK_12H)
            .build()
        picker.addOnPositiveButtonClickListener {
            calendar.set(Calendar.HOUR, picker.hour)
            calendar.set(Calendar.MINUTE, picker.minute)
            refreshDateTime()
        }
        picker.show(fragmentManager, "TIME_PICKER_DIALOG")
    }


    override fun onClick (v: View?) {
        val fieldIDs = listOf(Pair(R.id.edit_info_tag_layout, true), Pair(R.id.edit_info_address_layout, false), Pair(R.id.edit_info_comment_layout, false))
        getValuesFromViews(fieldIDs, root)?.also {
            val address = it[R.id.edit_info_address_layout] ?: ""
            val comment = it[R.id.edit_info_comment_layout] ?: ""
            val info = Report(args.coords, ReportStatus.RECEIVED, "hogweed", PreferenceManager.getUserId()!!, it[R.id.edit_info_tag_layout].toString(), calendar.time.time, listOf(), address, comment)
            Connector.push(info, pictures.checkout()).catch { message ->
                Toast.makeText(context, message.localizedMessage, Toast.LENGTH_SHORT).show()
            }.then { pictures.finalize() }
            findNavController().navigateUp()
        }
    }
}
