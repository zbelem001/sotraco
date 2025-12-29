const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { optionalAuth } = require('../middleware/auth');

// GET /api/buses - Obtenir tous les bus actifs
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { line_id, active_only = 'true' } = req.query;

    let query = `
      SELECT * FROM ${process.env.DB_SCHEMA}.active_buses_with_location
    `;

    const params = [];
    const conditions = [];

    if (line_id) {
      params.push(line_id);
      conditions.push(`line_id = $${params.length}`);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY line_number, bus_number';

    const result = await db.query(query, params);

    res.json({
      buses: result.rows.map(bus => ({
        busId: bus.bus_id,
        busNumber: bus.bus_number,
        lineId: bus.line_id,
        lineName: bus.line_name,
        lineNumber: bus.line_number,
        lineColor: bus.line_color,
        direction: bus.direction,
        latitude: bus.latitude ? parseFloat(bus.latitude) : null,
        longitude: bus.longitude ? parseFloat(bus.longitude) : null,
        lastUpdate: bus.last_update,
        minutesAgo: bus.minutes_ago ? parseFloat(bus.minutes_ago) : null,
      })),
    });
  } catch (error) {
    console.error('Erreur récupération bus:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/buses/nearby - Bus à proximité
router.get('/nearby', optionalAuth, async (req, res) => {
  try {
    const { lat, lng, radius = 5.0 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Latitude et longitude requises' });
    }

    const result = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.get_nearby_buses($1, $2, $3)`,
      [parseFloat(lat), parseFloat(lng), parseFloat(radius)]
    );

    res.json({
      buses: result.rows.map(bus => ({
        busId: bus.bus_id,
        busNumber: bus.bus_number,
        lineId: bus.line_id,
        lineName: bus.line_name,
        lineColor: bus.line_color,
        latitude: parseFloat(bus.latitude),
        longitude: parseFloat(bus.longitude),
        distanceMeters: parseFloat(bus.distance_meters),
        lastUpdate: bus.last_update,
      })),
    });
  } catch (error) {
    console.error('Erreur bus à proximité:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/buses/:id - Obtenir un bus spécifique
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { id } = req.params;

    const busResult = await db.query(
      `SELECT b.*, l.name as line_name, l.line_number, l.color as line_color
       FROM ${process.env.DB_SCHEMA}.buses b
       JOIN ${process.env.DB_SCHEMA}.lines l ON b.line_id = l.line_id
       WHERE b.bus_id = $1`,
      [id]
    );

    if (busResult.rows.length === 0) {
      return res.status(404).json({ error: 'Bus non trouvé' });
    }

    const bus = busResult.rows[0];

    // Récupérer la dernière position
    const locationResult = await db.query(
      `SELECT latitude, longitude, timestamp, source
       FROM ${process.env.DB_SCHEMA}.bus_locations
       WHERE bus_id = $1
       ORDER BY timestamp DESC
       LIMIT 1`,
      [id]
    );

    const location = locationResult.rows[0] || null;

    res.json({
      busId: bus.bus_id,
      busNumber: bus.bus_number,
      lineId: bus.line_id,
      lineName: bus.line_name,
      lineNumber: bus.line_number,
      lineColor: bus.line_color,
      direction: bus.direction,
      speed: bus.speed ? parseFloat(bus.speed) : 0,
      isActive: bus.is_active,
      currentLocation: location ? {
        latitude: parseFloat(location.latitude),
        longitude: parseFloat(location.longitude),
        timestamp: location.timestamp,
        source: location.source,
      } : null,
    });
  } catch (error) {
    console.error('Erreur récupération bus:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
