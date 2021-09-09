package com.ekdorn.hogweedgo.activities

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.MenuItem
import android.widget.ImageView
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.activity.viewModels
import androidx.appcompat.app.ActionBarDrawerToggle
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.drawerlayout.widget.DrawerLayout
import androidx.navigation.NavController
import androidx.navigation.Navigation.findNavController
import com.ekdorn.hogweedgo.singles.PreferenceManager
import com.ekdorn.hogweedgo.R
import com.ekdorn.hogweedgo.fragments.MapBearFragmentDirections
import com.ekdorn.hogweedgo.models.UserModel
import com.ekdorn.hogweedgo.utils.ResActivity
import com.ekdorn.hogweedgo.utils.loadProfilePic
import com.google.android.material.appbar.MaterialToolbar
import com.google.android.material.navigation.NavigationView


class MainActivity: ResActivity(StartActivityForResult::class), NavigationView.OnNavigationItemSelectedListener {
    private var clearLaunch: Boolean = true

    private lateinit var root: DrawerLayout
    private lateinit var rootListener: ActionBarDrawerToggle
    private lateinit var controller: NavController

    override fun onCreate (savedInstanceState: Bundle?) {
        PreferenceManager.init(this)

        clearLaunch = PreferenceManager.getUserId() != null
        if (!clearLaunch) {
            super.onCreate(savedInstanceState)
            launch(StartActivityForResult::class, Intent(this, AuthActivity::class.java)) {
                recreate()
            }
        } else {
            setTheme(R.style.AppTheme)
            super.onCreate(savedInstanceState)
            setContentView(R.layout.activity_main)

            findViewById<NavigationView>(R.id.navigation).setNavigationItemSelectedListener(this)
            val toolbar = findViewById<MaterialToolbar>(R.id.topAppBar).apply { setNavigationOnClickListener { root.open() } }

            setSupportActionBar(toolbar)
            root = findViewById(R.id.drawerLayout)
            rootListener = ActionBarDrawerToggle(this, root, toolbar, R.string.toolbar_open, R.string.toolbar_close)
            root.addDrawerListener(rootListener)
            rootListener.syncState()
            rootListener.setToolbarNavigationClickListener { onBackPressed() }

            var headerRoot: ConstraintLayout
            findViewById<NavigationView>(R.id.navigation).apply {
                setNavigationItemSelectedListener(this@MainActivity)
                headerRoot = getHeaderView(0) as ConstraintLayout
            }

            val userName = headerRoot.findViewById<TextView>(R.id.header_user_name)
            val userPicture = headerRoot.findViewById<ImageView>(R.id.header_user_picture)
            val model: UserModel by viewModels()
            model.getUser().observe(this, {
                userName.text = it.name
                userPicture?.loadProfilePic(this, it.photo)
            })
        }
    }

    override fun onStart() {
        super.onStart()
        if (clearLaunch) controller = findNavController(findViewById(R.id.main_fragment))
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        root.close()
        if (controller.currentDestination!!.id != controller.graph.startDestination) controller.navigateUp()
        when (item.itemId) {
            R.id.nav_menu_settings -> controller.navigate(MapBearFragmentDirections.actionMapBearFragmentToSettingsFragment())
            R.id.nav_menu_feedback -> run {
                val int = Intent(Intent.ACTION_VIEW, Uri.parse("https://t.me/pseusys"))
                launch(StartActivityForResult::class, int)
            }
        }
        return true
    }

    override fun onBackPressed() {
        if (controller.currentDestination!!.id != controller.graph.startDestination) controller.navigateUp()
        else finishAffinity()
    }


    fun showNavigation(show: Boolean) {
        if (show) {
            root.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED)
            supportActionBar?.setDisplayHomeAsUpEnabled(false)
            rootListener.isDrawerIndicatorEnabled = true
        } else {
            root.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED)
            rootListener.isDrawerIndicatorEnabled = false
            supportActionBar?.setDisplayHomeAsUpEnabled(true)
        }
    }
}
