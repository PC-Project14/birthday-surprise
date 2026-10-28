# Birthday Surprise Studio — customer orders + admin publishing

## Files
- `index.html`: public customer order form, based on your current dark starry design.
- `admin.html`: admin sign-in, order review, and publish-link tool.
- `surprise.html`: birthday recipient page opened by the unique token link.
- `supabase-setup.sql`: database, RLS, private photo storage, and public-link RPC setup.

## Important setup steps
1. In `supabase-setup.sql`, replace both occurrences of `admin@example.com` with the exact email you will use for the admin account. Run the full SQL in Supabase SQL Editor.
2. In Supabase Authentication, create the admin user with that email and a strong password. If email confirmation is on, confirm it first.
3. In all three HTML files, replace `PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE` with your Supabase **publishable** key (or legacy anon key). Never use a service_role or secret key in HTML.
4. Upload `index.html`, `admin.html`, and `surprise.html` to the root of the same GitHub Pages repository. Keep the filenames unchanged.
5. Customer order form is your GitHub Pages URL. Admin page is the same URL plus `admin.html`.
6. Sign in to `admin.html`, review an order, and click “Publish final surprise link”. Copy the link and send it to the customer.

## Security notes before real sales
- The customer insert policy intentionally lets anonymous visitors submit orders, but public uploads can be abused. Add server-side rate limiting / CAPTCHA or move submissions and uploads behind a Supabase Edge Function before accepting high-volume or sensitive orders.
- Admin policies only authorize the exact email you set in SQL. Do not publish admin credentials.
- Photos remain in a private bucket. Publishing creates signed photo URLs valid for one year, so the surprise page can display them; the signed photo URLs expire after that period.
- The share token acts like a secret link. Anyone who has the link can open the surprise. Do not include highly sensitive information.
- This package does not handle payments or send messages automatically. Copy the published link and send it manually by WhatsApp or email.
- Test with fake data first, then verify that a customer cannot read orders and a non-admin account cannot access the admin list.
