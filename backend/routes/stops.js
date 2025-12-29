const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { optionalAuth } = require('../middleware/auth');

// GET /api/stops - Obtenir tous les arrêts
router.get('/', optionalAuth, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.stops ORDER BY name`
    );

    res.json({
      stops: result.rows.map(stop => ({
        stopId: stop.stop_id,
        name: stop.name,
        latitude: parseFloat(stop.latitude),
        longitude: parseFloat(stop.longitude),
        createdAt: stop.created_at,
      })),
    });
  } catch (error) {
    console.error('Erreur récupération arrêts:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/stops/nearby - Arrêts à proximité
router.get('/nearby', optionalAuth, async (req, res) => {
  try {
    const { lat, lng, radius = 1.0 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Latitude et longitude requises' });
    }

    const result = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.get_nearby_stops($1, $2, $3)`,
      [parseFloat(lat), parseFloat(lng), parseFloat(radius)]
    );

    res.json({
      stops: result.rows.map(stop => ({
        stopId: stop.stop_id,
        name: stop.name,
        latitude: parseFloat(stop.latitude),
        longitude: parseFloat(stop.longitude),
        distanceMeters: parseFloat(stop.distance_meters),
      })),
    });
  } catch (error) {
    console.error('Erreur arrêts à proximité:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/stops/:id - Obtenir un arrêt spécifique
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { id } = req.params;

    const stopResult = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.stops WHERE stop_id = $1`,
      [id]
    );

    if (stopResult.rows.length === 0) {
      return res.status(404).json({ error: 'Arrêt non trouvé' });
    }

    const stop = stopResult.rows[0];

    // Récupérer les lignes passant par cet arrêt
    const linesResult = await db.query(
      `SELECT l.*, ls.sequence_order
       FROM ${process.env.DB_SCHEMA}.lines l
       JOIN ${process.env.DB_SCHEMA}.line_stops ls ON l.line_id = ls.line_id
       WHERE ls.stop_id = $1
       ORDER BY l.line_number`,
      [id]
    );

    res.json({
      stopId: stop.stop_id,
      name: stop.name,
      latitude: parseFloat(stop.latitude),
      longitude: parseFloat(stop.longitude),
      lines: linesResult.rows.map(line => ({
        lineId: line.line_id,
        lineNumber: line.line_number,
        name: line.name,
        color: line.color,
      })),
      createdAt: stop.created_at,
    });
  } catch (error) {
    console.error('Erreur récupération arrêt:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
