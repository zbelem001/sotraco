const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, optionalAuth } = require('../middleware/auth');

// GET /api/alerts - Obtenir toutes les alertes actives
router.get('/', optionalAuth, async (req, res) => {
  try {
    const { line_id } = req.query;

    let query = `SELECT * FROM ${process.env.DB_SCHEMA}.active_alerts`;
    const params = [];

    if (line_id) {
      query = `
        SELECT a.*, u.name as creator_name, u.reliability_score as creator_reliability,
               l.name as line_name, l.line_number,
               EXTRACT(EPOCH FROM (a.expires_at - NOW()))/60 AS minutes_remaining
        FROM ${process.env.DB_SCHEMA}.alerts a
        JOIN ${process.env.DB_SCHEMA}.users u ON a.created_by = u.user_id
        LEFT JOIN ${process.env.DB_SCHEMA}.lines l ON a.line_id = l.line_id
        WHERE a.expires_at > NOW() AND a.line_id = $1
        ORDER BY a.created_at DESC
      `;
      params.push(line_id);
    }

    const result = await db.query(query, params);

    res.json({
      alerts: result.rows.map(alert => ({
        alertId: alert.alert_id,
        type: alert.type,
        description: alert.description,
        latitude: parseFloat(alert.latitude),
        longitude: parseFloat(alert.longitude),
        lineId: alert.line_id,
        lineName: alert.line_name,
        lineNumber: alert.line_number,
        votes: alert.votes,
        createdBy: alert.created_by,
        creatorName: alert.creator_name,
        creatorReliability: alert.creator_reliability ? parseFloat(alert.creator_reliability) : null,
        createdAt: alert.created_at,
        expiresAt: alert.expires_at,
        minutesRemaining: alert.minutes_remaining ? parseFloat(alert.minutes_remaining) : null,
      })),
    });
  } catch (error) {
    console.error('Erreur récupération alertes:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/alerts/nearby - Alertes à proximité
router.get('/nearby', optionalAuth, async (req, res) => {
  try {
    const { lat, lng, radius = 5.0 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'Latitude et longitude requises' });
    }

    const result = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.get_nearby_alerts($1, $2, $3)`,
      [parseFloat(lat), parseFloat(lng), parseFloat(radius)]
    );

    res.json({
      alerts: result.rows.map(alert => ({
        alertId: alert.alert_id,
        type: alert.type,
        description: alert.description,
        latitude: parseFloat(alert.latitude),
        longitude: parseFloat(alert.longitude),
        distanceMeters: parseFloat(alert.distance_meters),
        votes: alert.votes,
        createdBy: alert.created_by,
        creatorName: alert.creator_name,
        expiresAt: alert.expires_at,
      })),
    });
  } catch (error) {
    console.error('Erreur alertes à proximité:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/alerts - Créer une alerte (authentification requise)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { type, description, latitude, longitude, line_id, validity_duration = 120 } = req.body;

    // Validation
    if (!type || !description || !latitude || !longitude) {
      return res.status(400).json({ error: 'Champs requis manquants' });
    }

    const validTypes = ['bus_full', 'breakdown', 'accident', 'stop_moved', 'road_blocked', 'other'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({ error: 'Type d\'alerte invalide' });
    }

    const result = await db.query(
      `INSERT INTO ${process.env.DB_SCHEMA}.alerts 
       (type, description, latitude, longitude, line_id, created_by, validity_duration)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING alert_id, type, description, latitude, longitude, votes, created_at, expires_at`,
      [type, description, latitude, longitude, line_id || null, req.user.userId, validity_duration]
    );

    const alert = result.rows[0];

    res.status(201).json({
      message: 'Alerte créée avec succès',
      alert: {
        alertId: alert.alert_id,
        type: alert.type,
        description: alert.description,
        latitude: parseFloat(alert.latitude),
        longitude: parseFloat(alert.longitude),
        votes: alert.votes,
        createdAt: alert.created_at,
        expiresAt: alert.expires_at,
      },
    });
  } catch (error) {
    console.error('Erreur création alerte:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/alerts/:id/vote - Voter sur une alerte (authentification requise)
router.post('/:id/vote', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { vote_type } = req.body; // 'up' ou 'down'

    if (!['up', 'down'].includes(vote_type)) {
      return res.status(400).json({ error: 'Type de vote invalide (up ou down)' });
    }

    // Vérifier si l'alerte existe et est active
    const alertCheck = await db.query(
      `SELECT alert_id FROM ${process.env.DB_SCHEMA}.alerts 
       WHERE alert_id = $1 AND expires_at > NOW()`,
      [id]
    );

    if (alertCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Alerte non trouvée ou expirée' });
    }

    // Vérifier si l'utilisateur a déjà voté
    const existingVote = await db.query(
      `SELECT id, vote_type FROM ${process.env.DB_SCHEMA}.alert_votes 
       WHERE alert_id = $1 AND user_id = $2`,
      [id, req.user.userId]
    );

    if (existingVote.rows.length > 0) {
      // Mettre à jour le vote
      await db.query(
        `UPDATE ${process.env.DB_SCHEMA}.alert_votes 
         SET vote_type = $1 
         WHERE alert_id = $2 AND user_id = $3`,
        [vote_type, id, req.user.userId]
      );
    } else {
      // Créer un nouveau vote
      await db.query(
        `INSERT INTO ${process.env.DB_SCHEMA}.alert_votes (alert_id, user_id, vote_type)
         VALUES ($1, $2, $3)`,
        [id, req.user.userId, vote_type]
      );
    }

    // Mettre à jour le compteur de votes de l'alerte
    const voteCount = await db.query(
      `SELECT 
         SUM(CASE WHEN vote_type = 'up' THEN 1 ELSE -1 END) as total_votes
       FROM ${process.env.DB_SCHEMA}.alert_votes
       WHERE alert_id = $1`,
      [id]
    );

    await db.query(
      `UPDATE ${process.env.DB_SCHEMA}.alerts SET votes = $1 WHERE alert_id = $2`,
      [voteCount.rows[0].total_votes || 0, id]
    );

    res.json({
      message: 'Vote enregistré',
      totalVotes: parseInt(voteCount.rows[0].total_votes) || 0,
    });
  } catch (error) {
    console.error('Erreur vote alerte:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
