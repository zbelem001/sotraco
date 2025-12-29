const db = require('../config/database');

const requireAdmin = async (req, res, next) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'Non authentifié' });
    }

    // Vérifier le role de l'utilisateur
    const result = await db.query(
      `SELECT role FROM ${process.env.DB_SCHEMA}.users WHERE user_id = $1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    const userRole = result.rows[0].role;

    if (userRole !== 'admin' && userRole !== 'super_admin') {
      return res.status(403).json({ 
        error: 'Accès refusé - Droits administrateur requis' 
      });
    }

    req.user.role = userRole;
    next();
  } catch (error) {
    console.error('Erreur vérification admin:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

const requireSuperAdmin = async (req, res, next) => {
  try {
    if (!req.user || !req.user.userId) {
      return res.status(401).json({ error: 'Non authentifié' });
    }

    const result = await db.query(
      `SELECT role FROM ${process.env.DB_SCHEMA}.users WHERE user_id = $1`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    if (result.rows[0].role !== 'super_admin') {
      return res.status(403).json({ 
        error: 'Accès refusé - Droits super administrateur requis' 
      });
    }

    req.user.role = 'super_admin';
    next();
  } catch (error) {
    console.error('Erreur vérification super admin:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
};

module.exports = {
  requireAdmin,
  requireSuperAdmin,
};
