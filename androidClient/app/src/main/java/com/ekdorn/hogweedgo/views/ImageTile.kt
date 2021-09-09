package com.ekdorn.hogweedgo.views

import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.activity.result.contract.ActivityResultContracts.*
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.FileProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.ekdorn.hogweedgo.*
import com.ekdorn.hogweedgo.activities.FullScreenActivity
import com.ekdorn.hogweedgo.utils.ResFragment
import com.google.android.material.floatingactionbutton.FloatingActionButton
import java.io.File
import kotlin.math.min



private class ImageTileViewHolder (private val ctx: ResFragment, root: ConstraintLayout): RecyclerView.ViewHolder(root) {
    private lateinit var pic: Uri
    val img: ImageView = root.findViewById(R.id.picture_image)
    private val fab: FloatingActionButton = root.findViewById(R.id.image_tile_close_button)

    fun init (deleteAction: ((Uri) -> Unit)?): ImageTileViewHolder {
        if (deleteAction != null) fab.setOnClickListener { deleteAction(pic) }
        else {
            fab.visibility = View.GONE
            img.setOnClickListener { zoom() }
        }
        return this
    }

    fun initLast (takeAction: () -> Unit, pickAction: () -> Unit): ImageTileViewHolder {
        img.setImageResource(R.drawable.camera_black)
        img.setOnClickListener { takeAction() }
        fab.setImageResource(R.drawable.ic_add_white)
        fab.setOnClickListener { pickAction() }
        return this
    }

    fun setPic (picture: Uri) {
        this.pic = picture
        Glide.with(ctx).load(pic).error(R.drawable.no_image_grey).placeholder(R.drawable.image_grey).into(img)
    }

    private fun zoom () {
        ctx.launch(StartActivityForResult::class, Intent(ctx.requireActivity(), FullScreenActivity::class.java).apply { this.putExtra(FullScreenActivity.BITMAP, pic) })
    }
}


private class ImageTileAdapter (private val ctx: ResFragment, private val editable: Boolean): RecyclerView.Adapter<ImageTileViewHolder>() {
    private companion object CONSTANTS {
        const val TILE_MAX = 10
    }

    private lateinit var recycler: RecyclerView
    private var dataSet: MutableList<Pair<Uri, Boolean>> = mutableListOf()

    private fun takeImage () {
        val activity = ctx.requireActivity()
        val file = File.createTempFile("image", null, activity.externalCacheDir)
        val uri = FileProvider.getUriForFile(activity, activity.packageName + ".provider", file)
        ctx.launch(TakePicture::class, uri) { saved ->
            if (saved == true) addImage(uri, true)
        }
    }

    private fun pickImage () {
        ctx.launch(GetContent::class, "image/*") { picked ->
            if (picked != null) addImage(picked, false)
        }
    }

    private fun addImage (uri: Uri, temp: Boolean) {
        dataSet.add(Pair(uri, temp))
        notifyItemInserted(dataSet.size - 1)
        if (dataSet.size == TILE_MAX) notifyItemRemoved(dataSet.size)
        else recycler.scrollToPosition(dataSet.size)
    }

    private fun removeImage (uri: Uri) {
        if (dataSet.size == TILE_MAX) notifyItemInserted(dataSet.size)
        val pos = dataSet.indexOfFirst{ it.first === uri }
        dataSet.removeAt(pos)
        notifyItemRemoved(pos)
    }

    fun addImages (preset: List<Uri>) {
        dataSet.addAll(preset.map { Pair(it, false) })
        notifyDataSetChanged()
    }

    // Create new views (invoked by the layout manager)
    override fun onCreateViewHolder (viewGroup: ViewGroup, viewType: Int): ImageTileViewHolder {
        val tile = LayoutInflater.from(viewGroup.context).inflate(R.layout.view_image_tile, viewGroup, false) as ConstraintLayout
        return if (viewType == -1) ImageTileViewHolder(ctx, tile).initLast(::takeImage, ::pickImage)
        else ImageTileViewHolder(ctx, tile).init(if (editable) ::removeImage else null)
    }

    // Replace the contents of a view (invoked by the layout manager)
    override fun onBindViewHolder (holder: ImageTileViewHolder, position: Int) = if (position != dataSet.size) holder.setPic(dataSet[position].first) else Unit

    // Return the size of your dataSet (invoked by the layout manager)
    override fun getItemCount () = min(if (editable) dataSet.size + 1 else dataSet.size, TILE_MAX)

    override fun getItemViewType (position: Int) = if (position == dataSet.size) -1 else 0

    override fun onAttachedToRecyclerView (recyclerView: RecyclerView) {
        super.onAttachedToRecyclerView(recyclerView)
        recycler = recyclerView
    }

    override fun onViewRecycled(holder: ImageTileViewHolder) {
        super.onViewRecycled(holder)
        Glide.with(ctx).clear(holder.img)
    }

    fun checkout () = dataSet.map { it.first }

    fun finalize () = dataSet.forEach { pair -> if (pair.second) pair.first.path?.let { File(it).deleteOnExit() } }
}


fun RecyclerView.setup (ctx: ResFragment, preset: List<String>?, editable: Boolean) {
    LinearLayoutManager(ctx.requireContext()).also {
        it.orientation = LinearLayoutManager.HORIZONTAL
        this.layoutManager = it
    }

    ImageTileAdapter(ctx, editable).also {
        if (preset != null) it.addImages(preset.map { uri -> Uri.parse(uri) })
        this.adapter = it
    }
}

fun RecyclerView.checkout () = (this.adapter as ImageTileAdapter).checkout()

fun RecyclerView.finalize () = (this.adapter as ImageTileAdapter).finalize()
