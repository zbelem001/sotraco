const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// GET /api/users/me - Obtenir le profil de l'utilisateur connecté
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT user_id, name, phone_number, avatar_id, is_location_enabled, 
              reliability_score, created_at, updated_at
       FROM ${process.env.DB_SCHEMA}.users 
       WHERE user_id = $1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    const user = result.rows[0];

    // Récupérer les statistiques
    const stats = await db.query(
      `SELECT * FROM ${process.env.DB_SCHEMA}.user_stats WHERE user_id = $1`,
      [req.user.userId]
    );

    res.json({
      userId: user.user_id,
      name: user.name,
      phoneNumber: user.phone_number,
      avatarId: user.avatar_id,
      isLocationEnabled: user.is_location_enabled,
      reliabilityScore: parseFloat(user.reliability_score),
      stats: stats.rows[0] ? {
        totalTrips: parseInt(stats.rows[0].total_trips),
        favoriteTrips: parseInt(stats.rows[0].favorite_trips),
        alertsCreated: parseInt(stats.rows[0].alerts_created),
        votesCast: parseInt(stats.rows[0].votes_cast),
        friendsCount: parseInt(stats.rows[0].friends_count),
      } : null,
      createdAt: user.created_at,
    });
  } catch (error) {
    console.error('Erreur récupération profil:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// PUT /api/users/me - Mettre à jour le profil
router.put('/me', authenticateToken, async (req, res) => {
  try {
    const { name, is_location_enabled, avatar_id } = req.body;

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (name !== undefined) {
      updates.push(`name = $${paramIndex}`);
      params.push(name);
      paramIndex++;
    }

    if (is_location_enabled !== undefined) {
      updates.push(`is_location_enabled = $${paramIndex}`);
      params.push(is_location_enabled);
      paramIndex++;
    }

    if (avatar_id !== undefined) {
      updates.push(`avatar_id = $${paramIndex}`);
      params.push(avatar_id);
      paramIndex++;
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'Aucune donnée à mettre à jour' });
    }

    params.push(req.user.userId);

    const result = await db.query(
      `UPDATE ${process.env.DB_SCHEMA}.users 
       SET ${updates.join(', ')}, updated_at = NOW()
       WHERE user_id = $${paramIndex}
       RETURNING user_id, name, phone_number, avatar_id, is_location_enabled, reliability_score`,
      params
    );

    const user = result.rows[0];

    res.json({
      message: 'Profil mis à jour',
      user: {
        userId: user.user_id,
        name: user.name,
        phoneNumber: user.phone_number,
        avatarId: user.avatar_id,
        isLocationEnabled: user.is_location_enabled,
        reliabilityScore: parseFloat(user.reliability_score),
      },
    });
  } catch (error) {
    console.error('Erreur mise à jour profil:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/users/me/location - Mettre à jour la localisation
router.post('/me/location', authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, accuracy } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude et longitude requises' });
    }

    await db.query(
      `INSERT INTO ${process.env.DB_SCHEMA}.locations (user_id, latitude, longitude, accuracy)
       VALUES ($1, $2, $3, $4)`,
      [req.user.userId, latitude, longitude, accuracy || null]
    );

    res.json({ message: 'Localisation enregistrée' });
  } catch (error) {
    console.error('Erreur enregistrement localisation:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// GET /api/users/me/trips - Obtenir les trajets de l'utilisateur
router.get('/me/trips', authenticateToken, async (req, res) => {
  try {
    const { favorites_only } = req.query;

    let query = `
      SELECT * FROM ${process.env.DB_SCHEMA}.trips 
      WHERE user_id = $1
    `;

    if (favorites_only === 'true') {
      query += ' AND is_favorite = true';
    }

    query += ' ORDER BY created_at DESC LIMIT 50';

    const result = await db.query(query, [req.user.userId]);

    res.json({
      trips: result.rows.map(trip => ({
        tripId: trip.trip_id,
        startLatitude: parseFloat(trip.start_latitude),
        startLongitude: parseFloat(trip.start_longitude),
        endLatitude: parseFloat(trip.end_latitude),
        endLongitude: parseFloat(trip.end_longitude),
        estimatedTime: trip.estimated_time,
        estimatedCost: trip.estimated_cost ? parseFloat(trip.estimated_cost) : null,
        isFavorite: trip.is_favorite,
        createdAt: trip.created_at,
      })),
    });
  } catch (error) {
    console.error('Erreur récupération trajets:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// POST /api/users/me/trips - Sauvegarder un trajet
router.post('/me/trips', authenticateToken, async (req, res) => {
  try {
    const { start_latitude, start_longitude, end_latitude, end_longitude, estimated_time, estimated_cost, is_favorite = false } = req.body;

    if (!start_latitude || !start_longitude || !end_latitude || !end_longitude) {
      return res.status(400).json({ error: 'Coordonnées de départ et d\'arrivée requises' });
    }

    const result = await db.query(
      `INSERT INTO ${process.env.DB_SCHEMA}.trips 
       (user_id, start_latitude, start_longitude, end_latitude, end_longitude, estimated_time, estimated_cost, is_favorite)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING trip_id, start_latitude, start_longitude, end_latitude, end_longitude, estimated_time, estimated_cost, is_favorite, created_at`,
      [req.user.userId, start_latitude, start_longitude, end_latitude, end_longitude, estimated_time, estimated_cost, is_favorite]
    );

    const trip = result.rows[0];

    res.status(201).json({
      message: 'Trajet sauvegardé',
      trip: {
        tripId: trip.trip_id,
        startLatitude: parseFloat(trip.start_latitude),
        startLongitude: parseFloat(trip.start_longitude),
        endLatitude: parseFloat(trip.end_latitude),
        endLongitude: parseFloat(trip.end_longitude),
        estimatedTime: trip.estimated_time,
        estimatedCost: trip.estimated_cost ? parseFloat(trip.estimated_cost) : null,
        isFavorite: trip.is_favorite,
        createdAt: trip.created_at,
      },
    });
  } catch (error) {
    console.error('Erreur sauvegarde trajet:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
