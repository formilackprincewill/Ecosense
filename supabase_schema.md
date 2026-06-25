# Supabase Migration Schema

You can copy and paste the following SQL commands directly into the **SQL Editor** on your Supabase dashboard to generate your tables, establish relational constraints, and enforce basic Row Level Security (RLS) identically to how Firebase Rules used to handle them.

```sql
-- 1. Create the `users` profile table
-- Links securely to the built-in Supabase `auth.users` authentication identity.
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  display_name TEXT NOT NULL DEFAULT 'Anonymous',
  email TEXT NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create the `data_points` environmental data table
CREATE TABLE public.data_points (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  submittedByName TEXT DEFAULT 'Unknown',
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  air_quality INTEGER,
  noise_level DOUBLE PRECISION,
  light_intensity INTEGER,
  timestamp TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Row Level Security (RLS) Implementation
-- Enable RLS to block unauthorized data scraping or spoofing.
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_points ENABLE ROW LEVEL SECURITY;

-- Allow users to read all profiles (required for leaderboards or displaying "submittedByName")
CREATE POLICY "Profiles are viewable by everyone" ON public.users FOR SELECT USING (true);

-- Allow users to update ONLY their own profile data
CREATE POLICY "Users can edit their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Allow everyone (or filter if required) to view submitted environmental data points
CREATE POLICY "Data points are viewable by everyone" ON public.data_points FOR SELECT USING (true);

-- Allow logged-in users to insert a data point under their own author_id
CREATE POLICY "Logged-in users can insert data points." ON public.data_points FOR INSERT WITH CHECK (auth.uid() = author_id);
```

### Important Automation Trigger (Optional but Recommended)
In Supabase, `auth.users` is generated automatically when someone signs up. However, you need a way to insert a parallel row into your `public.users` table so your app can actually fetch their custom `points` or `display_name` via API.

Paste this into the SQL Editor to automatically create a user profile *whenever* a new account is registered:

```sql
-- Trigger Function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name)
  VALUES (new.id, new.email, split_part(new.email, '@', 1));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger execution
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```
