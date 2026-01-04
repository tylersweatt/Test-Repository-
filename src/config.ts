import dotenv from 'dotenv';
import { IntegratorConfig } from './integrator.js';

dotenv.config();

export function loadConfig(): IntegratorConfig {
  const requiredVars = [
    'PLANNING_CENTER_APP_ID',
    'PLANNING_CENTER_SECRET',
    'CRAFT_API_TOKEN',
    'CLAUDE_API_KEY',
  ];

  const missing = requiredVars.filter(varName => !process.env[varName]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}\n` +
      'Please create a .env file with the required credentials.'
    );
  }

  return {
    planningCenter: {
      appId: process.env.PLANNING_CENTER_APP_ID!,
      secret: process.env.PLANNING_CENTER_SECRET!,
    },
    craft: {
      apiToken: process.env.CRAFT_API_TOKEN!,
    },
    claude: {
      apiKey: process.env.CLAUDE_API_KEY!,
      model: process.env.CLAUDE_MODEL,
    },
  };
}

export function validateConfig(config: IntegratorConfig): void {
  if (!config.planningCenter.appId || !config.planningCenter.secret) {
    throw new Error('Invalid Planning Center configuration');
  }

  if (!config.craft.apiToken) {
    throw new Error('Invalid Craft configuration');
  }

  if (!config.claude.apiKey) {
    throw new Error('Invalid Claude configuration');
  }
}
