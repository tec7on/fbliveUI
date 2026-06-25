#!/data/data/com.termux/files/usr/bin/bash
set -e

RES="app/src/main/res"
TMP="$TMPDIR/icons"
mkdir -p $TMP

# crop مربع
magick app_icon.png -gravity center \
  -extent "$(magick app_icon.png -format "%[fx:min(w,h)]x%[fx:min(w,h)]" info:)" \
  $TMP/sq.png

# ─── ic_launcher ─────────────────────────────────────────────────
magick $TMP/sq.png -resize 48x48   $RES/mipmap-mdpi/ic_launcher.png
magick $TMP/sq.png -resize 72x72   $RES/mipmap-hdpi/ic_launcher.png
magick $TMP/sq.png -resize 96x96   $RES/mipmap-xhdpi/ic_launcher.png
magick $TMP/sq.png -resize 144x144 $RES/mipmap-xxhdpi/ic_launcher.png
magick $TMP/sq.png -resize 192x192 $RES/mipmap-xxxhdpi/ic_launcher.png

# ─── ic_launcher_round دائري ─────────────────────────────────────
for entry in "48 mdpi" "72 hdpi" "96 xhdpi" "144 xxhdpi" "192 xxxhdpi"; do
  SIZE=$(echo $entry | cut -d' ' -f1)
  DPI=$(echo $entry | cut -d' ' -f2)
  HALF=$((SIZE/2))
  magick $TMP/sq.png -resize ${SIZE}x${SIZE} \
    \( +clone -alpha extract \
       -draw "fill black rectangle 0,0 ${SIZE},${SIZE} fill white circle ${HALF},${HALF} ${HALF},0" \
    \) -alpha off -compose CopyOpacity -composite \
    $RES/mipmap-${DPI}/ic_launcher_round.png
done

# ─── drawable foreground ─────────────────────────────────────────
magick $TMP/sq.png -resize 72x72 -gravity center -background none \
  -extent 108x108 $RES/drawable/ic_launcher_foreground.png

cat > $RES/drawable/ic_launcher_background.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#29d958"/>
</shape>
EOF

# ─── adaptive icons ──────────────────────────────────────────────
for name in ic_launcher ic_launcher_round; do
cat > $RES/mipmap-anydpi-v26/${name}.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
EOF
done

# ─── AndroidManifest (فقط لو مو موجود) ──────────────────────────
if ! grep -q "android:icon" app/src/main/AndroidManifest.xml; then
  sed -i 's|android:label="@string/app_name"|android:label="@string/app_name"\n        android:icon="@mipmap/ic_launcher"\n        android:roundIcon="@mipmap/ic_launcher_round"|' \
    app/src/main/AndroidManifest.xml
fi

# ─── push ────────────────────────────────────────────────────────
git add .
git commit -m "feat: add proper app icons"
git push

echo "✅ تم! راقب GitHub Actions"
