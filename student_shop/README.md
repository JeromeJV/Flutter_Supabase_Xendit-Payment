# Student Shop

A Flutter student-store app backed by Supabase, with Xendit checkout and order
history.

## Run the app

Install Flutter dependencies:

```sh
flutter pub get
```

In the Supabase dashboard, open **Project Settings → API** and copy the Project
URL and the anon/public key. Save them in the ignored `supabase.local.json`
file for local development, then start the app with:

```sh
flutter run --dart-define-from-file=supabase.local.json
```

Only use the anon/public key in this client app. Never include the Supabase
service-role key or Xendit secret key in Flutter code or build arguments.

The Supabase project must provide:

- A `products` table with `id`, `name`, `price`, and optional `image_url`
  columns, readable by the app's anon role.
- An `orders` table with `external_id`, `product_name`, `amount`, `status`, and
  `created_at` columns, readable by the app's anon role.
- A deployed `create-invoice` Edge Function that securely creates Xendit
  invoices and returns `invoice_url` and `external_id`. Keep Xendit credentials
  in the Edge Function's server-side secrets.
- A Xendit webhook that updates the matching order status after payment.

The app displays a setup screen instead of crashing if the Supabase URL or
public key has not been configured. Without credentials, the app opens a
clearly labeled demo catalog; its Buy Now buttons do not place orders or
process payments.

## Android APK

Android internet permission is enabled in
`android/app/src/main/AndroidManifest.xml`. Build a release APK with:

```sh
flutter build apk --release --dart-define-from-file=supabase.local.json
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.
