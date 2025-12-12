const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

app.use(cors());
app.use(express.json());

// Base de données
const db = new sqlite3.Database('./database.db');

// Création des tables
db.serialize(() => {
    db.run(`
    CREATE TABLE IF NOT EXISTS reports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT,
      category TEXT,
      description TEXT,
      location TEXT,
      urgency INTEGER,
      status TEXT DEFAULT 'pending',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

    db.run(`
    CREATE TABLE IF NOT EXISTS users (
      anonymous_id TEXT PRIMARY KEY,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
});

// Routes
app.post('/api/report', (req, res) => {
    const { userId, category, description, location, urgency } = req.body;

    db.run(
        `INSERT INTO reports (user_id, category, description, location, urgency, status) 
     VALUES (?, ?, ?, ?, ?, 'pending')`,
        [userId, category, description, location, urgency],
        function (err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }

            // Notifier tous les administrateurs
            db.get('SELECT * FROM reports WHERE id = ?', [this.lastID], (err, row) => {
                io.emit('new_report', row);
            });

            res.json({
                success: true,
                reportId: this.lastID,
                message: 'Signalement envoyé avec succès'
            });
        }
    );
});

app.get('/api/admin/reports', (req, res) => {
    db.all('SELECT * FROM reports ORDER BY created_at DESC', (err, rows) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }

        // Statistiques en une seule requête
        db.get(`
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                SUM(CASE WHEN status = 'resolved' THEN 1 ELSE 0 END) as resolved
            FROM reports
        `, (err, stats) => {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }

            // Valeurs par défaut si null
            const safeStats = {
                total: stats?.total || 0,
                pending: stats?.pending || 0,
                resolved: stats?.resolved || 0
            };

            res.json({
                reports: rows || [],
                stats: safeStats
            });
        });
    });
});

app.put('/api/admin/reports/:id', (req, res) => {
    const { status } = req.body;

    db.run(
        'UPDATE reports SET status = ? WHERE id = ?',
        [status, req.params.id],
        function (err) {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }

            // Notifier l'utilisateur concerné
            db.get('SELECT * FROM reports WHERE id = ?', [req.params.id], (err, row) => {
                if (row?.user_id) {
                    io.emit(`status_update_${row.user_id}`, row);
                }
            });

            res.json({ success: true });
        }
    );
});

app.get('/api/user/reports/:userId', (req, res) => {
    db.all(
        'SELECT * FROM reports WHERE user_id = ? ORDER BY created_at DESC',
        [req.params.userId],
        (err, rows) => {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json(rows || []);
        }
    );
});

// Générer un ID utilisateur anonyme
app.post('/api/generate-user-id', (req, res) => {
    const userId = 'USER_' + Math.random().toString(36).substr(2, 9).toUpperCase();

    db.run(
        'INSERT OR IGNORE INTO users (anonymous_id) VALUES (?)',
        [userId],
        (err) => {
            if (err) {
                res.status(500).json({ error: err.message });
                return;
            }
            res.json({ userId });
        }
    );
});

// Authentification admin
const ADMIN_USERNAME = "admin";
const ADMIN_PASSWORD = "anac2024";

app.post('/api/admin/login', (req, res) => {
    const { username, password } = req.body;

    if (username === ADMIN_USERNAME && password === ADMIN_PASSWORD) {
        res.json({ success: true, token: 'admin-token-prototype' });
    } else {
        res.status(401).json({ success: false, message: 'Identifiants incorrects' });
    }
});

// Route pour les stats admin
app.get('/api/admin/dashboard-stats', (req, res) => {
    db.get(`
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
      SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress,
      SUM(CASE WHEN status = 'resolved' THEN 1 ELSE 0 END) as resolved
    FROM reports
  `, (err, row) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }

        // Valeurs par défaut
        const safeStats = {
            total: row?.total || 0,
            pending: row?.pending || 0,
            in_progress: row?.in_progress || 0,
            resolved: row?.resolved || 0
        };

        res.json(safeStats);
    });
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`✅ Serveur backend démarré sur http://localhost:${PORT}`);
    console.log(`📊 API disponible: http://localhost:${PORT}/api/admin/reports`);
});