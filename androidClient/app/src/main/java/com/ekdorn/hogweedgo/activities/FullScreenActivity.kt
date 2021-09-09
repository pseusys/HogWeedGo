package com.ekdorn.hogweedgo.activities

import android.net.Uri
import android.os.Bundle
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.bumptech.glide.Glide
import com.ekdorn.hogweedgo.R


class FullScreenActivity: AppCompatActivity() {
    companion object CONSTANTS {
        const val BITMAP = "bitmap"
    }

    override fun onCreate (savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_fullscreen)
        (intent.getParcelableExtra(BITMAP) as Uri?)?.also {
            Glide.with(this).load(it).into(findViewById(R.id.zoom))
        }
    }

    override fun onWindowFocusChanged (hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, findViewById<ImageView>(R.id.root)).let {
            it.hide(WindowInsetsCompat.Type.systemBars())
            it.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }
}
