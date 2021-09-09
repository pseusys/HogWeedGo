package com.ekdorn.hogweedgo.dataclasses

import android.net.Uri
import android.os.Parcelable
import kotlinx.parcelize.Parcelize


enum class UserRole { USER, ADMIN }


@Parcelize
data class User (
    val role: UserRole = UserRole.USER,

    var name: String = "",
    var photo: Uri = Uri.EMPTY,

    var verified: Boolean = true
): Parcelable
