package com.ekdorn.hogweedgo.activities

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.CheckBox
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import com.ekdorn.hogweedgo.singles.Connector
import com.ekdorn.hogweedgo.R
import com.ekdorn.hogweedgo.singles.PreferenceManager
import com.ekdorn.hogweedgo.utils.getValuesFromViews
import com.ekdorn.hogweedgo.utils.setValuesToViews
import com.google.android.material.textfield.TextInputLayout

class AuthActivity: AppCompatActivity() {
    private var signInShowing = true
    private lateinit var root: ConstraintLayout

    override fun onCreate (savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_auth)
        PreferenceManager.init(this)

        root = findViewById(R.id.auth_container)
        val confirmation = findViewById<TextInputLayout>(R.id.auth_confirmation_layout)
        val send = findViewById<Button>(R.id.auth_send_button)
        send.setOnClickListener { send(send) }
        val check = findViewById<CheckBox>(R.id.auth_accept_checkbox)
        check.setOnCheckedChangeListener { _, isChecked ->
            send.isEnabled = isChecked
        }

        findViewById<Button>(R.id.auth_state_switch).setOnClickListener { switch(confirmation, send, check) }
    }

    private fun switch (confirmation: TextInputLayout, send: Button, check: CheckBox) {
        val views = arrayOf(R.id.auth_state_switch, R.id.auth_container_layout_description, R.id.auth_send_button)
        if (signInShowing) {
            val strings = arrayOf(getString(R.string.auth_state_switch_log_in), getString(R.string.auth_container_layout_description_log_in), getString(R.string.auth_send_button_log_in))
            setValuesToViews(strings.zip(views), root)
            confirmation.visibility = View.GONE
            check.visibility = View.INVISIBLE
            send.isEnabled = true
        } else {
            val strings = arrayOf(getString(R.string.auth_state_switch_sign_in), getString(R.string.auth_container_layout_description_sign_in), getString(R.string.auth_send_button_sign_in))
            setValuesToViews(strings.zip(views), root)
            confirmation.visibility = View.VISIBLE
            check.visibility = View.VISIBLE
            send.isEnabled = check.isChecked
        }
        signInShowing = !signInShowing
    }

    private fun send (send: Button) {
        val check = { id: Int, msg: String, checker: (String?) -> Boolean ->
            val view = root.findViewById<TextInputLayout>(id)
            val value = view.editText!!.text.toString()
            if (checker(value)) {
                view.error = msg
                null
            } else value
        }

        send.error = null

        if (signInShowing) {
            val email = check(R.id.auth_email_layout, getString(R.string.auth_error_email_length)) { str ->
                return@check str.isNullOrBlank() || (str.length < 5)
            }
            val password = check(R.id.auth_password_layout, getString(R.string.auth_error_password_length)) { str ->
                return@check str.isNullOrBlank() || (str.length < 5)
            }
            val confirmation = check(R.id.auth_confirmation_layout, getString(R.string.auth_error_confirmation_match)) { str ->
                return@check str.isNullOrBlank() || (str != password)
            }

            if ((email == null) || (password == null) || confirmation == null) return
            else Connector.createAccount(email, password).catch {
                Toast.makeText(this, it.localizedMessage, Toast.LENGTH_SHORT).show()
            }.then {
                PreferenceManager.setUserId(it)
                finish()
            }
        } else getValuesFromViews(arrayOf(R.id.auth_email_layout, R.id.auth_password_layout).zip(listOf(true, true)), root)?.also { map ->
            Connector.logIn(map[R.id.auth_email_layout]!!, map[R.id.auth_password_layout]!!).catch {
                Toast.makeText(this, it.localizedMessage, Toast.LENGTH_SHORT).show()
            }.then {
                PreferenceManager.setUserId(it)
                finish()
            }
        }
    }

    override fun onBackPressed() {
        finishAffinity()
    }
}
