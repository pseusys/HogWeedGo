package com.ekdorn.hogweedgo.fragments

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity.RESULT_CANCELED
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Bundle
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts.*
import androidx.core.app.ActivityCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentContainerView
import androidx.navigation.fragment.findNavController
import com.ekdorn.hogweedgo.singles.PreferenceManager
import com.ekdorn.hogweedgo.R
import com.ekdorn.hogweedgo.utils.ResFragment
import com.ekdorn.hogweedgo.dataclasses.Coordinates
import com.ekdorn.hogweedgo.dataclasses.ReportWithID
import com.ekdorn.hogweedgo.views.ReportButton
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*
import com.google.android.material.bottomsheet.BottomSheetBehavior


class MapBearFragment: ResFragment(StartIntentSenderForResult::class, RequestMultiplePermissions::class), View.OnClickListener {
    private companion object KEYS {
        const val GET_LOCATION_ALLOWED = "IS_LOCATION_ALLOWED"
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private lateinit var locationRequest: LocationRequest

    var location: Location? = null

    private lateinit var reportButton: ReportButton
    private lateinit var bottomSheet: BottomSheetBehavior<View>

    override fun onCreateView (inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val box = inflater.inflate(R.layout.fragment_map_bear, container, false)

        reportButton = box.findViewById(R.id.map_bear_report_button)
        reportButton.setOnClickListener(this)

        val bottomSheetLayout = box.findViewById<FragmentContainerView>(R.id.map_bear_bottom_sheet)
        bottomSheet = BottomSheetBehavior.from(bottomSheetLayout)
        bottomSheet.state = BottomSheetBehavior.STATE_HIDDEN
        bottomSheet.addBottomSheetCallback(object : BottomSheetBehavior.BottomSheetCallback() {
            override fun onStateChanged(bottomSheet: View, newState: Int) {}
            override fun onSlide(bottomSheetView: View, slideOffset: Float) {
                if (slideOffset > 0) reportButton.animate().scaleX(1 - slideOffset).scaleY(1 - slideOffset).setDuration(0).start()
            }
        })

        prepareRequests()
        return box
    }

    private fun prepareRequests () {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(requireActivity())
        locationCallback = object : LocationCallback() {
            @SuppressLint("MissingPermission")
            override fun onLocationAvailability (p0: LocationAvailability?) {
                val available = p0?.isLocationAvailable == true
                reportButton.state = if (available) ReportButton.ReportButtonState.STATE_READY else ReportButton.ReportButtonState.STATE_NO_LOCATION
                getChildFrag(R.id.main_frragment)?.let { (it as MapFragment).mMap.isMyLocationEnabled = available }
            }
            override fun onLocationResult (p0: LocationResult?) {
                if (p0 != null) location = p0.lastLocation
            }
        }
        locationRequest = LocationRequest.create().apply {
            interval = 10000
            fastestInterval = 5000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        askForPermissions()
    }

    override fun onPause () {
        super.onPause()
        if (checkForPermissions(requireActivity())) fusedLocationClient.removeLocationUpdates(locationCallback)

    }

    @SuppressLint("MissingPermission")
    override fun onResume () {
        super.onResume()
        if (checkForPermissions(requireActivity())) fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
    }



    private fun checkForPermissions (context: Context): Boolean {
        return ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }

    private fun askForPermissions () {
        if (!checkForPermissions(requireActivity()) && PreferenceManager.getValue(GET_LOCATION_ALLOWED, true)) {
            launch(RequestMultiplePermissions::class, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)) {
                if (!it!!.containsValue(false)) askForLocation()
                else {
                    PreferenceManager.putValue(GET_LOCATION_ALLOWED, false)
                    reportButton.state = ReportButton.ReportButtonState.STATE_NO_PERMISSION
                }
            }
        } else if (checkForPermissions(requireActivity())) askForLocation()
    }

    private fun askForLocation () {
        val builder = LocationSettingsRequest.Builder().addLocationRequest(locationRequest)
        val client = LocationServices.getSettingsClient(requireActivity())
        val task = client.checkLocationSettings(builder.build())
        task.addOnSuccessListener {
            reportButton.state = ReportButton.ReportButtonState.STATE_READY
        }
        task.addOnFailureListener { exception ->
            if (exception is ResolvableApiException) launch(StartIntentSenderForResult::class, IntentSenderRequest.Builder(exception.resolution).build()) {
                if (it!!.resultCode == RESULT_CANCELED) reportButton.state = ReportButton.ReportButtonState.STATE_NO_LOCATION
                else reportButton.state = ReportButton.ReportButtonState.STATE_READY
            }
        }
    }



    @SuppressLint("MissingPermission")
    override fun onClick (v: View?) {
        if ((v != null) && (v is ReportButton)) {
            when (v.state) {
                ReportButton.ReportButtonState.STATE_NO_PERMISSION -> {
                    PreferenceManager.putValue(GET_LOCATION_ALLOWED, true)
                    askForPermissions()
                }
                ReportButton.ReportButtonState.STATE_NO_LOCATION -> askForLocation()
                ReportButton.ReportButtonState.STATE_READY ->
                    if (location != null) {
                        val coords = Coordinates(location!!.latitude, location!!.longitude)
                        val action = MapBearFragmentDirections.actionMapBearFragmentToEditInfoFragment(coords)
                        findNavController().navigate(action)
                    } else Toast.makeText(requireContext(), getString(R.string.app_no_location), Toast.LENGTH_SHORT).show()
            }
        }
    }

    fun getChildFrag (id: Int): Fragment? = childFragmentManager.findFragmentById(id)



    fun openBottomSheetForData (info: ReportWithID) {
        getChildFrag(R.id.map_bear_bottom_sheet)?.let {
            (it as ViewInfoFragment).setupContent(info).apply {
                post {
                    bottomSheet.setPeekHeight(this.height, true)
                    bottomSheet.state = BottomSheetBehavior.STATE_COLLAPSED
                }
            }
        }
    }

    fun closeBottomSheetForData () {
        bottomSheet.state = BottomSheetBehavior.STATE_HIDDEN
    }
}
