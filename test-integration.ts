import { PlanningCenterClient } from './src/clients/planning-center.js';
import { ClaudeClient } from './src/clients/claude.js';
import { loadConfig } from './src/config.js';

async function test() {
  console.log('Testing Planning Center + Claude integration...\n');

  try {
    const config = loadConfig();

    // Test Planning Center
    console.log('1. Testing Planning Center API...');
    const pc = new PlanningCenterClient(config.planningCenter);
    const events = await pc.getCalendarEvents({ per_page: 5 });
    console.log(`   ✓ Successfully fetched ${events.length} events from Planning Center\n`);

    if (events.length > 0) {
      console.log('   Sample event:');
      console.log(`   - ${events[0].attributes.name}`);
      console.log(`   - Starts: ${events[0].attributes.starts_at || 'N/A'}\n`);
    }

    // Test Claude
    console.log('2. Testing Claude API...');
    const claude = new ClaudeClient(config.claude);
    const summary = await claude.summarize(JSON.stringify(events.slice(0, 3), null, 2), 100);
    console.log('   ✓ Successfully received response from Claude\n');
    console.log('   Claude\'s summary of events:');
    console.log(`   ${summary}\n`);

    // Test integration
    console.log('3. Testing combined workflow...');
    const analysis = await claude.analyze(
      events,
      'Identify the most important upcoming events and any potential scheduling conflicts'
    );
    console.log('   ✓ Successfully analyzed Planning Center data with Claude\n');
    console.log('   Analysis:');
    console.log(`   ${analysis}\n`);

    console.log('✓ All tests passed! Planning Center + Claude integration is working perfectly.');
    console.log('\nNext steps:');
    console.log('- Use `npm run query` to ask questions about your Planning Center data');
    console.log('- Once Craft API is configured, you can sync data to documentation');

  } catch (error) {
    console.error('Error:', error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

test();
