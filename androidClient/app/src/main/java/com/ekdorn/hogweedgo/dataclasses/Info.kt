package com.ekdorn.hogweedgo.dataclasses

import android.content.Context
import android.graphics.BitmapFactory
import android.os.Parcelable
import com.ekdorn.hogweedgo.R
import com.google.android.libraries.maps.model.LatLng
import kotlinx.parcelize.Parcelize



enum class ReportStatus {
    RECEIVED, APPROVED;

    fun getResource() = when (this) {
        RECEIVED -> R.drawable.ic_status_received
        APPROVED -> R.drawable.ic_status_approved
    }
}

fun getStatusBitmaps(ctx: Context) = enumValues<ReportStatus>().map { BitmapFactory.decodeResource(ctx.resources, it.getResource()) }


@Parcelize
data class Coordinates (val lat: Double = -1.0, val long: Double = -1.0): Parcelable {
    constructor(latLng: LatLng) : this(latLng.latitude, latLng.longitude)
    override fun toString() = "%.5f°, %.5f°".format(lat, long)
}


@Parcelize
data class Report (
    var place: Coordinates = Coordinates(),
    var status: ReportStatus = ReportStatus.RECEIVED,
    var name: String = "",
    var subs: String = "",

    var tag: String = "",
    var date: Long = 0,
    var photos: List<String> = listOf(),
    var address: String? = null,
    var comment: String? = null
): Parcelable {
    fun place () = LatLng(this.place.lat, this.place.long)
}


@Parcelize
data class ReportWithID (val key: String, var info: Report): Parcelable
