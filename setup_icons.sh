#!/data/data/com.termux/files/usr/bin/bash

set -e

RES="app/src/main/res"
DRAWABLE="$RES/drawable"

pkg install -y imagemagick 2>/dev/null

# ─── mipmap PNGs ─────────────────────────────────────────────────
convert app_icon.png -resize 48x48   $RES/mipmap-mdpi/ic_launcher.png
convert app_icon.png -resize 72x72   $RES/mipmap-hdpi/ic_launcher.png
convert app_icon.png -resize 96x96   $RES/mipmap-xhdpi/ic_launcher.png
convert app_icon.png -resize 144x144 $RES/mipmap-xxhdpi/ic_launcher.png
convert app_icon.png -resize 192x192 $RES/mipmap-xxxhdpi/ic_launcher.png

convert app_icon.png -resize 48x48   $RES/mipmap-mdpi/ic_launcher_round.png
convert app_icon.png -resize 72x72   $RES/mipmap-hdpi/ic_launcher_round.png
convert app_icon.png -resize 96x96   $RES/mipmap-xhdpi/ic_launcher_round.png
convert app_icon.png -resize 144x144 $RES/mipmap-xxhdpi/ic_launcher_round.png
convert app_icon.png -resize 192x192 $RES/mipmap-xxxhdpi/ic_launcher_round.png

# ─── adaptive icon XMLs ──────────────────────────────────────────
cat > $RES/mipmap-anydpi-v26/ic_launcher.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

cat > $RES/mipmap-anydpi-v26/ic_launcher_round.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF

# ─── drawable background (accent color) ──────────────────────────
cat > $DRAWABLE/ic_launcher_background.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#29d958"/>
</shape>
EOF

# ─── drawable foreground (أيقونة PNG كـ vector wrapper) ──────────
convert app_icon.png -resize 108x108 $DRAWABLE/ic_launcher_foreground.png

# ─── AndroidManifest: أضف ic_launcher ───────────────────────────
sed -i 's/android:theme="@style\/Theme.FbliveUI"/android:theme="@style\/Theme.FbliveUI"\n        android:icon="@mipmap\/ic_launcher"\n        android:roundIcon="@mipmap\/ic_launcher_round"/' \
    app/src/main/AndroidManifest.xml

# ─── git push ────────────────────────────────────────────────────
git add .
git commit -m "feat: add app icon and adaptive icons"
git push

echo ""
echo "✅ تم! البناء بدأ تلقائياً في GitHub Actions"
