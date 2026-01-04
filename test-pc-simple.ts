import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

async function testPlanningCenter() {
  console.log('Testing Planning Center API connection...\n');

  const appId = process.env.PLANNING_CENTER_APP_ID;
  const secret = process.env.PLANNING_CENTER_SECRET;

  console.log('App ID:', appId?.substring(0, 10) + '...');
  console.log('Secret:', secret?.substring(0, 10) + '...\n');

  try {
    const response = await axios.get('https://api.planningcenteronline.com/people/v2/me', {
      auth: {
        username: appId!,
        password: secret!,
      },
      headers: {
        'Content-Type': 'application/json',
      },
    });

    console.log('✓ Successfully connected to Planning Center!');
    console.log('User info:', response.data);
  } catch (error: any) {
    console.error('✗ Error connecting to Planning Center:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Status Text:', error.response.statusText);
      console.error('Data:', error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  }
}

testPlanningCenter();
