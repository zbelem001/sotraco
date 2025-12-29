-- ============================================
-- Script SQL PostgreSQL Local pour Dôrô Wéré
-- VERSION SANS POSTGIS (compatible PostgreSQL standard)
-- ============================================

-- Extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Créer le schéma de l'application
CREATE SCHEMA IF NOT EXISTS dorowere;
SET search_path TO dorowere, public;

-- ============================================
-- 1. TABLE USERS (Utilisateurs)
-- ============================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    avatar_id UUID,
    is_location_enabled BOOLEAN DEFAULT false,
    reliability_score DECIMAL(3,2) DEFAULT 0.0 CHECK (reliability_score >= 0 AND reliability_score <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_phone ON users(phone_number);
COMMENT ON TABLE users IS 'Table des utilisateurs de l''application';

-- ============================================
-- 2. TABLE FRIENDS_LIST (Liste d'amis)
-- ============================================
CREATE TABLE friends_list (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    location_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accuracy DECIMAL(10,2)
);

CREATE INDEX idx_locations_user ON locations(user_id);
CREATE INDEX idx_locations_timestamp ON locations(timestamp DESC);
CREATE INDEX idx_locations_coords ON locations(latitude, longitude);

-- ============================================
-- 4. TABLE LINES (Lignes de transport)
-- ============================================
CREATE TABLE lines (
    line_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    line_number VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(20) NOT NULL,
    start_point VARCHAR(255) NOT NULL,
    end_point VARCHAR(255) NOT NULL,
    route_coordinates JSONB,
    fare DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_lines_number ON lines(line_number);
CREATE INDEX idx_lines_active ON lines(is_active);
COMMENT ON TABLE lines IS 'Lignes de transport public';

-- ============================================
-- 5. TABLE STOPS (Arrêts)
-- ============================================
CREATE TABLE stops (
    stop_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_stops_name ON stops(name);
CREATE INDEX idx_stops_coords ON stops(latitude, longitude);

-- ============================================
-- 6. TABLE LINE_STOPS (Arrêts d'une ligne)
-- ============================================
CREATE TABLE line_stops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    line_id UUID NOT NULL REFERENCES lines(line_id) ON DELETE CASCADE,
    stop_id UUID NOT NULL REFERENCES stops(stop_id) ON DELETE CASCADE,
    sequence_order INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(line_id, stop_id)
);

CREATE INDEX idx_line_stops_line ON line_stops(line_id);
CREATE INDEX idx_line_stops_stop ON line_stops(stop_id);
CREATE INDEX idx_line_stops_sequence ON line_stops(line_id, sequence_order);

-- ============================================
-- 7. TABLE BUSES (Bus)
-- ============================================
CREATE TABLE buses (
    bus_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bus_id UUID NOT NULL REFERENCES buses(bus_id) ON DELETE CASCADE,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    source VARCHAR(20) DEFAULT 'crowdsourced' CHECK (source IN ('gps', 'crowdsourced'))
);

CREATE INDEX idx_bus_locations_bus ON bus_locations(bus_id);
CREATE INDEX idx_bus_locations_timestamp ON bus_locations(timestamp DESC);
CREATE INDEX idx_bus_locations_coords ON bus_locations(latitude, longitude);

-- ============================================
-- 9. TABLE ALERTS (Alertes communautaires)
-- ============================================
CREATE TABLE alerts (
    alert_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

CREATE INDEX idx_alerts_coords ON alerts(latitude, longitude);
CREATE INDEX idx_alerts_line ON alerts(line_id);
CREATE INDEX idx_alerts_created_by ON alerts(created_by);
CREATE INDEX idx_alerts_expires ON alerts(expires_at);

-- ============================================
-- 10. TABLE ALERT_VOTES (Votes sur les alertes)
-- ============================================
CREATE TABLE alert_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_id UUID NOT NULL REFERENCES alerts(alert_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    vote_type VARCHAR(10) CHECK (vote_type IN ('up', 'down')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(alert_id, user_id)
);

CREATE INDEX idx_alert_votes_alert ON alert_votes(alert_id);
CREATE INDEX idx_alert_votes_user ON alert_votes(user_id);

-- ============================================
-- 11. TABLE AVATARS (Avatars des utilisateurs)
-- ============================================
CREATE TABLE avatars (
    avatar_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    visibility_status VARCHAR(20) DEFAULT 'friends_only' CHECK (visibility_status IN ('visible', 'friends_only', 'invisible')),
    current_bus_id UUID REFERENCES buses(bus_id) ON DELETE SET NULL,
    current_stop_id UUID REFERENCES stops(stop_id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_avatars_user ON avatars(user_id);
CREATE INDEX idx_avatars_bus ON avatars(current_bus_id);
CREATE INDEX idx_avatars_stop ON avatars(current_stop_id);

-- ============================================
-- 12. TABLE TRIPS (Trajets enregistrés)
-- ============================================
CREATE TABLE trips (
    trip_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(trip_id) ON DELETE CASCADE,
    line_id UUID REFERENCES lines(line_id) ON DELETE CASCADE,
    sequence_order INT NOT NULL,
    walking_distance DECIMAL(10,2) DEFAULT 0.0
);

CREATE INDEX idx_trip_routes_trip ON trip_routes(trip_id);
CREATE INDEX idx_trip_routes_line ON trip_routes(line_id);

-- ============================================
-- 14. TABLE OFFLINE_MAPS (Cartes téléchargées)
-- ============================================
CREATE TABLE offline_maps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
-- FONCTIONS UTILITAIRES (sans PostGIS)
-- Utilise la formule Haversine pour calculer les distances
-- ============================================

-- Fonction helper: Calculer la distance Haversine entre deux points GPS (en mètres)
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DOUBLE PRECISION,
    lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$
DECLARE
    R CONSTANT DOUBLE PRECISION := 6371000; -- Rayon de la Terre en mètres
    dLat DOUBLE PRECISION;
    dLon DOUBLE PRECISION;
    a DOUBLE PRECISION;
    c DOUBLE PRECISION;
BEGIN
    dLat := radians(lat2 - lat1);
    dLon := radians(lon2 - lon1);
    
    a := sin(dLat/2) * sin(dLat/2) +
         cos(radians(lat1)) * cos(radians(lat2)) *
         sin(dLon/2) * sin(dLon/2);
    
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    
    RETURN R * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Fonction: Obtenir les arrêts à proximité
CREATE OR REPLACE FUNCTION get_nearby_stops(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 1.0
)
RETURNS TABLE (
    stop_id UUID,
    name VARCHAR,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_meters DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.stop_id,
        s.name,
        s.latitude,
        s.longitude,
        calculate_distance(user_lat, user_lng, s.latitude::DOUBLE PRECISION, s.longitude::DOUBLE PRECISION) as distance_meters
    FROM stops s
    WHERE calculate_distance(user_lat, user_lng, s.latitude::DOUBLE PRECISION, s.longitude::DOUBLE PRECISION) <= radius_km * 1000
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Fonction: Obtenir les bus actifs à proximité
CREATE OR REPLACE FUNCTION get_nearby_buses(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE (
    bus_id UUID,
    bus_number VARCHAR,
    line_id UUID,
    line_name VARCHAR,
    line_color VARCHAR,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_meters DOUBLE PRECISION,
    last_update TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.bus_id,
        b.bus_number,
        l.line_id,
        l.name as line_name,
        l.color as line_color,
        bl.latitude,
        bl.longitude,
        calculate_distance(user_lat, user_lng, bl.latitude::DOUBLE PRECISION, bl.longitude::DOUBLE PRECISION) as distance_meters,
        bl.timestamp as last_update
    FROM buses b
    JOIN lines l ON b.line_id = l.line_id
    JOIN LATERAL (
        SELECT latitude, longitude, timestamp
        FROM bus_locations
        WHERE bus_id = b.bus_id
        ORDER BY timestamp DESC
        LIMIT 1
    ) bl ON true
    WHERE b.is_active = true
        AND calculate_distance(user_lat, user_lng, bl.latitude::DOUBLE PRECISION, bl.longitude::DOUBLE PRECISION) <= radius_km * 1000
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Fonction: Obtenir les alertes actives à proximité
CREATE OR REPLACE FUNCTION get_nearby_alerts(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE (
    alert_id UUID,
    type VARCHAR,
    description TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    distance_meters DOUBLE PRECISION,
    votes INT,
    created_by UUID,
    creator_name VARCHAR,
    expires_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.alert_id,
        a.type,
        a.description,
        a.latitude,
        a.longitude,
        calculate_distance(user_lat, user_lng, a.latitude::DOUBLE PRECISION, a.longitude::DOUBLE PRECISION) as distance_meters,
        a.votes,
        a.created_by,
        u.name as creator_name,
        a.expires_at
    FROM alerts a
    JOIN users u ON a.created_by = u.user_id
    WHERE a.expires_at > NOW()
        AND calculate_distance(user_lat, user_lng, a.latitude::DOUBLE PRECISION, a.longitude::DOUBLE PRECISION) <= radius_km * 1000
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VUES UTILES
-- ============================================

-- Vue: Bus actifs avec leur dernière position
CREATE OR REPLACE VIEW active_buses_with_location AS
SELECT 
    b.bus_id,
    b.bus_number,
    b.line_id,
    l.name AS line_name,
    l.line_number,
    l.color AS line_color,
    b.direction,
    bl.latitude,
    bl.longitude,
    bl.timestamp AS last_update,
    EXTRACT(EPOCH FROM (NOW() - bl.timestamp))/60 AS minutes_ago
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

-- Vue: Alertes actives avec détails
CREATE OR REPLACE VIEW active_alerts AS
SELECT 
    a.alert_id,
    a.type,
    a.description,
    a.latitude,
    a.longitude,
    a.votes,
    a.created_at,
    a.expires_at,
    EXTRACT(EPOCH FROM (a.expires_at - NOW()))/60 AS minutes_remaining,
    u.name AS creator_name,
    u.reliability_score AS creator_reliability,
    l.name AS line_name,
    l.line_number
FROM alerts a
JOIN users u ON a.created_by = u.user_id
LEFT JOIN lines l ON a.line_id = l.line_id
WHERE a.expires_at > NOW()
ORDER BY a.created_at DESC;

-- Vue: Lignes avec nombre d'arrêts
CREATE OR REPLACE VIEW lines_with_stop_count AS
SELECT 
    l.line_id,
    l.line_number,
    l.name,
    l.color,
    l.start_point,
    l.end_point,
    l.fare,
    l.is_active,
    COUNT(ls.stop_id) AS stop_count
FROM lines l
LEFT JOIN line_stops ls ON l.line_id = ls.line_id
GROUP BY l.line_id;

-- Vue: Statistiques utilisateur
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    u.user_id,
    u.name,
    u.phone_number,
    u.reliability_score,
    COUNT(DISTINCT t.trip_id) AS total_trips,
    COUNT(DISTINCT CASE WHEN t.is_favorite THEN t.trip_id END) AS favorite_trips,
    COUNT(DISTINCT a.alert_id) AS alerts_created,
    COUNT(DISTINCT av.id) AS votes_cast,
    COUNT(DISTINCT f.friend_id) AS friends_count
FROM users u
LEFT JOIN trips t ON u.user_id = t.user_id
LEFT JOIN alerts a ON u.user_id = a.created_by
LEFT JOIN alert_votes av ON u.user_id = av.user_id
LEFT JOIN friends_list f ON u.user_id = f.user_id AND f.status = 'accepted'
GROUP BY u.user_id;

-- ============================================
-- DONNÉES DE TEST
-- ============================================

-- Insérer utilisateur démo (mot de passe: demo123)
INSERT INTO users (user_id, name, phone_number, password_hash, is_location_enabled, reliability_score)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Amadou Traoré',
    '+22670123456',
    crypt('demo123', gen_salt('bf')),
    true,
    4.5
) ON CONFLICT (phone_number) DO NOTHING;

-- Insérer lignes de test
INSERT INTO lines (line_id, line_number, name, color, start_point, end_point, fare, is_active) VALUES
('10000000-0000-0000-0000-000000000001', '1', 'Centre-ville - Ouaga 2000', '#2196F3', 'Place des Nations Unies', 'Ouaga 2000', 200, true),
('10000000-0000-0000-0000-000000000002', '2', 'Gounghin - Tanghin', '#4CAF50', 'Gounghin', 'Tanghin', 150, true),
('10000000-0000-0000-0000-000000000003', '3', 'Pissy - Dassasgho', '#FF9800', 'Pissy', 'Dassasgho', 150, true)
ON CONFLICT (line_id) DO NOTHING;

-- Insérer arrêts de test (Ouagadougou)
INSERT INTO stops (stop_id, name, latitude, longitude) VALUES
('20000000-0000-0000-0000-000000000001', 'Place des Nations Unies', 12.371420, -1.519740),
('20000000-0000-0000-0000-000000000002', 'Marché Central', 12.365000, -1.529000),
('20000000-0000-0000-0000-000000000003', 'Gare Routière', 12.368000, -1.526000),
('20000000-0000-0000-0000-000000000004', 'Ouaga 2000', 12.335000, -1.485000),
('20000000-0000-0000-0000-000000000005', 'Gounghin', 12.388000, -1.512000),
('20000000-0000-0000-0000-000000000006', 'Tanghin', 12.345000, -1.538000),
('20000000-0000-0000-0000-000000000007', 'Pissy', 12.352000, -1.542000),
('20000000-0000-0000-0000-000000000008', 'Dassasgho', 12.402000, -1.498000)
ON CONFLICT (stop_id) DO NOTHING;

-- Associer arrêts aux lignes
INSERT INTO line_stops (line_id, stop_id, sequence_order) VALUES
('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 1),
('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 2),
('10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 3),
('10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000005', 1),
('10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000006', 2),
('10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000007', 1),
('10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000008', 2)
ON CONFLICT (line_id, stop_id) DO NOTHING;

-- Insérer bus de test
INSERT INTO buses (bus_id, line_id, bus_number, direction, is_active) VALUES
('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'BUS-101', 'Ouaga 2000', true),
('30000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'BUS-102', 'Centre-ville', true),
('30000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'BUS-201', 'Tanghin', true),
('30000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000003', 'BUS-301', 'Dassasgho', true)
ON CONFLICT (bus_id) DO NOTHING;

-- Insérer positions de bus (exemple)
INSERT INTO bus_locations (bus_id, latitude, longitude, source) VALUES
('30000000-0000-0000-0000-000000000001', 12.371420, -1.519740, 'gps'),
('30000000-0000-0000-0000-000000000002', 12.345000, -1.538000, 'gps'),
('30000000-0000-0000-0000-000000000003', 12.388000, -1.512000, 'crowdsourced'),
('30000000-0000-0000-0000-000000000004', 12.352000, -1.542000, 'crowdsourced');

-- Insérer alertes de test
INSERT INTO alerts (alert_id, type, description, latitude, longitude, line_id, created_by, votes, validity_duration) VALUES
('40000000-0000-0000-0000-000000000001', 'bus_full', 'Bus complètement rempli', 12.371420, -1.519740, '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 5, 60),
('40000000-0000-0000-0000-000000000002', 'road_blocked', 'Route barrée - manifestation', 12.365000, -1.529000, NULL, '00000000-0000-0000-0000-000000000001', 12, 120)
ON CONFLICT (alert_id) DO NOTHING;

-- ============================================
-- GRANTS (Permissions pour développement)
-- ============================================

-- Créer un rôle pour l'application (optionnel)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'dorowere_app') THEN
        CREATE ROLE dorowere_app WITH LOGIN PASSWORD 'dev_password_change_in_production';
    END IF;
END
$$;

-- Donner les permissions au rôle
GRANT USAGE ON SCHEMA dorowere TO dorowere_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA dorowere TO dorowere_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA dorowere TO dorowere_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA dorowere TO dorowere_app;

-- Permissions par défaut pour les futurs objets
ALTER DEFAULT PRIVILEGES IN SCHEMA dorowere
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO dorowere_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA dorowere
    GRANT USAGE, SELECT ON SEQUENCES TO dorowere_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA dorowere
    GRANT EXECUTE ON FUNCTIONS TO dorowere_app;

-- ============================================
-- FIN DU SCRIPT
-- ============================================

-- Afficher un résumé
DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Dôrô Wéré - Schéma PostgreSQL Local';
    RAISE NOTICE 'VERSION SANS POSTGIS';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Schéma: dorowere';
    RAISE NOTICE 'Tables créées: 14';
    RAISE NOTICE 'Vues créées: 4';
    RAISE NOTICE 'Fonctions créées: 4 (avec calcul Haversine)';
    RAISE NOTICE 'Utilisateur démo: +22670123456 / demo123';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Note: Cette version utilise la formule Haversine';
    RAISE NOTICE 'pour les calculs de distance (pas PostGIS)';
    RAISE NOTICE '============================================';
END $$;
