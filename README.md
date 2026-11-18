# Sovann Marina Portfolio (Flutter Web + Supabase)

Tech: Flutter Web (website and animation), Supabase (database and login),
Supabase Storage (images), GitHub Pages (free hosting).

## Step 1 - Create the Flutter project shell
Install Flutter (flutter.dev), then run:

    flutter create sovann_portfolio --platforms web

Copy these items from this zip INTO that new folder, replacing existing files:
`lib/`, `pubspec.yaml`, `assets/`, `supabase_setup.sql`, `.github/`, `.gitignore`.

## Step 2 - Supabase
1. Create a project at supabase.com.
2. SQL Editor > New query > paste `supabase_setup.sql` > Run.
3. Authentication > Users > Add user (your email and a strong password). This is your admin account.
4. Authentication > Sign In / Providers > Email: turn OFF "Allow new users to sign up",
   so nobody else can become an admin.
5. Project Settings > API: copy the Project URL and the `anon public` key.

## Step 3 - Add keys
Open `lib/main.dart` and replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY`.
The anon key is safe to be public because of the security rules in the SQL file.
Never put the `service_role` key anywhere in this project.

## Step 4 - Your photo
Save your photo as `assets/photo.jpg`. Without it, the initials "SM" are shown.

## Step 5 - Run
    flutter pub get
    flutter run -d chrome

Click the lock icon, log in, then use the + icon to add projects, designs and certificates with images.
Hide birth date and ID numbers on certificates before uploading. Never upload your ID card.

## Step 6 - Publish on GitHub Pages
1. Create a public GitHub repository and push this project to the `main` branch.
2. Wait for the "Deploy to GitHub Pages" action to finish (Actions tab).
3. Settings > Pages > Source: "Deploy from a branch", Branch: `gh-pages`, folder `/ (root)`.
4. Your site: https://YOUR-USERNAME.github.io/REPOSITORY-NAME/
