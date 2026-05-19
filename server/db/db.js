const sql = require('mssql');

const rawServer = process.env.DB_HOST || 'localhost';
const [server, embeddedInstanceName] = rawServer.split('\\');
const instanceName = process.env.DB_INSTANCE || embeddedInstanceName;
const port = process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined;

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  server,
  database: process.env.DB_NAME,
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true,
    ...(instanceName ? { instanceName } : {})
  }
};

if (port && !Number.isNaN(port) && !instanceName) {
  config.port = port;
}

let pool;

function cloneConfig(baseConfig, overrides = {}) {
  return {
    ...baseConfig,
    ...overrides,
    options: {
      ...baseConfig.options,
      ...(overrides.options || {})
    }
  };
}

function getConnectionCandidates() {
  const candidates = [config];

  if (!instanceName && !config.port && ['localhost', '127.0.0.1'].includes(server.toLowerCase())) {
    candidates.push(cloneConfig(config, { options: { instanceName: 'SQLEXPRESS' } }));
    candidates.push(cloneConfig(config, { options: { instanceName: 'SQLEXPRESS01' } }));
  }

  return candidates;
}

function formatConnectionTarget(connectionConfig) {
  const target = connectionConfig.options.instanceName
    ? `${connectionConfig.server}\\${connectionConfig.options.instanceName}`
    : connectionConfig.port
      ? `${connectionConfig.server}:${connectionConfig.port}`
      : connectionConfig.server;

  return `${target} / ${connectionConfig.database}`;
}

async function getPool() {
  if (pool && pool.connected) {
    return pool;
  }

  let lastError;

  for (const connectionConfig of getConnectionCandidates()) {
    try {
      pool = await new sql.ConnectionPool(connectionConfig).connect();
      return pool;
    } catch (error) {
      lastError = error;

      if (!error || error.code !== 'ESOCKET') {
        break;
      }
    }
  }

  pool = undefined;

  if (lastError && lastError.code === 'ESOCKET') {
    const connectionTarget = getConnectionCandidates().map(formatConnectionTarget).join(', ');

    throw new Error(
      `Unable to connect to SQL Server. Tried: ${connectionTarget}. ` +
      'If you are using a named instance, set DB_INSTANCE or include the instance in DB_HOST. ' +
      'If you are connecting by port, set DB_PORT. '
    );
  }

  throw lastError;
}

module.exports = { sql, getPool };
