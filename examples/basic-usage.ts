import { PCCCIntegrator, loadConfig } from '../src/index.js';

async function main() {
  // Load configuration from environment variables
  const config = loadConfig();

  // Create the integrator instance
  const integrator = new PCCCIntegrator(config);

  console.log('=== Planning Center + Claude + Craft Integration Examples ===\n');

  // Example 1: Sync events to Craft documentation
  console.log('Example 1: Syncing events to documentation...');
  try {
    const eventDocId = await integrator.syncEventsToDocumentation(
      'your-craft-space-id',
      'This Week\'s Events'
    );
    console.log(`✓ Created document: ${eventDocId}\n`);
  } catch (error) {
    console.error('Error:', error);
  }

  // Example 2: Generate people insights
  console.log('Example 2: Generating people insights...');
  try {
    const peopleDocId = await integrator.syncPeopleInsights(
      'your-craft-space-id',
      'youth'
    );
    console.log(`✓ Created insights document: ${peopleDocId}\n`);
  } catch (error) {
    console.error('Error:', error);
  }

  // Example 3: Ask a question with context
  console.log('Example 3: Asking question with Planning Center context...');
  try {
    const answer = await integrator.queryWithContext(
      'What events are scheduled for this month?',
      { type: 'event' }
    );
    console.log('Answer:', answer, '\n');
  } catch (error) {
    console.error('Error:', error);
  }

  // Example 4: Analyze specific data type
  console.log('Example 4: Analyzing groups data...');
  try {
    const analysisDocId = await integrator.analyzeAndDocument(
      'groups',
      'your-craft-space-id',
      'Identify groups that need more leaders and suggest growth opportunities'
    );
    console.log(`✓ Created analysis document: ${analysisDocId}\n`);
  } catch (error) {
    console.error('Error:', error);
  }

  // Example 5: Using individual clients
  console.log('Example 5: Using clients directly...');
  try {
    const pcClient = integrator.getPlanningCenterClient();
    const craftClient = integrator.getCraftClient();
    const claudeClient = integrator.getClaudeClient();

    // Get Planning Center data
    const events = await pcClient.getCalendarEvents({ per_page: 5 });
    console.log(`Found ${events.length} events`);

    // Analyze with Claude
    const summary = await claudeClient.summarize(
      JSON.stringify(events, null, 2),
      100
    );
    console.log('Summary:', summary);

    // List Craft spaces
    const spaces = await craftClient.getSpaces();
    console.log(`Found ${spaces.length} Craft spaces\n`);
  } catch (error) {
    console.error('Error:', error);
  }

  // Example 6: Service plan summary
  console.log('Example 6: Generating service plan summary...');
  try {
    const servicePlanDocId = await integrator.generateServicePlanSummary(
      'your-service-type-id',
      'your-craft-space-id'
    );
    console.log(`✓ Created service plan document: ${servicePlanDocId}\n`);
  } catch (error) {
    console.error('Error:', error);
  }

  console.log('=== Examples Complete ===');
}

main().catch(console.error);
