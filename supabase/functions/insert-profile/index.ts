// supabase/functions/insert-profile/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

// ✅ Get secrets safely
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization') || ''
    const token = authHeader.replace('Bearer ', '')

    if (!token) {
      return new Response(JSON.stringify({ error: 'Missing auth token' }), {
        status: 401,
        headers: corsHeaders,
      })
    }

    const body = await req.json()
    console.log('Incoming request:', body)

    const {
      id,
      first_name,
      last_name,
      email,
      mobile,
      dob,
      gender,
      avatar_url,
      bio
    } = body

    // ✅ Handle invalid or empty gender values
    const allowedGenders = ['male', 'female', 'other']
    const genderToInsert = allowedGenders.includes(gender) ? gender : 'other'

    // ✅ Insert profile into the "profiles" table
    const { error } = await supabase.from('profiles').insert({
      id,
      first_name,
      last_name,
      email,
      mobile,
      dob,
      gender: genderToInsert,
      avatar_url,
      bio,
    })

    if (error) {
      console.error('Insert error:', error.message)
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400,
        headers: corsHeaders,
      })
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: corsHeaders,
    })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: corsHeaders,
    })
  }
})
