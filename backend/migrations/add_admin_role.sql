-- Ajouter le champ role aux utilisateurs
ALTER TABLE dorowere.users ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'super_admin'));

-- Créer un index sur le role
CREATE INDEX IF NOT EXISTS idx_users_role ON dorowere.users(role);

-- Mettre l'utilisateur démo en admin
UPDATE dorowere.users SET role = 'admin' WHERE phone_number = '+22670123456';

-- Créer un super admin (optionnel)
INSERT INTO dorowere.users (user_id, name, phone_number, password_hash, is_location_enabled, reliability_score, role)
VALUES (
    '00000000-0000-0000-0000-000000000099',
    'Super Admin',
    '+22670000000',
    crypt('admin123', gen_salt('bf')),
    true,
    5.0,
    'super_admin'
) ON CONFLICT (phone_number) DO UPDATE SET role = 'super_admin';

-- Vue pour les statistiques admin
CREATE OR REPLACE VIEW dorowere.admin_stats AS
SELECT 
    (SELECT COUNT(*) FROM dorowere.users) as total_users,
    (SELECT COUNT(*) FROM dorowere.lines) as total_lines,
    (SELECT COUNT(*) FROM dorowere.stops) as total_stops,
    (SELECT COUNT(*) FROM dorowere.buses) as total_buses,
    (SELECT COUNT(*) FROM dorowere.buses WHERE is_active = true) as active_buses,
    (SELECT COUNT(*) FROM dorowere.alerts WHERE expires_at > NOW()) as active_alerts,
    (SELECT COUNT(*) FROM dorowere.trips) as total_trips,
    (SELECT COUNT(*) FROM dorowere.trips WHERE created_at > NOW() - INTERVAL '7 days') as trips_last_week,
    (SELECT COUNT(*) FROM dorowere.alerts WHERE created_at > NOW() - INTERVAL '24 hours') as alerts_last_24h;

COMMENT ON VIEW dorowere.admin_stats IS 'Statistiques globales pour le tableau de bord admin';
