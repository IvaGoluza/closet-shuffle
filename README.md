# Closet Shuffle

Snap your clothes, shuffle the fits, save the cute ones. Each person logs in with an email and password and sees the same closet on their phone and laptop.

**Cost: $0.** The page is hosted on GitHub Pages, and the logins, photos and outfits are stored in Supabase's free plan.

## What's in this folder

| File | What it is |
|---|---|
| `index.html` | The whole app |
| `config.js` | Where you paste your two Supabase values |
| `supabase-setup.sql` | Creates the database tables and the private photo storage |
| `.github/workflows/keepalive.yml` | Pings Supabase every 3 days so the free project never pauses |

Setup takes about 20 minutes, done once.

---

## Step 1: Create the Supabase project

1. Go to **supabase.com** and sign up (free).
2. Click **New project**. Give it a name like `closet-shuffle`, set a database password (save it somewhere), and pick the region closest to you. Choose the **Free** plan.
3. Wait a minute or two while it sets up.
4. In the left sidebar, open **SQL Editor** and click **New query**.
5. Open `supabase-setup.sql`, copy everything, paste it in, and click **Run**. You should see "Success. No rows returned."
6. Go to **Project Settings → API Keys** (or **Settings → API** on older dashboards) and copy two things:
   - the **Project URL**, which looks like `https://abcdefgh.supabase.co`
   - the **Publishable key** (on older projects it's called the **anon public** key)

   Never use the **secret** or **service_role** key here.

## Step 2: Paste the values into `config.js`

Open `config.js` in any text editor and replace the two placeholder values:

```js
window.CLOSET_CONFIG = {
  supabaseUrl: "https://abcdefgh.supabase.co",
  supabaseKey: "sb_publishable_…"
};
```

These values are safe to publish. They only let someone reach the login screen, and the rules from step 1 make sure each person can only see their own clothes.

## Step 3: Put the site on GitHub Pages

1. Sign up at **github.com** (free) if you don't have an account.
2. Click **+ → New repository**. Name it `closet-shuffle`, keep it **Public** (free Pages needs a public repo; the photos are not stored here), and click **Create repository**.
3. Click **uploading an existing file**, drag in `index.html`, `config.js`, `supabase-setup.sql` and `README.md`, then click **Commit changes**.
4. Add the keep-awake file. Click **Add file → Create new file**, type the name `.github/workflows/keepalive.yml` (the slashes create the folders), paste the contents of that file, and commit.
5. Go to **Settings → Pages**. Under "Build and deployment", set **Source: Deploy from a branch**, **Branch: main**, folder **/ (root)**, and click **Save**.
6. After a minute, the page shows your link: `https://YOUR-USERNAME.github.io/closet-shuffle/`

## Step 4: Tell Supabase your site's address

This makes the confirm-email and reset-password links open your site.

In Supabase, go to **Authentication → URL Configuration**:
- **Site URL:** `https://YOUR-USERNAME.github.io/closet-shuffle/`
- **Redirect URLs:** add the same address

Optional: if confirmation emails are a hassle, go to **Authentication → Sign In / Providers → Email** and turn off **Confirm email**. Supabase's built-in email sender only sends a few emails per hour, which is plenty for a couple of friends.

## Step 5: Keep it from pausing

Free Supabase projects pause after a week with no activity. The workflow you added pings it every 3 days.

1. In your GitHub repo, go to **Settings → Secrets and variables → Actions → New repository secret** and add:
   - `SUPABASE_URL`: your Project URL
   - `SUPABASE_KEY`: your publishable (anon) key
2. Open the **Actions** tab, enable workflows if GitHub asks, click **Keep Supabase awake → Run workflow**, and check that it turns green.

GitHub stops scheduled workflows in a repo that has had no changes for 60 days, and emails you first. One click on **Enable workflow** in the Actions tab turns it back on. If the project ever does pause, nothing is lost: open your Supabase dashboard and click **Restore project**.

## Step 6: Sign up and lock the door

1. Open the site, tap **Create an account**, and send the link to your friend so she can do the same.
2. Once everyone who should use it has an account, go to Supabase **Authentication → Sign In / Providers** and turn off **Allow new users to sign up**. Strangers who find the link can then no longer create accounts and use up your free storage.

**On iPhone:** open the site in Safari, tap **Share → Add to Home Screen**, and it opens like an app.

---

## How the syncing works

- Photos are shrunk to about 720 px and saved as small WebP files (PNG or JPEG on browsers that can't make WebP). That comes to roughly 50 to 150 KB each, so the free 1 GB holds several thousand pieces.
- Each phone or laptop keeps its own copy of the photos. Opening the app downloads only the list of items (a few KB) plus any photos that are new to that device. This keeps downloads far below the free 5 GB a month.
- If the device copy gets wiped (Safari sometimes clears unused sites), the app downloads the photos again. Nothing is lost.
- **Log out** also deletes the photos from that device, which is good for shared computers.

## Who can see the photos

- Other users of the site can't see each other's photos. The storage bucket is private, and every photo sits in a folder only its owner can read.
- Whoever owns the Supabase project (you) can see all files in the Supabase dashboard. Let your friend know that.

## Using Vercel instead of GitHub Pages

Do steps 1 and 2, push the files to a GitHub repo, then on **vercel.com** click **Add New → Project**, import the repo, leave every build setting empty, and click **Deploy**. Use the `https://….vercel.app` address in step 4. The keep-awake workflow still runs from GitHub.
