# Learn Laravel Kiswahili API

Laravel 13 REST API with public learning, Sanctum community accounts, an owner
admin panel, quizzes, progress tracking, and realtime chat via Laravel Reverb's
Pusher-compatible WebSocket protocol.

Profile photos are validated as JPG, PNG, or WebP up to 5 MB and stored on the
public disk. The Flutter app loads the chat alert from
`/api/v1/notification-sound`.

## Start locally

```bash
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
php artisan reverb:start --host=0.0.0.0 --port=8080
```

Demo account:

- Email: `demo@learnlaravel.co.tz`
- Password: `password123`

Owner admin:

- Username: `rogerscharleseugen`
- Password: `roger123`

API routes are under `/api/v1`. Protected requests must send:

```text
Authorization: Bearer YOUR_TOKEN
Accept: application/json
```

The Android emulator reaches the API at `http://10.0.2.2:8000/api/v1` and
Reverb at `ws://10.0.2.2:8080`.

Guests can browse the landing page, topics, and lessons. Authentication is only
required for quiz attempts, saved progress, community chat, and admin routes.
