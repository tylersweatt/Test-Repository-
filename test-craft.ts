import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const baseUrl = 'https://connect.craft.do/links/Hn7UdVqh6ie/api/v1';
const apiToken = process.env.CRAFT_API_TOKEN!;

async function testCraftAuth() {
  console.log('Testing Craft API with different authentication methods...\n');
  console.log('Base URL:', baseUrl);
  console.log('Token:', apiToken.substring(0, 10) + '...\n');

  const endpoints = ['/', '/spaces', '/documents'];

  const authMethods = [
    { name: 'X-API-Key header', headers: { 'X-API-Key': apiToken, 'Content-Type': 'application/json' } },
    { name: 'Authorization: Bearer', headers: { 'Authorization': `Bearer ${apiToken}`, 'Content-Type': 'application/json' } },
    { name: 'Authorization: Token', headers: { 'Authorization': `Token ${apiToken}`, 'Content-Type': 'application/json' } },
    { name: 'x-craft-api-key', headers: { 'x-craft-api-key': apiToken, 'Content-Type': 'application/json' } },
  ];

  for (const method of authMethods) {
    console.log(`\nTrying: ${method.name}`);
    console.log('─'.repeat(50));

    for (const endpoint of endpoints) {
      try {
        const url = `${baseUrl}${endpoint}`;
        console.log(`  Testing ${endpoint}...`);
        const response = await axios.get(url, { headers: method.headers });
        console.log(`  ✓ SUCCESS on ${endpoint}!`);
        console.log('  Response status:', response.status);
        console.log('  Response data:', JSON.stringify(response.data, null, 2).substring(0, 200));
        return; // Exit on first success
      } catch (error: any) {
        if (error.response) {
          console.log(`  ✗ ${endpoint}: ${error.response.status} ${error.response.statusText}`);
          if (error.response.data) {
            console.log(`    Data:`, JSON.stringify(error.response.data).substring(0, 100));
          }
        } else {
          console.log(`  ✗ ${endpoint}: ${error.message}`);
        }
      }
    }
  }

  console.log('\n\n❌ No authentication method worked. Craft API may require:');
  console.log('  1. Different authentication approach (OAuth, etc.)');
  console.log('  2. Additional headers or configuration');
  console.log('  3. MCP (Model Context Protocol) instead of REST API');
}

testCraftAuth();
