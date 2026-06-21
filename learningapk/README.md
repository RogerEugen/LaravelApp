# Learn Laravel Kiswahili Mobile

Flutter client with a public Laravel introduction slider, free guest lessons,
community authentication, quizzes, progress, owner administration, and
realtime user-admin chat. It supports Android 7.0 (API 24) and newer.

The first launch language is English. Users can switch between English and
Kiswahili from Profile, and the preference is saved on the device. Signed-in
users can upload a profile picture from the gallery; admins see it in user and
chat screens. Incoming Reverb messages play the backend notification sound.

## Run

Start both Laravel services first:

```bash
cd ../LearningApp
php artisan serve --host=0.0.0.0 --port=8000
php artisan reverb:start --host=0.0.0.0 --port=8080
```

Then run Flutter:

```bash
flutter pub get
flutter run
```

The default API URL works on the Android emulator:

```text
http://10.0.2.2:8000/api/v1
```

For a physical phone, use your computer's LAN address:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

The phone and computer must be on the same network, and Laravel should run
with `--host=0.0.0.0`. Set `REVERB_PUBLIC_HOST` in Laravel's `.env` to the
computer LAN IP for physical-phone realtime chat.

Admin login:

```text
rogerscharleseugen
roger123
```
