package com.ekdorn.hogweedgo.fragments

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ekdorn.hogweedgo.*
import com.ekdorn.hogweedgo.dataclasses.ReportWithID
import com.ekdorn.hogweedgo.singles.Connector
import com.ekdorn.hogweedgo.utils.ResFragment
import com.ekdorn.hogweedgo.utils.getLocalDateTime
import com.ekdorn.hogweedgo.utils.setValuesToViews
import com.ekdorn.hogweedgo.views.setup
import com.google.android.libraries.maps.CameraUpdateFactory
import java.util.*



class ViewInfoFragment: ResFragment(ActivityResultContracts.StartActivityForResult::class) {
    private lateinit var root: ConstraintLayout

    override fun onCreateView (inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        root = inflater.inflate(R.layout.fragment_view_info, container, false) as ConstraintLayout
        return root
    }

    fun setupContent (info: ReportWithID): ConstraintLayout {
        val data = root.findViewById<ConstraintLayout>(R.id.view_info)
        val (date, time) = getLocalDateTime(requireContext(), Date(info.info.date))
        val values = arrayOf(info.info.tag, "$date $time", getString(R.string.connection_no_user), info.info.place.toString(), info.info.address, info.info.comment)
        val views = arrayOf(R.id.view_info_tag, R.id.view_info_date_time, R.id.view_info_subs, R.id.view_info_coords, R.id.view_info_address, R.id.view_info_comment)
        setValuesToViews(values.zip(views), data)

        Connector.getUser(info.info.subs).then {
            setValuesToViews(arrayOf(it.name).zip(arrayOf(R.id.view_info_subs)), data) // TODO: handle deleted user
            Glide.with(this).load(it.photo).error(R.drawable.no_image_grey).into(data.findViewById(R.id.view_info_subs_image))
        }

        root.findViewById<ImageView>(R.id.view_info_status).setImageResource(info.info.status.getResource())

        root.findViewById<TextView>(R.id.view_info_coords).setOnClickListener {
            val map = (parentFragment as MapBearFragment).getChildFrag(R.id.main_frragment)
            if (map != null) (map as MapFragment).mMap.animateCamera(CameraUpdateFactory.newLatLng(info.info.place()))
        }

        root.findViewById<TextView>(R.id.view_info_address).setOnClickListener {
            val gmmIntentUri = Uri.parse("google.navigation:q=${info.info.place.lat},${info.info.place.long}")
            launch(ActivityResultContracts.StartActivityForResult::class, Intent(Intent.ACTION_VIEW, gmmIntentUri).setPackage("com.google.android.apps.maps"))
        }

        val pictures = root.findViewById<RecyclerView>(R.id.view_info_pictures_layout)
        if (info.info.photos.isEmpty()) pictures.visibility = View.GONE
        else pictures.setup(this, info.info.photos, false)

        return data.findViewById(R.id.view_info_data)
    }
}
