// Configuracion de Supabase para el portal Zoca.
// 1. En Supabase: Project Settings > API.
// 2. Copia "Project URL" en SUPABASE_URL y la "anon public key" en SUPABASE_ANON_KEY.
// Mientras estos dos campos esten vacios, el portal funciona en modo demo
// con la licencia ZCA-2026-01847 y la contrasena zoca2026.

window.ZOCA_CONFIG = {
  SUPABASE_URL: "",
  SUPABASE_ANON_KEY: "",
  // Dominio interno para convertir la licencia en el correo de Supabase.
  // ZCA-2026-01847  ->  zca-2026-01847@clientes.zoca.app
  LICENSE_EMAIL_DOMAIN: "clientes.zoca.app"
};
