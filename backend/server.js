const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de sécurité
app.use(helmet());

// CORS configuration
const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = process.env.CORS_ORIGINS?.split(',') || ['http://localhost:*'];
    
    // Autoriser les requêtes sans origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    // Vérifier si l'origin correspond à un pattern autorisé
    const isAllowed = allowedOrigins.some(pattern => {
      if (pattern.includes('*')) {
        const regex = new RegExp(pattern.replace('*', '.*'));
        return regex.test(origin);
      }
      return pattern === origin;
    });
    
    if (isAllowed) {
      callback(null, true);
    } else {
      callback(new Error('Non autorisé par CORS'));
    }
  },
  credentials: true,
};

app.use(cors(corsOptions));

// Logging
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limite chaque IP à 100 requêtes par fenêtre
  message: 'Trop de requêtes depuis cette IP, réessayez plus tard',
});

app.use('/api/', limiter);

// Routes
const authRoutes = require('./routes/auth');
const linesRoutes = require('./routes/lines');
const stopsRoutes = require('./routes/stops');
const busesRoutes = require('./routes/buses');
const alertsRoutes = require('./routes/alerts');
const usersRoutes = require('./routes/users');
const adminRoutes = require('./routes/admin');

app.use('/api/auth', authRoutes);
app.use('/api/lines', linesRoutes);
app.use('/api/stops', stopsRoutes);
app.use('/api/buses', busesRoutes);
app.use('/api/alerts', alertsRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/admin', adminRoutes);

// Route de santé
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    database: {
      host: process.env.DB_HOST,
      database: process.env.DB_NAME,
      schema: process.env.DB_SCHEMA,
    },
  });
});

// Route racine
app.get('/', (req, res) => {
  res.json({
    name: 'Dôrô Wéré API',
    version: '1.0.0',
    description: 'API Backend pour l\'application de transport urbain intelligent',
    endpoints: {
      auth: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login',
        demo: 'POST /api/auth/demo',
      },
      lines: {
        list: 'GET /api/lines',
        details: 'GET /api/lines/:id',
      },
      stops: {
        list: 'GET /api/stops',
        details: 'GET /api/stops/:id',
        nearby: 'GET /api/stops/nearby?lat=&lng=&radius=',
      },
      buses: {
        list: 'GET /api/buses',
        details: 'GET /api/buses/:id',
        nearby: 'GET /api/buses/nearby?lat=&lng=&radius=',
      },
      alerts: {
        list: 'GET /api/alerts',
        nearby: 'GET /api/alerts/nearby?lat=&lng=&radius=',
        create: 'POST /api/alerts (auth required)',
        vote: 'POST /api/alerts/:id/vote (auth required)',
      },
      users: {
        profile: 'GET /api/users/me (auth required)',
        updateProfile: 'PUT /api/users/me (auth required)',
        updateLocation: 'POST /api/users/me/location (auth required)',
        trips: 'GET /api/users/me/trips (auth required)',
        saveTrip: 'POST /api/users/me/trips (auth required)',
      },
      admin: {
        stats: 'GET /api/admin/stats (admin required)',
        users: 'GET /api/admin/users (admin required)',
        createLine: 'POST /api/admin/lines (admin required)',
        createStop: 'POST /api/admin/stops (admin required)',
        createBus: 'POST /api/admin/buses (admin required)',
        manageAll: 'Full CRUD operations (admin required)',
      },
    },
  });
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Gestion globale des erreurs
app.use((err, req, res, next) => {
  console.error('Erreur globale:', err);
  res.status(err.status || 500).json({
    error: process.env.NODE_ENV === 'production' 
      ? 'Une erreur est survenue' 
      : err.message,
  });
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log('='.repeat(50));
  console.log(`🚀 Dôrô Wéré API Server`);
  console.log(`📡 Port: ${PORT}`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV}`);
  console.log(`💾 Base de données: ${process.env.DB_NAME}`);
  console.log(`📊 Schema: ${process.env.DB_SCHEMA}`);
  console.log('='.repeat(50));
  console.log(`\n✅ Serveur démarré sur http://localhost:${PORT}`);
  console.log(`📚 Documentation: http://localhost:${PORT}/`);
  console.log(`❤️  Health check: http://localhost:${PORT}/health\n`);
});

// Gestion propre de l'arrêt
process.on('SIGTERM', () => {
  console.log('SIGTERM reçu, arrêt du serveur...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\nSIGINT reçu, arrêt du serveur...');
  process.exit(0);
});

module.exports = app;
