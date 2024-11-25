const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const app = express();
const port = 5000;
const http = require('http');
const cors = require('cors');

dotenv.config(); // Cargar variables de entorno desde un archivo .env

app.use(express.json());
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS']
}));

// Conexión a la base de datos
const db = mysql.createPool({
    host: 'localhost', // Cambia esto si tu base de datos está en otro host
    user: 'admin', // Tu usuario de la base de datos
    password: '', // Tu contraseña de la base de datos
    database: 'bankapp', // El nombre de la base de datos
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Endpoint de registro (sin cambios)
app.post('/register', async (req, res) => {
    const { username, names, lastnames, email, password } = req.body;

    db.execute('SELECT * FROM users WHERE username = ? OR email = ?', [username, email], async (err, result) => {
        if (err) return res.status(500).json({ error: 'Error al verificar el usuario' });
        if (result.length > 0) return res.status(400).json({ error: 'El username o el email ya están en uso' });

        db.beginTransaction(async (err) => {
            if (err) return res.status(500).json({ error: 'Error al iniciar la transacción' });

            const hashedPassword = await bcrypt.hash(password, 10);

            db.execute('INSERT INTO users (username, names, lastnames, email, password) VALUES (?, ?, ?, ?, ?)',
                [username, names, lastnames, email, hashedPassword],
                (err, result) => {
                    if (err) {
                        return db.rollback(() => res.status(500).json({ error: 'Error al registrar el usuario' }));
                    }

                    const accountNumber = `${ new Date().getFullYear()
                }${(new Date().getMonth() + 1).toString().padStart(2, '0')}${ crypto.randomBytes(3).toString('hex').toUpperCase() }`;

        db.execute('INSERT INTO accounts (username, account_number, balance) VALUES (?, ?, ?)', [username, accountNumber, 0],
            (err, accountResult) => {
                if (err) {
                    return db.rollback(() => res.status(500).json({ error: 'Error al crear la cuenta bancaria' }));
                }

                db.commit((err) => {
                    if (err) {
                        return db.rollback(() => res.status(500).json({ error: 'Error al realizar el commit de la transacción' }));
                    }

                    res.status(201).json({
                        message: 'Usuario y cuenta registrados con éxito',
                        userId: result.insertId,
                        accountId: accountResult.insertId,
                        accountNumber
                    });
                });
            });
    });
});
    });
});

app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: 'Faltan credenciales' });
    }

    db.execute('SELECT * FROM users WHERE username = ?', [username], async (err, result) => {
        if (err) {
            console.error('Error en la consulta:', err);
            return res.status(500).json({ error: 'Error al verificar el usuario' });
        }

        if (result.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        const user = result[0];

        // Verificar contraseña
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Contraseña incorrecta' });
        }

        // Generar JWT
        const secret = process.env.JWT_SECRET;
        const token = jwt.sign(
            { userId: user.id, username: user.username },
            secret,
            { expiresIn: '5h' }
        );

        // Asegúrate de que estás enviando el userId y el token
        return res.status(200).json({
            message: 'Login exitoso',
            token,
            userId: user.id // Aquí estamos incluyendo el userId en la respuesta
        });
    });
});

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ error: 'Token no proporcionado' });

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Token no válido' });
        req.user = user; // Aquí debe estar userId
        next();
    });
};

app.get('/dashboard', authenticateToken, (req, res) => {
    const username = req.user.username;

    const query =`
        SELECT
    u.username,
        u.names,
        u.lastnames,
        a.account_number,
        a.balance
    FROM 
            users u
    JOIN 
            accounts a
    ON
    u.username = a.username
    WHERE
    u.username = ?;`
    ;

    db.execute(query, [username], (err, results) => {
        if (err) {
            console.error('Error en la consulta:', err);
            return res.status(500).json({ error: 'Error al obtener los datos' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'No se encontraron datos para este usuario' });
        }

        res.status(200).json(results[0]);
    });
});

app.post('/transaction', authenticateToken, async (req, res) => {
    const { amount, type, description } = req.body;
    const userId = req.user.userId;

    if (amount <= 0) {
        return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
    }

    try {
        // Obtener la cuenta del usuario
        db.getConnection((err, connection) => {
            if (err) return res.status(500).json({ error: 'Error al obtener conexión' });

            connection.beginTransaction((err) => {
                if (err) {
                    connection.release();
                    return res.status(500).json({ error: 'Error al iniciar transacción' });
                }

                // Obtener la cuenta del usuario
                connection.query('SELECT account_number, balance FROM accounts WHERE username = ?', [req.user.username], (err, result) => {
                    if (err) {
                        connection.rollback(() => {
                            connection.release();
                            return res.status(500).json({ error: 'Error al obtener la cuenta del usuario' });
                        });
                    }
                    if (result.length === 0) {
                        connection.rollback(() => {
                            connection.release();
                            return res.status(404).json({ error: 'Cuenta no encontrada' });
                        });
                    }

                    const account = result[0];
                    const { account_number, balance } = account;
                    const currentBalance = parseFloat(balance); // Convertir balance a número

                    let newBalance;

                    if (type === 'deposit') {
                        newBalance = currentBalance + amount; // Sumar saldo
                    } else if (type === 'withdrawal') {
                        if (currentBalance < amount) {
                            connection.rollback(() => {
                                connection.release();
                                return res.status(400).json({ error: 'Saldo insuficiente para retirar' });
                            });
                        }
                        newBalance = currentBalance - amount; // Restar saldo
                    } else {
                        connection.rollback(() => {
                            connection.release();
                            return res.status(400).json({ error: 'Tipo de transacción no válido' });
                        });
                    }

                    // Actualizar el balance de la cuenta
                    connection.query('UPDATE accounts SET balance = ? WHERE account_number = ?', [newBalance, account_number], (err) => {
                        if (err) {
                            connection.rollback(() => {
                                connection.release();
                                return res.status(500).json({ error: 'Error al actualizar el balance' });
                            });
                        }

                        // Registrar la transacción
                        connection.query('INSERT INTO transactions (user_id, account_number, type, amount, balance_before, balance_after, description) VALUES (?, ?, ?, ?, ?, ?, ?)',
                            [userId, account_number, type, amount, currentBalance, newBalance, description],
                            (err, result) => {
                                if (err) {
                                    connection.rollback(() => {
                                        connection.release();
                                        return res.status(500).json({ error: 'Error al registrar la transacción' });
                                    });
                                }

                                // Confirmar la transacción
                                connection.commit((err) => {
                                    if (err) {
                                        connection.rollback(() => {
                                            connection.release();
                                            return res.status(500).json({ error: 'Error al confirmar la transacción' });
                                        });
                                    }

                                    connection.release();
                                    res.status(200).json({
                                        message: 'Transacción realizada con éxito',
                                        transactionId: result.insertId,
                                        newBalance
                                    });
                                });
                            });
                    });
                });
            });
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al procesar la transacción' });
    }
});

app.get('/movements', authenticateToken, (req, res) => {
    const userId = req.user.userId; // El ID del usuario desde el token

    const query =
        `SELECT id, type, amount, balance_before, balance_after, transaction_date, status, description
        FROM transactions
        WHERE user_id = ?
        ORDER BY transaction_date DESC;`
    ;

    db.execute(query, [userId], (err, transactions) => {
        if (err) {
            console.error('Error al obtener las transacciones:', err);
            return res.status(500).json({ error: 'Error al obtener las transacciones' });
        }

        if (transactions.length === 0) {
            return res.status(404).json({ message: 'No se encontraron transacciones' });
        }

        res.status(200).json({ transactions });
    });
});

app.post('/transfer', authenticateToken, (req, res) => {
    const { from_account, to_account, amount } = req.body;

    if (!from_account || !to_account || !amount || amount <= 0) {
        return res.status(400).json({ error: "Datos de transferencia inválidos." });
    }

    const checkBalanceQuery = `
        SELECT balance 
        FROM accounts 
        WHERE account_number = ?;
    `;
    const updateBalanceQuery = `
        UPDATE accounts 
        SET balance = balance + ? 
        WHERE account_number = ?;
    `;
    const insertTransactionQuery = `
        INSERT INTO transactions (user_id, type, amount, balance_before, balance_after, transaction_date, status, description)
        VALUES (?, ?, ?, ?, ?, NOW(), ?, ?);
    `;

    db.getConnection((err, connection) => {
        if (err) {
            console.error("Error obteniendo la conexión:", err);
            return res.status(500).json({ error: "Error en el servidor." });
        }

        connection.beginTransaction((transactionErr) => {
            if (transactionErr) {
                connection.release();
                return res.status(500).json({ error: "Error iniciando la transacción." });
            }

            // Verificar saldo suficiente en la cuenta de origen
            connection.query(checkBalanceQuery, [from_account], (err, results) => {
                if (err || results.length === 0) {
                    connection.rollback(() => connection.release());
                    return res.status(404).json({ error: "Cuenta de origen no encontrada." });
                }

                const fromBalance = results[0].balance;
                if (fromBalance < amount) {
                    connection.rollback(() => connection.release());
                    return res.status(400).json({ error: "Saldo insuficiente." });
                }

                // Actualizar saldo de la cuenta de origen
                connection.query(updateBalanceQuery, [-amount, from_account], (err) => {
                    if (err) {
                        connection.rollback(() => connection.release());
                        return res.status(500).json({ error: "Error actualizando la cuenta de origen." });
                    }

                    // Actualizar saldo de la cuenta de destino
                    connection.query(updateBalanceQuery, [amount, to_account], (err) => {
                        if (err) {
                            connection.rollback(() => connection.release());
                            return res.status(500).json({ error: "Error actualizando la cuenta de destino." });
                        }

                        // Registrar transacción para ambas cuentas
                        const fromTransaction = [
                            req.user.userId,
                            "transfer-out",
                            amount,
                            fromBalance,
                            fromBalance - amount,
                            "completed",
                            `Transferencia a la cuenta ${to_account}`,
                        ];
                        const toTransaction = [
                            req.user.userId,
                            "transfer-in",
                            amount,
                            fromBalance - amount,
                            fromBalance,
                            "completed",
                            `Transferencia desde la cuenta ${from_account}`,
                        ];

                        connection.query(insertTransactionQuery, fromTransaction, (err) => {
                            if (err) {
                                connection.rollback(() => connection.release());
                                return res.status(500).json({ error: "Error registrando la transacción de salida." });
                            }

                            connection.query(insertTransactionQuery, toTransaction, (err) => {
                                if (err) {
                                    connection.rollback(() => connection.release());
                                    return res.status(500).json({ error: "Error registrando la transacción de entrada." });
                                }

                                connection.commit((commitErr) => {
                                    connection.release();
                                    if (commitErr) {
                                        return res.status(500).json({ error: "Error confirmando la transacción." });
                                    }

                                    return res.status(200).json({ message: "Transferencia exitosa." });
                                });
                            });
                        });
                    });
                });
            });
        });
    });
});



app.listen(port, () => {
    console.log(`Servidor escuchando en http://localhost:${port}`);
});