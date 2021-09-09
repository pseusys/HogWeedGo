package com.ekdorn.hogweedgo.fragments

import android.graphics.Bitmap
import android.os.Bundle
import androidx.navigation.fragment.NavHostFragment.findNavController
import com.ekdorn.hogweedgo.dataclasses.Coordinates
import com.ekdorn.hogweedgo.dataclasses.ReportWithID
import com.ekdorn.hogweedgo.dataclasses.getStatusBitmaps
import com.ekdorn.hogweedgo.singles.Connector
import com.google.android.libraries.maps.GoogleMap
import com.google.android.libraries.maps.OnMapReadyCallback
import com.google.android.libraries.maps.SupportMapFragment
import com.google.android.libraries.maps.model.*
import java.util.*


class MapFragment: SupportMapFragment(), OnMapReadyCallback, GoogleMap.OnMapLongClickListener, GoogleMap.OnMarkerClickListener, GoogleMap.OnMapClickListener {
    lateinit var mMap: GoogleMap
    private val markers = ArrayList<Marker>()
    private lateinit var markerIcons: List<BitmapDescriptor>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        markerIcons = getStatusBitmaps(requireContext()).map {
            BitmapDescriptorFactory.fromBitmap(Bitmap.createScaledBitmap(it, 73, 108, false))
        }
        this.getMapAsync(this)
    }

    /*override fun onInflate(context: Context, attrs: AttributeSet, savedInstanceState: Bundle?) {
        super.onInflate(context, attrs, savedInstanceState)
        Log.e("TAG", "onInflate: ${savedInstanceState}")
        for (i in 0 until attrs.attributeCount)
            Log.e("TAG", "onInflate: ${attrs.getAttributeName(i)}, ${attrs.getAttributeValue(i)}")
    }*/

    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap
        mMap.setOnMarkerClickListener(this)
        mMap.setOnMapClickListener(this)
        mMap.setOnMapLongClickListener(this)

        val createMarker: (ReportWithID) -> Marker = { i ->
            mMap.addMarker(MarkerOptions().position(i.info.place()).title(i.info.tag).icon(markerIcons[i.info.status.ordinal])).setInfo(i)
        }
        val removeMarker: (Marker) -> Marker = { m ->
            m.also { it.remove() }
        }

        Connector.connectMap({ i ->
            markers.add(createMarker(i))
        }, { k ->
            markers.first { it.getInfo().key == k }.apply {
                markers.remove(removeMarker(this))
            }
        })

        mMap.uiSettings.isZoomControlsEnabled = false
        mMap.uiSettings.isMapToolbarEnabled = false
        mMap.isIndoorEnabled = false
    }

    override fun onDestroy() {
        super.onDestroy()
        Connector.disconnectMap()
    }



    override fun onMapLongClick(latLng: LatLng) {
        val action = MapBearFragmentDirections.actionMapBearFragmentToEditInfoFragment(Coordinates(latLng))
        findNavController(this).navigate(action)
    }

    override fun onMarkerClick(marker: Marker): Boolean {
        (requireParentFragment() as MapBearFragment).openBottomSheetForData(marker.getInfo())
        return false
    }

    override fun onMapClick(p0: LatLng?) = (requireParentFragment() as MapBearFragment).closeBottomSheetForData()



    private fun Marker.setInfo(info: ReportWithID): Marker {
        this.tag = info
        return this
    }

    private fun Marker.getInfo(): ReportWithID {
        return this.tag as ReportWithID
    }
}
