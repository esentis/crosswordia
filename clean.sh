echo "Updating dependencies"
fvm flutter clean
fvm flutter pub get
cd ios
echo "Removing Podfile.lock"
rm Podfile.lock
arch -x86_64 pod install --repo-update
clear