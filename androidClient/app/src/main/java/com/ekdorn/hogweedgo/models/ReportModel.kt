package com.ekdorn.hogweedgo.models

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.ekdorn.hogweedgo.dataclasses.ReportWithID
import java.util.ArrayList

class ReportModel: ViewModel() {
    private val information: MutableLiveData<List<ReportWithID>> by lazy {
        MutableLiveData<List<ReportWithID>>().also {
            loadInformation()
        }
    }

    fun getInformation (): LiveData<List<ReportWithID>> = information

    private fun loadInformation () {
        information.value = ArrayList<ReportWithID>()
    }
}
