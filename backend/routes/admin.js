const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { requireAdmin } = require('../middleware/admin');

// Toutes les routes nécessitent l'authentification ET les droits admin
router.use(authenticateToken);
router.use(requireAdmin);

// ========================================
// STATISTIQUES GLOBALES
// ========================================

router.get('/stats', async (req, res) => {
  try {
    const stats = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM dorowere.users) as total_users,
        (SELECT COUNT(*) FROM dorowere.users WHERE role = 'driver') as total_drivers,
        (SELECT COUNT(*) FROM dorowere.users WHERE role = 'admin') as total_admins,
        (SELECT COUNT(*) FROM dorowere.lines) as total_lines,
        (SELECT COUNT(*) FROM dorowere.stops) as total_stops,
        (SELECT COUNT(*) FROM dorowere.buses) as total_buses,
        (SELECT COUNT(*) FROM dorowere.buses WHERE is_active = true) as active_buses,
        (SELECT COUNT(*) FROM dorowere.alerts WHERE expires_at > CURRENT_TIMESTAMP) as active_alerts,
        (SELECT COUNT(*) FROM dorowere.alerts) as total_alerts,
        (SELECT COUNT(*) FROM dorowere.trips) as total_trips
    `);

    const recentActivity = await pool.query(`
      (SELECT 'user' as type, created_at FROM dorowere.users ORDER BY created_at DESC LIMIT 5)
      UNION ALL
      (SELECT 'alert' as type, created_at FROM dorowere.alerts ORDER BY created_at DESC LIMIT 5)
      UNION ALL
      (SELECT 'trip' as type, created_at FROM dorowere.trips ORDER BY created_at DESC LIMIT 5)
      ORDER BY created_at DESC
      LIMIT 10
    `);

    res.json({
      stats: stats.rows[0],
      recentActivity: recentActivity.rows,
    });
  } catch (error) {
    console.error('Erreur stats admin:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ========================================
// GESTION DES UTILISATEURS
// ========================================

router.get('/users', async (req, res) => {
  try {
    const { page = 1, limit = 50, role, search } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        user_id, 
        display_name, 
        phone_number, 
        role, 
        avatar_id, 
        created_at, 
        last_seen,
        (SELECT COUNT(*) FROM dorowere.trips WHERE user_id = u.user_id) as trips_count
      FROM dorowere.users u
      WHERE 1=1
    `;
    const params = [];
    let paramIndex = 1;

    if (role) {
      query += ` AND role = $${paramIndex++}`;
      params.push(role);
    }

    if (search) {
      query += ` AND (display_name ILIKE $${paramIndex} OR phone_number ILIKE $${paramIndex + 1})`;
      params.push(`%${search}%`, `%${search}%`);
      paramIndex += 2;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countQuery = `SELECT COUNT(*) FROM dorowere.users WHERE 1=1` +
      (role ? ` AND role = '${role}'` : '') +
      (search ? ` AND (display_name ILIKE '%${search}%' OR phone_number ILIKE '%${search}%')` : '');
    const countResult = await pool.query(countQuery);

    res.json({
      users: result.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      limit: parseInt(limit),
    });
  } catch (error) {
    console.error('Erreur get users:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.put('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { display_name, role, phone_number } = req.body;

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (display_name !== undefined) {
      updates.push(`display_name = $${paramIndex++}`);
      params.push(display_name);
    }
    if (role !== undefined) {
      updates.push(`role = $${paramIndex++}`);
      params.push(role);
    }
    if (phone_number !== undefined) {
      updates.push(`phone_number = $${paramIndex++}`);
      params.push(phone_number);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'Aucune mise à jour fournie' });
    }

    params.push(userId);
    const query = `
      UPDATE dorowere.users 
      SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE user_id = $${paramIndex}
      RETURNING user_id, display_name, phone_number, role, updated_at
    `;

    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    res.json({ user: result.rows[0], message: 'Utilisateur mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur update user:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.delete('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    if (userId === req.user.user_id) {
      return res.status(400).json({ error: 'Vous ne pouvez pas supprimer votre propre compte' });
    }

    await pool.query('DELETE FROM dorowere.users WHERE user_id = $1', [userId]);

    res.json({ message: 'Utilisateur supprimé avec succès' });
  } catch (error) {
    console.error('Erreur delete user:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ========================================
// GESTION DES LIGNES
// ========================================

router.post('/lines', async (req, res) => {
  try {
    const { line_number, line_name, start_point, end_point, color, description } = req.body;

    if (!line_number || !line_name) {
      return res.status(400).json({ error: 'Numéro et nom de ligne requis' });
    }

    const result = await pool.query(
      `INSERT INTO dorowere.lines (line_number, line_name, start_point, end_point, color, description)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [line_number, line_name, start_point, end_point, color || '#FF6B35', description]
    );

    res.status(201).json({ line: result.rows[0], message: 'Ligne créée avec succès' });
  } catch (error) {
    console.error('Erreur create line:', error);
    if (error.code === '23505') {
      res.status(400).json({ error: 'Ce numéro de ligne existe déjà' });
    } else {
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
});

router.put('/lines/:lineId', async (req, res) => {
  try {
    const { lineId } = req.params;
    const { line_number, line_name, start_point, end_point, color, description, is_active } = req.body;

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (line_number !== undefined) {
      updates.push(`line_number = $${paramIndex++}`);
      params.push(line_number);
    }
    if (line_name !== undefined) {
      updates.push(`line_name = $${paramIndex++}`);
      params.push(line_name);
    }
    if (start_point !== undefined) {
      updates.push(`start_point = $${paramIndex++}`);
      params.push(start_point);
    }
    if (end_point !== undefined) {
      updates.push(`end_point = $${paramIndex++}`);
      params.push(end_point);
    }
    if (color !== undefined) {
      updates.push(`color = $${paramIndex++}`);
      params.push(color);
    }
    if (description !== undefined) {
      updates.push(`description = $${paramIndex++}`);
      params.push(description);
    }
    if (is_active !== undefined) {
      updates.push(`is_active = $${paramIndex++}`);
      params.push(is_active);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'Aucune mise à jour fournie' });
    }

    params.push(lineId);
    const query = `
      UPDATE dorowere.lines 
      SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE line_id = $${paramIndex}
      RETURNING *
    `;

    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Ligne non trouvée' });
    }

    res.json({ line: result.rows[0], message: 'Ligne mise à jour avec succès' });
  } catch (error) {
    console.error('Erreur update line:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.delete('/lines/:lineId', async (req, res) => {
  try {
    const { lineId } = req.params;

    const busCheck = await pool.query(
      'SELECT COUNT(*) FROM dorowere.buses WHERE line_id = $1',
      [lineId]
    );

    if (parseInt(busCheck.rows[0].count) > 0) {
      return res.status(400).json({ 
        error: 'Impossible de supprimer cette ligne car des bus y sont assignés' 
      });
    }

    await pool.query('DELETE FROM dorowere.lines WHERE line_id = $1', [lineId]);

    res.json({ message: 'Ligne supprimée avec succès' });
  } catch (error) {
    console.error('Erreur delete line:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ========================================
// GESTION DES ARRÊTS
// ========================================

router.post('/stops', async (req, res) => {
  try {
    const { stop_name, stop_code, latitude, longitude, description } = req.body;

    if (!stop_name || !latitude || !longitude) {
      return res.status(400).json({ error: 'Nom, latitude et longitude requis' });
    }

    const result = await pool.query(
      `INSERT INTO dorowere.stops (stop_name, stop_code, latitude, longitude, description)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [stop_name, stop_code, latitude, longitude, description]
    );

    res.status(201).json({ stop: result.rows[0], message: 'Arrêt créé avec succès' });
  } catch (error) {
    console.error('Erreur create stop:', error);
    if (error.code === '23505') {
      res.status(400).json({ error: 'Ce code d\'arrêt existe déjà' });
    } else {
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
});

router.put('/stops/:stopId', async (req, res) => {
  try {
    const { stopId } = req.params;
    const { stop_name, stop_code, latitude, longitude, description, is_active } = req.body;

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (stop_name !== undefined) {
      updates.push(`stop_name = $${paramIndex++}`);
      params.push(stop_name);
    }
    if (stop_code !== undefined) {
      updates.push(`stop_code = $${paramIndex++}`);
      params.push(stop_code);
    }
    if (latitude !== undefined) {
      updates.push(`latitude = $${paramIndex++}`);
      params.push(latitude);
    }
    if (longitude !== undefined) {
      updates.push(`longitude = $${paramIndex++}`);
      params.push(longitude);
    }
    if (description !== undefined) {
      updates.push(`description = $${paramIndex++}`);
      params.push(description);
    }
    if (is_active !== undefined) {
      updates.push(`is_active = $${paramIndex++}`);
      params.push(is_active);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'Aucune mise à jour fournie' });
    }

    params.push(stopId);
    const query = `
      UPDATE dorowere.stops 
      SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE stop_id = $${paramIndex}
      RETURNING *
    `;

    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Arrêt non trouvé' });
    }

    res.json({ stop: result.rows[0], message: 'Arrêt mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur update stop:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.delete('/stops/:stopId', async (req, res) => {
  try {
    const { stopId } = req.params;

    await pool.query('DELETE FROM dorowere.stops WHERE stop_id = $1', [stopId]);

    res.json({ message: 'Arrêt supprimé avec succès' });
  } catch (error) {
    console.error('Erreur delete stop:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.post('/lines/:lineId/stops/:stopId', async (req, res) => {
  try {
    const { lineId, stopId } = req.params;
    const { sequence_order } = req.body;

    if (!sequence_order) {
      return res.status(400).json({ error: 'sequence_order requis' });
    }

    const result = await pool.query(
      `INSERT INTO dorowere.line_stops (line_id, stop_id, sequence_order)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [lineId, stopId, sequence_order]
    );

    res.status(201).json({ 
      lineStop: result.rows[0], 
      message: 'Arrêt ajouté à la ligne avec succès' 
    });
  } catch (error) {
    console.error('Erreur add stop to line:', error);
    if (error.code === '23505') {
      res.status(400).json({ error: 'Cet arrêt est déjà dans cette ligne' });
    } else {
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
});

router.delete('/lines/:lineId/stops/:stopId', async (req, res) => {
  try {
    const { lineId, stopId } = req.params;

    await pool.query(
      'DELETE FROM dorowere.line_stops WHERE line_id = $1 AND stop_id = $2',
      [lineId, stopId]
    );

    res.json({ message: 'Arrêt retiré de la ligne avec succès' });
  } catch (error) {
    console.error('Erreur remove stop from line:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ========================================
// GESTION DES BUS
// ========================================

router.post('/buses', async (req, res) => {
  try {
    const { bus_number, line_id, capacity, description } = req.body;

    if (!bus_number || !line_id) {
      return res.status(400).json({ error: 'Numéro de bus et ligne requis' });
    }

    const result = await pool.query(
      `INSERT INTO dorowere.buses (bus_number, line_id, capacity, description)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [bus_number, line_id, capacity || 45, description]
    );

    res.status(201).json({ bus: result.rows[0], message: 'Bus créé avec succès' });
  } catch (error) {
    console.error('Erreur create bus:', error);
    if (error.code === '23505') {
      res.status(400).json({ error: 'Ce numéro de bus existe déjà' });
    } else if (error.code === '23503') {
      res.status(400).json({ error: 'Ligne non trouvée' });
    } else {
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
});

router.put('/buses/:busId', async (req, res) => {
  try {
    const { busId } = req.params;
    const { bus_number, line_id, capacity, description, is_active } = req.body;

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (bus_number !== undefined) {
      updates.push(`bus_number = $${paramIndex++}`);
      params.push(bus_number);
    }
    if (line_id !== undefined) {
      updates.push(`line_id = $${paramIndex++}`);
      params.push(line_id);
    }
    if (capacity !== undefined) {
      updates.push(`capacity = $${paramIndex++}`);
      params.push(capacity);
    }
    if (description !== undefined) {
      updates.push(`description = $${paramIndex++}`);
      params.push(description);
    }
    if (is_active !== undefined) {
      updates.push(`is_active = $${paramIndex++}`);
      params.push(is_active);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'Aucune mise à jour fournie' });
    }

    params.push(busId);
    const query = `
      UPDATE dorowere.buses 
      SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE bus_id = $${paramIndex}
      RETURNING *
    `;

    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Bus non trouvé' });
    }

    res.json({ bus: result.rows[0], message: 'Bus mis à jour avec succès' });
  } catch (error) {
    console.error('Erreur update bus:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.delete('/buses/:busId', async (req, res) => {
  try {
    const { busId } = req.params;

    await pool.query('DELETE FROM dorowere.buses WHERE bus_id = $1', [busId]);

    res.json({ message: 'Bus supprimé avec succès' });
  } catch (error) {
    console.error('Erreur delete bus:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ========================================
// GESTION DES ALERTES
// ========================================

router.get('/alerts', async (req, res) => {
  try {
    const { page = 1, limit = 50, type, status = 'all' } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        a.*,
        u.display_name as reporter_name,
        (SELECT COUNT(*) FROM dorowere.alert_votes WHERE alert_id = a.alert_id AND vote_type = 'confirm') as confirms,
        (SELECT COUNT(*) FROM dorowere.alert_votes WHERE alert_id = a.alert_id AND vote_type = 'deny') as denies
      FROM dorowere.alerts a
      LEFT JOIN dorowere.users u ON a.user_id = u.user_id
      WHERE 1=1
    `;
    const params = [];
    let paramIndex = 1;

    if (type) {
      query += ` AND a.alert_type = $${paramIndex++}`;
      params.push(type);
    }

    if (status === 'active') {
      query += ` AND a.expires_at > CURRENT_TIMESTAMP`;
    } else if (status === 'expired') {
      query += ` AND a.expires_at <= CURRENT_TIMESTAMP`;
    }

    query += ` ORDER BY a.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countQuery = `SELECT COUNT(*) FROM dorowere.alerts a WHERE 1=1` +
      (type ? ` AND alert_type = '${type}'` : '') +
      (status === 'active' ? ` AND expires_at > CURRENT_TIMESTAMP` : '') +
      (status === 'expired' ? ` AND expires_at <= CURRENT_TIMESTAMP` : '');
    const countResult = await pool.query(countQuery);

    res.json({
      alerts: result.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      limit: parseInt(limit),
    });
  } catch (error) {
    console.error('Erreur get alerts:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.delete('/alerts/:alertId', async (req, res) => {
  try {
    const { alertId } = req.params;

    await pool.query('DELETE FROM dorowere.alerts WHERE alert_id = $1', [alertId]);

    res.json({ message: 'Alerte supprimée avec succès' });
  } catch (error) {
    console.error('Erreur delete alert:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
