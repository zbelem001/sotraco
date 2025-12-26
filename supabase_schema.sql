-- ============================================
-- Script SQL Supabase pour Dôrô Wéré
-- Application de Transport Urbain Intelligent
-- ============================================

-- ============================================
-- 1. TABLE USERS (Utilisateurs)
-- ============================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    avatar_id UUID,
    is_location_enabled BOOLEAN DEFAULT false,
    reliability_score DECIMAL(3,2) DEFAULT 0.0 CHECK (reliability_score >= 0 AND reliability_score <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour recherche rapide par téléphone
CREATE INDEX idx_users_phone ON users(phone_number);

-- ============================================
-- 2. TABLE FRIENDS_LIST (Liste d'amis)
-- ============================================
CREATE TABLE friends_list (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);

CREATE INDEX idx_friends_user ON friends_list(user_id);
CREATE INDEX idx_friends_friend ON friends_list(friend_id);

-- ============================================
-- 3. TABLE LOCATIONS (Positions GPS)
-- ============================================
CREATE TABLE locations (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accuracy DECIMAL(10,2)
);

CREATE INDEX idx_locations_user ON locations(user_id);
CREATE INDEX idx_locations_timestamp ON locations(timestamp DESC);

-- ============================================
-- 4. TABLE LINES (Lignes de transport)
-- ============================================
CREATE TABLE lines (
    line_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    color VARCHAR(7) NOT NULL, -- Format hex color #RRGGBB
    average_speed DECIMAL(5,2) DEFAULT 25.0,
    base_fare DECIMAL(10,2) DEFAULT 200.0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_lines_active ON lines(is_active);

-- ============================================
-- 5. TABLE STOPS (Arrêts)
-- ============================================
CREATE TABLE stops (
    stop_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    is_official BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index géospatial pour recherche par proximité
CREATE INDEX idx_stops_location ON stops(latitude, longitude);

-- ============================================
-- 6. TABLE LINE_STOPS (Association Lignes-Arrêts)
-- ============================================
CREATE TABLE line_stops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    line_id UUID NOT NULL REFERENCES lines(line_id) ON DELETE CASCADE,
    stop_id UUID NOT NULL REFERENCES stops(stop_id) ON DELETE CASCADE,
    sequence_order INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(line_id, stop_id, sequence_order)
);

CREATE INDEX idx_line_stops_line ON line_stops(line_id);
CREATE INDEX idx_line_stops_stop ON line_stops(stop_id);

-- ============================================
-- 7. TABLE BUSES (Bus)
-- ============================================
CREATE TABLE buses (
    bus_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    line_id UUID NOT NULL REFERENCES lines(line_id) ON DELETE CASCADE,
    bus_number VARCHAR(50),
    direction VARCHAR(100),
    speed DECIMAL(5,2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_buses_line ON buses(line_id);
CREATE INDEX idx_buses_active ON buses(is_active);

-- ============================================
-- 8. TABLE BUS_LOCATIONS (Position des bus en temps réel)
-- ============================================
CREATE TABLE bus_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bus_id UUID NOT NULL REFERENCES buses(bus_id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    source VARCHAR(20) DEFAULT 'crowdsourced' CHECK (source IN ('gps', 'crowdsourced'))
);

CREATE INDEX idx_bus_locations_bus ON bus_locations(bus_id);
CREATE INDEX idx_bus_locations_timestamp ON bus_locations(timestamp DESC);

-- ============================================
-- 9. TABLE ALERTS (Alertes communautaires)
-- ============================================
CREATE TABLE alerts (
    alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL CHECK (type IN ('bus_full', 'breakdown', 'accident', 'stop_moved', 'road_blocked', 'other')),
    description TEXT NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    line_id UUID REFERENCES lines(line_id) ON DELETE SET NULL,
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    votes INT DEFAULT 0,
    validity_duration INT DEFAULT 120, -- minutes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_alerts_location ON alerts(latitude, longitude);
CREATE INDEX idx_alerts_line ON alerts(line_id);
CREATE INDEX idx_alerts_created_by ON alerts(created_by);
CREATE INDEX idx_alerts_expires ON alerts(expires_at);

-- ============================================
-- 10. TABLE ALERT_VOTES (Votes sur les alertes)
-- ============================================
CREATE TABLE alert_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES alerts(alert_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    vote_type VARCHAR(10) CHECK (vote_type IN ('up', 'down')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(alert_id, user_id)
);

CREATE INDEX idx_alert_votes_alert ON alert_votes(alert_id);

-- ============================================
-- 11. TABLE AVATARS (Avatars des utilisateurs)
-- ============================================
CREATE TABLE avatars (
    avatar_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    visibility_status VARCHAR(20) DEFAULT 'friends_only' CHECK (visibility_status IN ('visible', 'friends_only', 'invisible')),
    current_bus_id UUID REFERENCES buses(bus_id) ON DELETE SET NULL,
    current_stop_id UUID REFERENCES stops(stop_id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_avatars_user ON avatars(user_id);
CREATE INDEX idx_avatars_bus ON avatars(current_bus_id);

-- ============================================
-- 12. TABLE TRIPS (Trajets enregistrés)
-- ============================================
CREATE TABLE trips (
    trip_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    start_latitude DECIMAL(10,8) NOT NULL,
    start_longitude DECIMAL(11,8) NOT NULL,
    end_latitude DECIMAL(10,8) NOT NULL,
    end_longitude DECIMAL(11,8) NOT NULL,
    estimated_time INT, -- minutes
    estimated_cost DECIMAL(10,2),
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_trips_user ON trips(user_id);
CREATE INDEX idx_trips_favorite ON trips(user_id, is_favorite);

-- ============================================
-- 13. TABLE TRIP_ROUTES (Routes d'un trajet)
-- ============================================
CREATE TABLE trip_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(trip_id) ON DELETE CASCADE,
    line_id UUID REFERENCES lines(line_id) ON DELETE CASCADE,
    sequence_order INT NOT NULL,
    walking_distance DECIMAL(10,2) DEFAULT 0.0
);

CREATE INDEX idx_trip_routes_trip ON trip_routes(trip_id);

-- ============================================
-- 14. TABLE OFFLINE_MAPS (Cartes téléchargées)
-- ============================================
CREATE TABLE offline_maps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    zone_name VARCHAR(255) NOT NULL,
    map_data JSONB,
    file_size BIGINT,
    downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, zone_name)
);

CREATE INDEX idx_offline_maps_user ON offline_maps(user_id);

-- ============================================
-- TRIGGERS pour auto-update des timestamps
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lines_updated_at
    BEFORE UPDATE ON lines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stops_updated_at
    BEFORE UPDATE ON stops
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_buses_updated_at
    BEFORE UPDATE ON buses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_avatars_updated_at
    BEFORE UPDATE ON avatars
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- TRIGGER pour calculer expires_at des alertes
-- ============================================
CREATE OR REPLACE FUNCTION set_alert_expiration()
RETURNS TRIGGER AS $$
BEGIN
    NEW.expires_at = NEW.created_at + (NEW.validity_duration || ' minutes')::INTERVAL;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_alert_expires_at
    BEFORE INSERT ON alerts
    FOR EACH ROW
    EXECUTE FUNCTION set_alert_expiration();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Activer RLS sur les tables sensibles
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE avatars ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

-- Politique: Les utilisateurs peuvent voir et modifier leurs propres données
CREATE POLICY users_policy ON users
    FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY locations_policy ON locations
    FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY avatars_policy ON avatars
    FOR ALL
    USING (auth.uid() = user_id);

CREATE POLICY trips_policy ON trips
    FOR ALL
    USING (auth.uid() = user_id);

-- ============================================
-- VUES UTILES
-- ============================================

-- Vue: Bus actifs avec leur dernière position
CREATE OR REPLACE VIEW active_buses_with_location AS
SELECT 
    b.bus_id,
    b.line_id,
    l.name AS line_name,
    l.color AS line_color,
    b.direction,
    bl.latitude,
    bl.longitude,
    bl.timestamp AS last_update
FROM buses b
JOIN lines l ON b.line_id = l.line_id
LEFT JOIN LATERAL (
    SELECT latitude, longitude, timestamp
    FROM bus_locations
    WHERE bus_id = b.bus_id
    ORDER BY timestamp DESC
    LIMIT 1
) bl ON true
WHERE b.is_active = true;

-- Vue: Alertes actives
CREATE OR REPLACE VIEW active_alerts AS
SELECT 
    a.*,
    u.name AS creator_name,
    l.name AS line_name
FROM alerts a
JOIN users u ON a.created_by = u.user_id
LEFT JOIN lines l ON a.line_id = l.line_id
WHERE a.expires_at > NOW();

-- ============================================
-- DONNÉES DE TEST (Optionnel)
-- ============================================

-- Insérer un utilisateur démo
INSERT INTO users (user_id, name, phone_number, password_hash, is_location_enabled, reliability_score)
VALUES (
    gen_random_uuid(),
    'Amadou Traoré',
    '+22670123456',
    crypt('demo123', gen_salt('bf')), -- Nécessite l'extension pgcrypto
    true,
    4.5
);

-- Note: Activer l'extension pgcrypto pour le hachage des mots de passe
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- FIN DU SCRIPT
-- ============================================
