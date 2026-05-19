const useTrustedConnection = ['1', 'true', 'yes'].includes(String(process.env.DB_TRUSTED_CONNECTION || '').toLowerCase());
const useEncryption = !['0', 'false', 'no'].includes(String(process.env.DB_ENCRYPT || 'true').toLowerCase());
const sql = useTrustedConnection ? require('mssql/msnodesqlv8') : require('mssql');

const odbcDriver = process.env.DB_DRIVER || 'ODBC Driver 18 for SQL Server';

const rawServer = process.env.DB_HOST || 'localhost';
const [server, embeddedInstanceName] = rawServer.split('\\');
const instanceName = process.env.DB_INSTANCE || embeddedInstanceName;
const port = process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined;

const config = {
  server,
  database: process.env.DB_NAME || 'SecureShopDB',
  options: {
    encrypt: useEncryption,
    trustServerCertificate: true,
    enableArithAbort: true,
    ...(instanceName ? { instanceName } : {})
  }
};

function logDbStartup() {
  const target = instanceName
    ? `${server}\\${instanceName}`
    : port && !Number.isNaN(port)
      ? `${server}:${port}`
      : server;
  const authMode = useTrustedConnection ? 'Windows trusted connection' : 'SQL authentication';

  console.log(
    `[db] target=${target} database=${config.database} auth=${authMode} ` +
    `driver=${useTrustedConnection ? 'msnodesqlv8' : 'mssql'} encrypt=${useEncryption ? 'on' : 'off'}`
  );
}

logDbStartup();

if (useTrustedConnection) {
  config.options.trustedConnection = true;
} else {
  config.user = process.env.DB_USER;
  config.password = process.env.DB_PASS;
}

if (port && !Number.isNaN(port) && !instanceName && !useTrustedConnection) {
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

function escapeOdbcValue(value) {
  return `{${String(value ?? '').replace(/}/g, '}}')}}`;
}

function buildConnectionString(connectionConfig) {
  const target = connectionConfig.options.instanceName
    ? `${connectionConfig.server}\\${connectionConfig.options.instanceName}`
    : connectionConfig.port
      ? `${connectionConfig.server},${connectionConfig.port}`
      : connectionConfig.server;

  const parts = [
    `Driver={${odbcDriver}}`,
    `Server=${target}`,
    `Database=${connectionConfig.database}`,
    `Encrypt=${useEncryption ? 'Yes' : 'No'}`,
    'TrustServerCertificate=Yes'
  ];

  if (useTrustedConnection) {
    parts.push('Trusted_Connection=Yes');
  } else {
    parts.push(`Uid=${escapeOdbcValue(connectionConfig.user)}`);
    parts.push(`Pwd=${escapeOdbcValue(connectionConfig.password)}`);
  }

  return parts.join(';');
}

function materializeConfig(baseConfig, overrides = {}) {
  const connectionConfig = cloneConfig(baseConfig, overrides);

  return {
    ...connectionConfig,
    connectionString: buildConnectionString(connectionConfig)
  };
}

function getConnectionCandidates() {
  const candidates = [materializeConfig(config)];

  if (!useTrustedConnection && !instanceName && !config.port && ['localhost', '127.0.0.1'].includes(server.toLowerCase())) {
    candidates.push(materializeConfig(config, { options: { instanceName: 'SQLEXPRESS' } }));
    candidates.push(materializeConfig(config, { options: { instanceName: 'SQLEXPRESS01' } }));
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
  const connectionCandidates = getConnectionCandidates();

  for (const connectionConfig of connectionCandidates) {
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

  const connectionTarget = connectionCandidates.map(formatConnectionTarget).join(', ');
  const authMode = useTrustedConnection ? 'Windows trusted connection' : 'SQL authentication';
  const baseMessage = `Unable to connect to SQL Server. Tried: ${connectionTarget}. Auth mode: ${authMode}. Database: ${config.database}.`;

  if (lastError && lastError.code === 'ESOCKET') {
    throw new Error(
      `${baseMessage} If you are using a named instance, set DB_INSTANCE or include the instance in DB_HOST. ` +
      'If you are connecting by port, set DB_PORT.'
    );
  }

  const detail = lastError && lastError.message ? lastError.message : String(lastError || 'Unknown error');
  throw new Error(`${baseMessage} Original error: ${detail}`);
}

module.exports = { sql, getPool };
