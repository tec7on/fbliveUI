#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  fbliveUI — Splash Screen Setup
#  Run from: /sdcard/project/fbliveUI
#  Usage: bash setup_splash.sh
# ============================================================

set -e
ACCENT="#29D958"
PROJECT_DIR="$(pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   fbliveUI — Splash Setup  by Tec7on ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Verify we're in the right place ──────────────────────
if [ ! -f "settings.gradle.kts" ]; then
  echo "❌  Run this script from the project root (where settings.gradle.kts is)"
  exit 1
fi

echo "✅  Project root confirmed: $PROJECT_DIR"

# ── 2. Create directories ────────────────────────────────────
mkdir -p app/src/main/java/com/tec7on/fbliveui/ui/splash
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/values-ar

echo "✅  Directories ready"

# ── 3. strings.xml  (English — default) ─────────────────────
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">fbliveUI</string>
    <string name="splash_tagline">Crafted with passion</string>
    <string name="splash_credit">UI Template by</string>
</resources>
EOF

# ── 4. strings.xml  (Arabic — optional) ─────────────────────
cat > app/src/main/res/values-ar/strings.xml << 'EOF'
<resources>
    <string name="app_name">fbliveUI</string>
    <string name="splash_tagline">مصنوع بشغف</string>
    <string name="splash_credit">قالب واجهة بقلم</string>
</resources>
EOF

echo "✅  Strings (EN + AR) written"

# ── 5. SplashActivity.kt ─────────────────────────────────────
cat > app/src/main/java/com/tec7on/fbliveui/ui/splash/SplashActivity.kt << 'EOF'
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
EOF

echo "✅  SplashActivity.kt written"

# ── 6. Patch AndroidManifest.xml ─────────────────────────────
#    • Add SplashActivity as MAIN/LAUNCHER
#    • Move MainActivity (no intent-filter needed)
#    • Add screenOrientation + theme override on splash

MANIFEST="app/src/main/AndroidManifest.xml"

cat > "$MANIFEST" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:label="@string/app_name"
        android:theme="@style/Theme.FbliveUI"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true">

        <!-- ── Splash (entry point) ── -->
        <activity
            android:name=".ui.splash.SplashActivity"
            android:exported="true"
            android:screenOrientation="portrait"
            android:theme="@style/Theme.FbliveUI.Splash">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- ── Main screen ── -->
        <activity
            android:name=".MainActivity"
            android:exported="false"
            android:windowSoftInputMode="adjustResize" />

    </application>
</manifest>
EOF

echo "✅  AndroidManifest.xml updated"

# ── 7. themes.xml  (add Splash theme — no ActionBar) ─────────
cat > app/src/main/res/values/themes.xml << 'EOF'
<resources>
    <style name="Theme.FbliveUI" parent="Theme.Material3.DayNight.NoActionBar" />

    <style name="Theme.FbliveUI.Splash" parent="Theme.FbliveUI">
        <item name="android:windowFullscreen">true</item>
        <item name="android:windowBackground">@android:color/transparent</item>
    </style>
</resources>
EOF

echo "✅  themes.xml updated"

# ── 8. Commit & push ─────────────────────────────────────────
echo ""
echo "📦  Staging changes for git…"
git add \
  app/src/main/java/com/tec7on/fbliveui/ui/splash/SplashActivity.kt \
  app/src/main/res/values/strings.xml \
  app/src/main/res/values-ar/strings.xml \
  app/src/main/AndroidManifest.xml \
  app/src/main/res/values/themes.xml

git commit -m "feat: add professional animated splash screen

- SplashActivity with scale+bounce logo animation
- Slide-up tagline with fade
- Smooth fade-out exit transition
- Light/Dark theme support (bg reacts to system, text inverts)
- Accent color #29D958 used for Tec7on credit (always green)
- Bilingual strings: EN default + AR optional (values-ar)
- ic_splash.png used as logo
- Credit: UI Template by Tec7on"

echo ""
echo "🚀  Pushing to origin/main…"
git push origin main

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  ✅  Done! GitHub Actions will build the APK  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Check Actions tab: https://github.com/<your-repo>/actions"
echo ""
