const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Générer un token JWT
const generateToken = (user) => {
  return jwt.sign(
    { userId: user.user_id, phoneNumber: user.phone_number },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

// POST /api/auth/register - Inscription
router.post('/register', async (req, res) => {
  try {
    const { name, phone_number, password } = req.body;

    // Validation
    if (!name || !phone_number || !password) {
      return res.status(400).json({ error: 'Tous les champs sont requis' });
    }

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await db.query(
      `SELECT user_id FROM ${process.env.DB_SCHEMA}.users WHERE phone_number = $1`,
      [phone_number]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ error: 'Ce numéro est déjà enregistré' });
    }

    // Hasher le mot de passe
    const passwordHash = await bcrypt.hash(password, 10);

    // Insérer l'utilisateur
    const result = await db.query(
      `INSERT INTO ${process.env.DB_SCHEMA}.users 
       (name, phone_number, password_hash, is_location_enabled, reliability_score)
       VALUES ($1, $2, $3, true, 5.0)
       RETURNING user_id, name, phone_number, reliability_score, created_at`,
      [name, phone_number, passwordHash]
    );

    const user = result.rows[0];
    const token = generateToken(user);

    res.status(201).json({
      message: 'Inscription réussie',
      token,
      user: {
        userId: user.user_id,
        name: user.name,
        phoneNumber: user.phone_number,
        reliabilityScore: user.reliability_score,
        createdAt: user.created_at,
      },
    });
  } catch (error) {
    console.error('Erreur inscription:', error);
    res.status(500).json({ error: 'Erreur serveur lors de l\'inscription' });
  }
});

// POST /api/auth/login - Connexion
router.post('/login', async (req, res) => {
  try {
    const { phone_number, password } = req.body;

    // Validation
    if (!phone_number || !password) {
      return res.status(400).json({ error: 'Téléphone et mot de passe requis' });
    }

    // Chercher l'utilisateur
    const result = await db.query(
      `SELECT user_id, name, phone_number, password_hash, reliability_score, 
              is_location_enabled, avatar_id, created_at
       FROM ${process.env.DB_SCHEMA}.users 
       WHERE phone_number = $1`,
      [phone_number]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Téléphone ou mot de passe incorrect' });
    }

    const user = result.rows[0];

    // Vérifier le mot de passe
    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      return res.status(401).json({ error: 'Téléphone ou mot de passe incorrect' });
    }

    // Générer le token
    const token = generateToken(user);

    res.json({
      message: 'Connexion réussie',
      token,
      user: {
        userId: user.user_id,
        name: user.name,
        phoneNumber: user.phone_number,
        reliabilityScore: user.reliability_score,
        isLocationEnabled: user.is_location_enabled,
        avatarId: user.avatar_id,
        createdAt: user.created_at,
      },
    });
  } catch (error) {
    console.error('Erreur connexion:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la connexion' });
  }
});

// POST /api/auth/demo - Mode démo (utilisateur test)
router.post('/demo', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT user_id, name, phone_number, reliability_score, 
              is_location_enabled, avatar_id, created_at
       FROM ${process.env.DB_SCHEMA}.users 
       WHERE phone_number = '+22670123456'`
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur démo non trouvé' });
    }

    const user = result.rows[0];
    const token = generateToken(user);

    res.json({
      message: 'Mode démo activé',
      token,
      user: {
        userId: user.user_id,
        name: user.name,
        phoneNumber: user.phone_number,
        reliabilityScore: user.reliability_score,
        isLocationEnabled: user.is_location_enabled,
        avatarId: user.avatar_id,
        createdAt: user.created_at,
      },
    });
  } catch (error) {
    console.error('Erreur mode démo:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
