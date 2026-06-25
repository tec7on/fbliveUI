package com.tec7on.fbliveui.ui.splash

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.tec7on.fbliveui.MainActivity
import com.tec7on.fbliveui.R
import com.tec7on.fbliveui.ui.theme.Accent
import com.tec7on.fbliveui.ui.theme.FbliveUITheme
import kotlinx.coroutines.delay

class SplashActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            FbliveUITheme {
                SplashScreen(
                    onFinished = {
                        startActivity(Intent(this, MainActivity::class.java))
                        finish()
                        overridePendingTransition(
                            android.R.anim.fade_in,
                            android.R.anim.fade_out
                        )
                    }
                )
            }
        }
    }
}

@Composable
fun SplashScreen(onFinished: () -> Unit) {

    // ── Animation states ──────────────────────────────────────
    var startAnim by remember { mutableStateOf(false) }

    // Logo: scale + alpha  (enter)
    val logoScale by animateFloatAsState(
        targetValue = if (startAnim) 1f else 0.6f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness    = Spring.StiffnessLow
        ),
        label = "logoScale"
    )
    val logoAlpha by animateFloatAsState(
        targetValue  = if (startAnim) 1f else 0f,
        animationSpec = tween(700, easing = EaseOutCubic),
        label = "logoAlpha"
    )

    // Tagline: slide up + alpha
    val tagAlpha by animateFloatAsState(
        targetValue  = if (startAnim) 1f else 0f,
        animationSpec = tween(800, delayMillis = 400, easing = EaseOutCubic),
        label = "tagAlpha"
    )
    val tagOffset by animateFloatAsState(
        targetValue  = if (startAnim) 0f else 30f,
        animationSpec = tween(700, delayMillis = 400, easing = EaseOutCubic),
        label = "tagOffset"
    )

    // Credit line: appear last
    val creditAlpha by animateFloatAsState(
        targetValue  = if (startAnim) 1f else 0f,
        animationSpec = tween(600, delayMillis = 800, easing = EaseOutCubic),
        label = "creditAlpha"
    )

    // Exit: everything fades out
    var exitAnim by remember { mutableStateOf(false) }
    val screenAlpha by animateFloatAsState(
        targetValue  = if (exitAnim) 0f else 1f,
        animationSpec = tween(500, easing = EaseInCubic),
        label = "screenAlpha"
    )

    // ── Timer ─────────────────────────────────────────────────
    LaunchedEffect(Unit) {
        startAnim = true
        delay(2_600)
        exitAnim  = true
        delay(520)
        onFinished()
    }

    // ── Background ────────────────────────────────────────────
    val bg = MaterialTheme.colorScheme.background
    val onBg = MaterialTheme.colorScheme.onBackground

    Box(
        modifier = Modifier
            .fillMaxSize()
            .alpha(screenAlpha)
            .background(bg),
        contentAlignment = Alignment.Center
    ) {

        // ── Center column ─────────────────────────────────────
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {

            // Logo image
            Image(
                painter = painterResource(id = R.drawable.ic_splash),
                contentDescription = "App Logo",
                modifier = Modifier
                    .size(140.dp)
                    .scale(logoScale)
                    .alpha(logoAlpha)
            )

            Spacer(modifier = Modifier.height(24.dp))

            // App name
            Text(
                text        = stringResource(R.string.app_name),
                fontSize    = 30.sp,
                fontWeight  = FontWeight.Bold,
                color       = onBg,
                letterSpacing = 2.sp,
                modifier    = Modifier.alpha(logoAlpha)
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Tagline
            Text(
                text      = stringResource(R.string.splash_tagline),
                fontSize  = 14.sp,
                color     = onBg.copy(alpha = 0.55f),
                textAlign = TextAlign.Center,
                modifier  = Modifier
                    .alpha(tagAlpha)
                    .offset(y = tagOffset.dp)
            )
        }

        // ── Bottom credit ─────────────────────────────────────
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 40.dp)
                .alpha(creditAlpha)
        ) {
            Text(
                text     = stringResource(R.string.splash_credit),
                fontSize = 12.sp,
                color    = onBg.copy(alpha = 0.45f)
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text       = "Tec7on",
                fontSize   = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color      = Accent   // always green regardless of theme
            )
        }
    }
}
