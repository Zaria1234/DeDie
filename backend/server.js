const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, { cors: { origin: "*" } });

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

    console.log('✅ Tables créées/verifiées');
});

// Route pour recevoir les signalements MOBILE
app.post('/api/report', (req, res) => {
    console.log('📱 Signalement reçu du mobile:', req.body);

    const { userId, category, description, location } = req.body;

    // Validation
    if (!userId || !category || !description || !location) {
        return res.status(400).json({
            success: false,
            error: 'Données manquantes'
        });
    }

    // 1. Stocke en base
    db.run(
        `INSERT INTO reports (user_id, category, description, location, status) 
         VALUES (?, ?, ?, ?, 'pending')`,
        [userId, category, description, location],
        function (err) {
            if (err) {
                console.error('❌ Erreur SQL:', err);
                return res.status(500).json({
                    success: false,
                    error: err.message
                });
            }

            // 2. Récupère le signalement complet
            db.get('SELECT * FROM reports WHERE id = ?', [this.lastID], (err, row) => {
                if (err) {
                    console.error('❌ Erreur récupération:', err);
                    return res.status(500).json({
                        success: false,
                        error: err.message
                    });
                }

                console.log('📨 Nouveau signalement stocké:', row);

                // 3. Envoie en temps réel aux dashboards WEB (Socket.io)
                io.emit('new_report', row);

                // 4. Répond au mobile
                res.json({
                    success: true,
                    reportId: this.lastID,
                    message: 'Signalement envoyé avec succès'
                });
            });
        }
    );
});

// Route pour les dashboards WEB (polling)
app.get('/api/admin/reports', (req, res) => {
    db.all('SELECT * FROM reports ORDER BY created_at DESC', (err, rows) => {
        if (err) {
            console.error('❌ Erreur récupération reports:', err);
            return res.status(500).json({ error: err.message });
        }
        res.json({
            reports: rows || [],
            count: rows ? rows.length : 0
        });
    });
});

// Route pour les statistiques (polling)
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
            console.error('❌ Erreur stats:', err);
            return res.status(500).json({ error: err.message });
        }

        const stats = {
            total: row?.total || 0,
            pending: row?.pending || 0,
            in_progress: row?.in_progress || 0,
            resolved: row?.resolved || 0
        };

        res.json(stats);
    });
});

// Générer un ID utilisateur anonyme
app.post('/api/generate-user-id', (req, res) => {
    const userId = 'USER_' + Math.random().toString(36).substr(2, 9).toUpperCase();

    db.run(
        'INSERT OR IGNORE INTO users (anonymous_id) VALUES (?)',
        [userId],
        (err) => {
            if (err) {
                console.error('❌ Erreur génération ID:', err);
                return res.status(500).json({ error: err.message });
            }

            console.log('🆔 ID généré:', userId);
            res.json({ userId });
        }
    );
});

// Authentification admin
app.post('/api/admin/login', (req, res) => {
    const { username, password } = req.body;

    // Pour le prototype
    if (username === 'admin' && password === 'anac2024') {
        console.log('🔐 Admin connecté:', username);
        res.json({
            success: true,
            token: 'admin-token-prototype',
            user: { username, role: 'admin' }
        });
    } else {
        console.log('❌ Tentative de connexion échouée:', username);
        res.status(401).json({
            success: false,
            message: 'Identifiants incorrects'
        });
    }
});

// Mettre à jour le statut d'un signalement
app.put('/api/admin/reports/:id', (req, res) => {
    const { status } = req.body;
    const reportId = req.params.id;

    if (!['pending', 'in_progress', 'resolved'].includes(status)) {
        return res.status(400).json({
            success: false,
            error: 'Statut invalide'
        });
    }

    db.run(
        'UPDATE reports SET status = ? WHERE id = ?',
        [status, reportId],
        function (err) {
            if (err) {
                console.error('❌ Erreur mise à jour:', err);
                return res.status(500).json({
                    success: false,
                    error: err.message
                });
            }

            if (this.changes === 0) {
                return res.status(404).json({
                    success: false,
                    error: 'Signalement non trouvé'
                });
            }

            // Récupérer le signalement mis à jour
            db.get('SELECT * FROM reports WHERE id = ?', [reportId], (err, row) => {
                if (err) {
                    console.error('❌ Erreur récupération:', err);
                    return res.status(500).json({
                        success: false,
                        error: err.message
                    });
                }

                // Notifier les dashboards
                io.emit('status_update', row);

                res.json({
                    success: true,
                    message: 'Statut mis à jour',
                    report: row
                });
            });
        }
    );
});

// Récupérer les signalements d'un utilisateur
app.get('/api/user/reports/:userId', (req, res) => {
    const userId = req.params.userId;

    db.all(
        'SELECT * FROM reports WHERE user_id = ? ORDER BY created_at DESC',
        [userId],
        (err, rows) => {
            if (err) {
                console.error('❌ Erreur récupération user reports:', err);
                return res.status(500).json({ error: err.message });
            }
            res.json(rows || []);
        }
    );
});

// Route de test
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        service: 'ĐeDie API'
    });
});

// Gestion des erreurs 404
app.use((req, res) => {
    res.status(404).json({
        error: 'Route non trouvée',
        path: req.path
    });
});

// Démarrer le serveur
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log('✅ BACKEND ĐeDie DÉMARRÉ');
    console.log('='.repeat(50));
    console.log(`📡 API: http://localhost:${PORT}`);
    console.log(`📱 Mobile (Android): http://10.0.2.2:${PORT}`);
    console.log(`💻 Web: http://localhost:${PORT}`);
    console.log('');
    console.log('📊 Endpoints disponibles:');
    console.log(`  POST   /api/report              - Envoyer un signalement`);
    console.log(`  GET    /api/admin/reports       - Liste des signalements`);
    console.log(`  GET    /api/admin/dashboard-stats - Statistiques`);
    console.log(`  POST   /api/admin/login         - Connexion admin`);
    console.log(`  PUT    /api/admin/reports/:id   - Mettre à jour statut`);
    console.log(`  POST   /api/generate-user-id    - Générer ID anonyme`);
    console.log(`  GET    /api/health              - Vérifier santé API`);
    console.log('='.repeat(50));
});