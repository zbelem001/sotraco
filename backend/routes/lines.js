const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { optionalAuth } = require('../middleware/auth');

// GET /api/lines - Obtenir toutes les lignes
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { active_only } = req.query;

    let query = `
      SELECT l.*, 
             (SELECT COUNT(*) FROM ${process.env.DB_SCHEMA}.line_stops WHERE line_id = l.line_id) as stop_count
      FROM ${process.env.DB_SCHEMA}.lines l
    `;

    const params = [];
    if (active_only === 'true') {
      query += ' WHERE l.is_active = true';
    }

    query += ' ORDER BY l.line_number';

    const result = await db.query(query, params);

    res.json({
      lines: result.rows.map(line => ({
        lineId: line.line_id,
        lineNumber: line.line_number,
        name: line.name,
        color: line.color,
        startPoint: line.start_point,
        endPoint: line.end_point,
        fare: parseFloat(line.fare),
        isActive: line.is_active,
        stopCount: parseInt(line.stop_count),
        createdAt: line.created_at,
      })),
    });
  } catch (error) {
    console.error('Erreur récupération lignes:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/lines/:id - Obtenir une ligne spécifique
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const { id } = req.params;

    const lineResult = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.lines WHERE line_id = $1`,
      [id]
    );

    if (lineResult.rows.length === 0) {
      return res.status(404).json({ error: 'Ligne non trouvée' });
    }

    const line = lineResult.rows[0];

    // Récupérer les arrêts de cette ligne
    const stopsResult = await db.query(
      `SELECT s.*, ls.sequence_order
       FROM ${process.env.DB_SCHEMA}.stops s
       JOIN ${process.env.DB_SCHEMA}.line_stops ls ON s.stop_id = ls.stop_id
       WHERE ls.line_id = $1
       ORDER BY ls.sequence_order`,
      [id]
    );

    res.json({
      lineId: line.line_id,
      lineNumber: line.line_number,
      name: line.name,
      color: line.color,
      startPoint: line.start_point,
      endPoint: line.end_point,
      fare: parseFloat(line.fare),
      isActive: line.is_active,
      routeCoordinates: line.route_coordinates,
      stops: stopsResult.rows.map(stop => ({
        stopId: stop.stop_id,
        name: stop.name,
        latitude: parseFloat(stop.latitude),
        longitude: parseFloat(stop.longitude),
        sequenceOrder: stop.sequence_order,
      })),
      createdAt: line.created_at,
    });
  } catch (error) {
    console.error('Erreur récupération ligne:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
